---
title: skywalking-java-plugin
date: 2022-01-06 10:40:57
tags:
---

SkyWalking Java Agent 插件加载机制（上）

之前的两篇文章分别介绍了 SkyWalking Java Agent 日志组件 和 配置初始化流程

- [SkyWalking Java Agent 日志组件分析](https://juejin.cn/post/7047329063135871013)

- [SkyWalking Java Agent 配置初始化流程分析](https://juejin.cn/post/7050487296243531784)

今天我们要分析的是 SkyWalking Java Agent 插件加载机制

```java
/**
 * The main entrance of sky-walking agent, based on javaagent mechanism.
 */
public class SkyWalkingAgent {
    private static ILog LOGGER = LogManager.getLogger(SkyWalkingAgent.class);

    /**
     * Main entrance. Use byte-buddy transform to enhance all classes, which define in plugins.
     */
    public static void premain(String agentArgs, Instrumentation instrumentation) throws PluginException {
        final PluginFinder pluginFinder;
        
        // 省略部分代码....
        
        try {
            pluginFinder = new PluginFinder(new PluginBootstrap().loadPlugins());
        } catch (AgentPackageNotFoundException ape) {
            LOGGER.error(ape, "Locate agent.jar failure. Shutting down.");
            return;
        } catch (Exception e) {
            LOGGER.error(e, "SkyWalking agent initialized failure. Shutting down.");
            return;
        }

        // 省略部分代码....
    }
    

    // 省略部分代码....
}    
```


核心代码
```java
pluginFinder = new PluginFinder(new PluginBootstrap().loadPlugins());
```

PluginBootstrap 是一个插件查找器，使用 PluginResourcesResolver 查找所有插件，使用 PluginCfg 加载所有插件。

```java
/**
 * Plugins finder. Use {@link PluginResourcesResolver} to find all plugins, and ask {@link PluginCfg} to load all plugin
 * definitions.
 */
public class PluginBootstrap {
    private static final ILog LOGGER = LogManager.getLogger(PluginBootstrap.class);

    /**
     * load all plugins.
     *
     * @return plugin definition list.
     */
    public List<AbstractClassEnhancePluginDefine> loadPlugins() throws AgentPackageNotFoundException {
        // 1.初始化 AgentClassLoader
        AgentClassLoader.initDefaultLoader();

        PluginResourcesResolver resolver = new PluginResourcesResolver();
      	// 2.使用 AgentClassLoader 读取插件定义文件 skywalking-plugin.def
        List<URL> resources = resolver.getResources();

        if (resources == null || resources.size() == 0) {
            LOGGER.info("no plugin files (skywalking-plugin.def) found, continue to start application.");
            return new ArrayList<AbstractClassEnhancePluginDefine>();
        }

        for (URL pluginUrl : resources) {
            try {
                // 3.读取插件定义文件 skywalking-plugin.def 内容，封装成 PluginDefine
                PluginCfg.INSTANCE.load(pluginUrl.openStream());
            } catch (Throwable t) {
                LOGGER.error(t, "plugin file [{}] init failure.", pluginUrl);
            }
        }

        List<PluginDefine> pluginClassList = PluginCfg.INSTANCE.getPluginClassList();

        List<AbstractClassEnhancePluginDefine> plugins = new ArrayList<AbstractClassEnhancePluginDefine>();
        for (PluginDefine pluginDefine : pluginClassList) {
            try {
                LOGGER.debug("loading plugin class {}.", pluginDefine.getDefineClass());
                // 4.使用 AgentClassLoader 加载并实例化插件定义类
                AbstractClassEnhancePluginDefine plugin = (AbstractClassEnhancePluginDefine) Class.forName(pluginDefine.getDefineClass(), true, AgentClassLoader
                    .getDefault()).newInstance();
                plugins.add(plugin);
            } catch (Throwable t) {
                LOGGER.error(t, "load plugin [{}] failure.", pluginDefine.getDefineClass());
            }
        }

        plugins.addAll(DynamicPluginLoader.INSTANCE.load(AgentClassLoader.getDefault()));

        return plugins;

    }

}
```

主要包括以下几个步骤：

1.初始化类加载器 AgentClassLoader；

2.PluginResourcesResolver.getResources() 使用 AgentClassLoader 类加载器读取插件定义文件 skywalking-plugin.def；

3.PluginCfg.load(InputStream input)  读取 skywalking-plugin.def 内容，读取插件定义文件的每一行，比如 dubbo=org.apache.skywalking.apm.plugin.asf.dubbo.DubboInstrumentation，将每一行的 name=class 封装成 PluginDefine；

4.Class.forName 通过 AgentClassLoader 加载并实例化插件定义类 class，AbstractClassEnhancePluginDefine 是 SkyWalking Java Agent 中所有增强插件的基类。

```java
AbstractClassEnhancePluginDefine plugin = (AbstractClassEnhancePluginDefine) Class.forName(pluginDefine.getDefineClass(), true, AgentClassLoader
    .getDefault()).newInstance();
```

关于插件加载机制的内容比较多，因此分为准备上下两篇来写，上篇我们要分析的是自定义类加载器 AgentClassLoader 部分

首先我们回顾下 Java 类加载器

#### 类加载器
类加载器对象负责加载类，ClassLoader 是一个抽象类，给定一个类的 binary name，类加载器尝试定位或生成构成类定义的数据，典型的场景是从文件系统读取类的 class 文件。对于任意一个类，都必须由加载它的类加载器和这个类本身共同决定了其在 Java 虚拟机中的唯一性。
每一个Class 对象包含一个指向定义它的类加载器的引用。

数组类的 class 对象不是由类加载器创建的，而是根据 Java 运行时的需要自动创建的，通过 Class.getClassLoader() 返回的数组类的类加载器和它的元素类（element type）的类加载器相同，比如下面的示例代码 Foo[]数组的 class 对象的类加载器和 Foo 的 class 对象的类加载器相同，原生类型的数组没有类加载器。

```java
public class FooArrayTest {
    public static void main(String[] args) {
        Foo[] foos = new Foo[10];
        foos[0] = new Foo();
        System.out.println(foos.getClass().getClassLoader());
        System.out.println(Foo.class.getClassLoader());
    }
}

class Foo {
}
```

输出

```java
sun.misc.Launcher$AppClassLoader@18b4aac2
sun.misc.Launcher$AppClassLoader@18b4aac2
```



应用程序可以通过继承 ClassLoader 来扩展 Java 虚拟机动态加载类的方式。ClassLoader 采用委托模式查找类和资源，每一个 ClassLoader 实例都有一个相关联的父类加载器（parent class loader）。

当请求查找一个类或资源的时候，ClassLoader 实例在它尝试自己查找类或资源之前会将查找委托给它的父类加载器。Java 虚拟机内置的类加载器叫作启动类加载器（bootstrap class loader），它没有父类加载#器，但是可以作为 ClassLoader 实例的父类加载器。

#### 类加载器的并行能力
支持并发加载类的类加载器被称为具有并行能力的类加载器，需要在类初始化的时候通过调用 ClassLoader.registerAsParallelCapable() 注册自己。注意，ClassLoader 类在默认情况下被注册为具有并行能力，而它的子类如果需要具有并行能力，需要注册它们自己。

AgentClassLoader 类加载器就是通过静态代码块将自己注册为具有并行能力。

```java
public class AgentClassLoader extends ClassLoader {

    static {
        /*
         * Try to solve the classloader dead lock. See https://github.com/apache/skywalking/pull/2016
         * 支持并发的加载类，参见 ClassLoader 的 Javadoc
         */
        registerAsParallelCapable();
    }
    
    // 省略部分代码....
}
```

在委托模式不是严格分层的环境中，类加载器需要并行能力，否则类加载可能导致死锁，因为加载器锁在类加载过程一直被持有（参见 ClassLoader.loadClass方法）。

通常，Java 虚拟机从本地文件系统加载类，比如从  CLASSPATH 环境变量定义的目录加载类，然而一些类可能不是以文件的形式存在，它们可能从其他形式产生，例如网络或由应用程序构造。defineClass 方法将类的字节数组转换成 Class 实例，这个新定义的类的 Class 实例可以通过 Class.newInstance() 创建类的实例。

一个类加载创建的对象的方法和构造器可能引用了其他类，为了确定引用的类，Java 虚拟机调用同一个类加载器的 loadClass 方法加载引用的类。例如，应用程序可以创建一个类加载器从服务器下载类的 class 文件，示例代码如下

```java
ClassLoader loader = new NetworkClassLoader(host, port);
Object main = loader.loadClass("Main", true).newInstance();
. . .
```

NetworkClassLoader 必须继承 ClassLoader，并重写 findClass 方法从网络下载 class 的字节数组，然后使用 defineClass 方法创建 Class 实例。

```java
class NetworkClassLoader extends ClassLoader {
    String host;
    int port;

    @Override
    public Class<?> findClass(String name) throws ClassNotFoundException {
        byte[] b = loadClassData(name);
        return defineClass(name, b, 0, b.length);
    }

    private byte[] loadClassData(String name) {
        // load the class data from the connection
        . . .
    }
}
```


#### AgentClassLoader 初始化默认类加载器

初始化类加载器 AgentClassLoader，AgentClassLoader 是 SkyWalking Java Agent 自定义的类加载器，用于加载指定目录的 jar 插件（默认加载的插件目录 plugins 和 activations）。

AgentClassLoader 继承 ClassLoader，重写 findClass 方法。


`AgentClassLoader.initDefaultLoader();` 初始化默认的 AgentClassLoader 类加载器，并赋值给成员变量 DEFAULT_LOADER。
```java
 /**
 * Init the default class loader.
 *
 * @throws AgentPackageNotFoundException if agent package is not found.
 */
public static void initDefaultLoader() throws AgentPackageNotFoundException {
    if (DEFAULT_LOADER == null) {
        synchronized (AgentClassLoader.class) {
            if (DEFAULT_LOADER == null) {
                DEFAULT_LOADER = new AgentClassLoader(PluginBootstrap.class.getClassLoader());
                LOGGER.info("DEFAULT_LOADER parent is " + DEFAULT_LOADER.getParent().getClass());
            }
        }
    }
}
```
首先判断 DEFAULT_LOADER 是否为空，如果为空，则进入 synchronized 同步代码块进行 double check，调用 AgentClassLoader 构造方法做一些变量的初始化, 设置 AgentClassLoader 的 classpath。
AgentClassLoader 的构造方法传入父类加载器 AppClassLoader， 通过 `PluginBootstrap.class.getClassLoader()` 获取的类加载器，PluginBootstrap 类是由 AppClassLoader 加载的。

```java
public AgentClassLoader(ClassLoader parent) throws AgentPackageNotFoundException {
    super(parent);
    LOGGER.info("AgentClassLoader parent is " + parent.getClass());
    // SkyWalking agent.jar 所在目录
    File agentDictionary = AgentPackagePath.getPath();
    classpath = new LinkedList<>();
    // 设置插件的 classpath
    Config.Plugin.MOUNT.forEach(mountFolder -> classpath.add(new File(agentDictionary, mountFolder)));
}
```
通过 File agentDictionary = AgentPackagePath.getPath(); 获取SkyWalking agent.jar 所在目录，默认插件目录位于 SkyWalking agent.jar目录下的 plugins 和 activations目录。
经过以上步骤 AgentClassLoader 的默认类加载器初始化完成了。


#### findClass 方法实现过程
接下来我们重点看下 findClass 方法是如何实现的，findClass 方法首先调用了 getAllJars 方法用于获取所有的 jar 插件（文件后缀是.jar），获取到的 jar 信息赋值给成员变量 List<Jar> allJars;

```java
private List<Jar> getAllJars() {
    if (allJars == null) {
        jarScanLock.lock();
        try {
            // 获取到锁之后，再检查一次
            if (allJars == null) {
                allJars = doGetJars();
            }
        } finally {
            jarScanLock.unlock();
        }
    }

    return allJars;
}

private LinkedList<Jar> doGetJars() {
    LinkedList<Jar> jars = new LinkedList<>();
    // 从 classpath 目录下查找
    for (File path : classpath) {
        if (path.exists() && path.isDirectory()) {
            // 查找目录下所有的.jar文件
            String[] jarFileNames = path.list((dir, name) -> name.endsWith(".jar"));
            for (String fileName : jarFileNames) {
                try {
                    File file = new File(path, fileName);
                    Jar jar = new Jar(new JarFile(file), file);
                    jars.add(jar);
                    LOGGER.info("{} loaded.", file.toString());
                } catch (IOException e) {
                    LOGGER.error(e, "{} jar file can't be resolved", fileName);
                }
            }
        }
    }
    return jars;
}
```
然后将目标类的全类名 name（比如com.xxx.Foo）转换成目录格式， 遍历 allJars 查找目标类是存在，如果存储读取目录表字节码内容到 byte[]，
调用 父类 ClassLoader 的 defineClass 方法将目标类的字节数组转换成类的 Class 对象。


那么我们重写的 findClass 方法什么时候会被调用呢？
当我们使用反射 Class.forName(name, true, AgentClassLoader.getDefault()) 指定类加载器为 AgentClassLoader 的时候，会调用我们自定义的的 findClass 方法。

AgentClassLoader 完整代码
```java
/**
 * The <code>AgentClassLoader</code> represents a classloader, which is in charge of finding plugins and interceptors.
 */
public class AgentClassLoader extends ClassLoader {

    static {
        /*
         * Try to solve the classloader dead lock. See https://github.com/apache/skywalking/pull/2016
         * 支持并发的加载类，参见 ClassLoader 的 Javadoc
         */
        registerAsParallelCapable();
    }

    private static final ILog LOGGER = LogManager.getLogger(AgentClassLoader.class);
    /**
     * The default class loader for the agent.
     */
    private static AgentClassLoader DEFAULT_LOADER;

    private List<File> classpath;
    private List<Jar> allJars;
    private ReentrantLock jarScanLock = new ReentrantLock();

    public static AgentClassLoader getDefault() {
        return DEFAULT_LOADER;
    }

    /**
     * Init the default class loader.
     *
     * @throws AgentPackageNotFoundException if agent package is not found.
     */
    public static void initDefaultLoader() throws AgentPackageNotFoundException {
        if (DEFAULT_LOADER == null) {
            synchronized (AgentClassLoader.class) {
                if (DEFAULT_LOADER == null) {
                    DEFAULT_LOADER = new AgentClassLoader(PluginBootstrap.class.getClassLoader());
                    LOGGER.info("DEFAULT_LOADER parent is " + DEFAULT_LOADER.getParent().getClass());
                }
            }
        }
    }

    public AgentClassLoader(ClassLoader parent) throws AgentPackageNotFoundException {
        super(parent);
        LOGGER.info("AgentClassLoader parent is " + parent.getClass());
        // SkyWalking agent.jar 所在目录
        File agentDictionary = AgentPackagePath.getPath();
        classpath = new LinkedList<>();
        // 设置插件的 classpath
        Config.Plugin.MOUNT.forEach(mountFolder -> classpath.add(new File(agentDictionary, mountFolder)));
    }

    /**
     * Class.forName(name, true, AgentClassLoader.getDefault()) 使用 AgentClassLoader 类加载器时，会调用这个 findClass 方法
     * 具体见父类 ClassLoader 的 loadClass 方法
     * @param name
     * @return
     * @throws ClassNotFoundException
     */
    @Override
    protected Class<?> findClass(String name) throws ClassNotFoundException {
        List<Jar> allJars = getAllJars();
        String path = name.replace('.', '/').concat(".class");
        for (Jar jar : allJars) {
            JarEntry entry = jar.jarFile.getJarEntry(path);
            if (entry == null) {
                continue;
            }
            try {
                URL classFileUrl = new URL("jar:file:" + jar.sourceFile.getAbsolutePath() + "!/" + path);
                byte[] data;
                try (final BufferedInputStream is = new BufferedInputStream(
                    classFileUrl.openStream()); final ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
                    int ch;
                    while ((ch = is.read()) != -1) {
                        baos.write(ch);
                    }
                    data = baos.toByteArray();
                }
                // defineClass 方法用于将类的字节数组转换成类的 Class 对象
                return processLoadedClass(defineClass(name, data, 0, data.length));
            } catch (IOException e) {
                LOGGER.error(e, "find class fail.");
            }
        }
        throw new ClassNotFoundException("Can't find " + name);
    }

    @Override
    protected URL findResource(String name) {
        List<Jar> allJars = getAllJars();
        for (Jar jar : allJars) {
            JarEntry entry = jar.jarFile.getJarEntry(name);
            if (entry != null) {
                try {
                    return new URL("jar:file:" + jar.sourceFile.getAbsolutePath() + "!/" + name);
                } catch (MalformedURLException ignored) {
                }
            }
        }
        return null;
    }

    // 父类 ClassLoader 的 getResources 方法内部会调用这个方法
    @Override
    protected Enumeration<URL> findResources(String name) throws IOException {
        List<URL> allResources = new LinkedList<>();
        List<Jar> allJars = getAllJars();
        for (Jar jar : allJars) {
            // 从 jar 包中查找目标文件
            JarEntry entry = jar.jarFile.getJarEntry(name);
            if (entry != null) {
                allResources.add(new URL("jar:file:" + jar.sourceFile.getAbsolutePath() + "!/" + name));
            }
        }

        final Iterator<URL> iterator = allResources.iterator();
        return new Enumeration<URL>() {
            @Override
            public boolean hasMoreElements() {
                return iterator.hasNext();
            }

            @Override
            public URL nextElement() {
                return iterator.next();
            }
        };
    }

    private Class<?> processLoadedClass(Class<?> loadedClass) {
        final PluginConfig pluginConfig = loadedClass.getAnnotation(PluginConfig.class);
        if (pluginConfig != null) {
            // Set up the plugin config when loaded by class loader at the first time.
            // Agent class loader just loaded limited classes in the plugin jar(s), so the cost of this
            // isAssignableFrom would be also very limited.
            SnifferConfigInitializer.initializeConfig(pluginConfig.root());
        }

        return loadedClass;
    }

    private List<Jar> getAllJars() {
        if (allJars == null) {
            jarScanLock.lock();
            try {
                // 获取到锁之后，再检查一次
                if (allJars == null) {
                    allJars = doGetJars();
                }
            } finally {
                jarScanLock.unlock();
            }
        }

        return allJars;
    }

    private LinkedList<Jar> doGetJars() {
        LinkedList<Jar> jars = new LinkedList<>();
        // 从 classpath 目录下查找
        for (File path : classpath) {
            if (path.exists() && path.isDirectory()) {
                // 查找目录下所有的.jar文件
                String[] jarFileNames = path.list((dir, name) -> name.endsWith(".jar"));
                for (String fileName : jarFileNames) {
                    try {
                        File file = new File(path, fileName);
                        Jar jar = new Jar(new JarFile(file), file);
                        jars.add(jar);
                        LOGGER.info("{} loaded.", file.toString());
                    } catch (IOException e) {
                        LOGGER.error(e, "{} jar file can't be resolved", fileName);
                    }
                }
            }
        }
        return jars;
    }

    @RequiredArgsConstructor
    private static class Jar {
        private final JarFile jarFile;
        private final File sourceFile;
    }
}
```



抽象类定义属性，并为属性提供 Setter 和 Getter 方法，子类通过构造方法内调用super(xx)将属性赋值给父类。


