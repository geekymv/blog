---
title: SkyWalking Java Agent 配置初始化流程分析
date: 2022-01-04 08:47:28
tags:
---
**基于 SkyWalking Java Agent 8.8.0 版本**

上一篇文章我们通过 SkyWalking Java Agent 日志组件分析一文详细介绍了日志相关的底层实现原理，今天我们要正式进入 premain 方法了，premain 方法见名知义就是在我们 Java 程序的 main 方法之前运行的方法，一般我们通过 JVM 参数 `-javaagent:/path/to/skywalking-agent.jar` 的方式指定代理程序。

今天我们要分析的是 SkyWalking Java Agent 配置相关内容，我们接触到的框架大都需要一些配置文件，比如 SpringBoot 中的 application.yml。
SkyWalking Java Agent 在 premain 方法中首先做的就是通过 `SnifferConfigInitializer.initializeCoreConfig(agentArgs);` 初始化核心配置。

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
        try {
            SnifferConfigInitializer.initializeCoreConfig(agentArgs);
        } catch (Exception e) {
            // try to resolve a new logger, and use the new logger to write the error log here
            LogManager.getLogger(SkyWalkingAgent.class)
                    .error(e, "SkyWalking agent initialized failure. Shutting down.");
            return;
        } finally {
            // refresh logger again after initialization finishes
            LOGGER = LogManager.getLogger(SkyWalkingAgent.class);
        }
        // 省略部分代码....
        
    }
    // 省略部分代码....
}        
```
今天我们要重点分析的就是这行代码的内部实现
```java
SnifferConfigInitializer.initializeCoreConfig(agentArgs);
```

建议在继续阅读之前大家可以先阅读 [skywalking-java](https://github.com/apache/skywalking-java) 项目官方提供的关于配置相关的文档
- [Locate agent config file by system property](https://github.com/apache/skywalking-java/blob/v8.8.0/docs/en/setup/service-agent/java-agent/Specified-agent-config.md) 关于通过系统属性指定配置文件；
- [Setting Override](https://github.com/apache/skywalking-java/blob/v8.8.0/docs/en/setup/service-agent/java-agent/Setting-override.md) 关于配置覆盖相关内容。

#### 初始化核心配置

SnifferConfigInitializer 类使用多种方式初始化配置，内部实现有以下几个重要步骤：

1.loadConfig() 加载配置文件

- 从指定的配置文件路径读取配置文件内容，通过 -Dskywalking_config=/xxx/yyy 可以指定配置文件位置；
- 如果没有指定配置文件路径，则从默认配置文件 config/agent.config 读取；
- 将配置文件内容加载到 Properties；

```java
/**
 * Load the specified config file or default config file
 *
 * @return the config file {@link InputStream}, or null if not needEnhance.
 */
private static InputStreamReader loadConfig() throws AgentPackageNotFoundException, ConfigNotFoundException {
    // System.getProperty() 读取 Java 虚拟机中的系统属性, Java 虚拟机中的系统属性在运行Java程序的时候通过 java -Dk1=v1 配置.
    String specifiedConfigPath = System.getProperty(SPECIFIED_CONFIG_PATH);
    // 使用指定的配置文件或默认的配置文件, AgentPackagePath.getPath() 获取 skywalking-agent.jar 所在目录
    File configFile = StringUtil.isEmpty(specifiedConfigPath) ? new File(
        AgentPackagePath.getPath(), DEFAULT_CONFIG_FILE_NAME) : new File(specifiedConfigPath);

    if (configFile.exists() && configFile.isFile()) {
        try {
            LOGGER.info("Config file found in {}.", configFile);

            return new InputStreamReader(new FileInputStream(configFile), StandardCharsets.UTF_8);
        } catch (FileNotFoundException e) {
            throw new ConfigNotFoundException("Failed to load agent.config", e);
        }
    }
    throw new ConfigNotFoundException("Failed to load agent.config.");
}
```


2.replacePlaceholders() 解析占位符 placeholder

- ​从配置文件中读取到的配置值都是以 placeholder 形式(比如 agent.service_name=${SW_AGENT_NAME:Your_ApplicationName})存在的，这里需要将占位符解析为实际值。

```java
/**
 * Replaces all placeholders of format {@code ${name}} with the corresponding property from the supplied {@link
 * Properties}.
 *
 * @param value      the value containing the placeholders to be replaced
 * @param properties the {@code Properties} to use for replacement
 * @return the supplied value with placeholders replaced inline
 */
public String replacePlaceholders(String value, final Properties properties) {
    return replacePlaceholders(value, new PlaceholderResolver() {
        @Override
        public String resolvePlaceholder(String placeholderName) {
            return getConfigValue(placeholderName, properties);
        }
    });
}

// 优先级 System.Properties(-D) > System environment variables > Config file
private String getConfigValue(String key, final Properties properties) {
    // 从Java虚拟机系统属性中获取(-D)
    String value = System.getProperty(key);
    if (value == null) {
        // 从操作系统环境变量获取, 比如 JAVA_HOME、Path 等环境变量
        value = System.getenv(key);
    }
    if (value == null) {
        // 从配置文件中获取
        value = properties.getProperty(key);
    }
    return value;
}
```


3.overrideConfigBySystemProp() 读取 System.getProperties() 中以 skywalking. 开头的系统属性覆盖配置;

```java
/**
 * Override the config by system properties. The property key must start with `skywalking`, the result should be as
 * same as in `agent.config`
 * <p>
 * such as: Property key of `agent.service_name` should be `skywalking.agent.service_name`
 */
private static void overrideConfigBySystemProp() throws IllegalAccessException {
    Properties systemProperties = System.getProperties();
    for (final Map.Entry<Object, Object> prop : systemProperties.entrySet()) {
        String key = prop.getKey().toString();
        // 必须是以 skywalking. 开头的属性
        if (key.startsWith(ENV_KEY_PREFIX)) {
            String realKey = key.substring(ENV_KEY_PREFIX.length());
            AGENT_SETTINGS.put(realKey, prop.getValue());
        }
    }
}
```

4.overrideConfigByAgentOptions() 解析 agentArgs 参数配置覆盖配置，后面会重点分析；

agentArgs 就是 premain 方法的第一个参数，以 `-javaagent:/path/to/skywalking-agent.jar=k1=v1,k2=v2`的形式传值。

5.initializeConfig() 将以上读取到的配置信息映射到 Config 类的静态属性；

6.configureLogger() 根据配置的 Config.Logging.RESOLVER 重配置 Log，更多关于日志参见文章；

```java
static void configureLogger() {
    switch (Config.Logging.RESOLVER) {
        case JSON:
            LogManager.setLogResolver(new JsonLogResolver());
            break;
        case PATTERN:
        default:
            LogManager.setLogResolver(new PatternLogResolver());
    }
}
```

7.必填参数验证，验证非空参数 agent.service_name 和 collector.servers。



#### 定位 skywalking-agent.jar 所在目录
skywalking-agent 目录结构如下：
{% asset_img skywalking-agent.png skywalking-agent %}
config 目录存放的是默认配置文件 agent.config，读取默认配置文件，以及后面加载插件都需要用到 skywalking-agent.jar 所在目录

```java
/**
 * Load the specified config file or default config file
 *
 * @return the config file {@link InputStream}, or null if not needEnhance.
 */
private static InputStreamReader loadConfig() throws AgentPackageNotFoundException, ConfigNotFoundException {
    // System.getProperty() 读取 Java 虚拟机中的系统属性, Java 虚拟机中的系统属性在运行Java程序的时候通过 java -Dk1=v1 配置.
    String specifiedConfigPath = System.getProperty(SPECIFIED_CONFIG_PATH);
    // 使用指定的配置文件或默认的配置文件, AgentPackagePath.getPath() 获取 skywalking-agent.jar 所在目录
    File configFile = StringUtil.isEmpty(specifiedConfigPath) ? new File(
        AgentPackagePath.getPath(), DEFAULT_CONFIG_FILE_NAME) : new File(specifiedConfigPath);

    if (configFile.exists() && configFile.isFile()) {
        try {
            LOGGER.info("Config file found in {}.", configFile);

            return new InputStreamReader(new FileInputStream(configFile), StandardCharsets.UTF_8);
        } catch (FileNotFoundException e) {
            throw new ConfigNotFoundException("Failed to load agent.config", e);
        }
    }
    throw new ConfigNotFoundException("Failed to load agent.config.");
}
```
new File(AgentPackagePath.getPath(), DEFAULT_CONFIG_FILE_NAME) 定位默认配置文件的位置，
AgentPackagePath.getPath() 方法用来获取 skywalking-agent.jar 所在目录

```java
/**
 * AgentPackagePath is a flag and finder to locate the SkyWalking agent.jar. It gets the absolute path of the agent jar.
 * The path is the required metadata for agent core looking up the plugins and toolkit activations. If the lookup
 * mechanism fails, the agent will exit directly.
 */
public class AgentPackagePath {
    private static final ILog LOGGER = LogManager.getLogger(AgentPackagePath.class);

    private static File AGENT_PACKAGE_PATH;

    public static File getPath() throws AgentPackageNotFoundException {
        if (AGENT_PACKAGE_PATH == null) {
            // 返回 skywalking-agent.jar 文件所在的目录 E:\develop\source\sample\source\skywalking-java\skywalking-agent
            AGENT_PACKAGE_PATH = findPath();
        }
        return AGENT_PACKAGE_PATH;
    }

    public static boolean isPathFound() {
        return AGENT_PACKAGE_PATH != null;
    }

    private static File findPath() throws AgentPackageNotFoundException {
        // 将 AgentPackagePath 全类名中的.替换成 /
        // org/apache/skywalking/apm/agent/core/boot/AgentPackagePath.class
        String classResourcePath = AgentPackagePath.class.getName().replaceAll("\\.", "/") + ".class";
        // 使用 AppClassLoader 加载资源，通常情况下 AgentPackagePath 类是被 AppClassLoader 加载的。
        URL resource = ClassLoader.getSystemClassLoader().getResource(classResourcePath);
        if (resource != null) {
            String urlString = resource.toString();
            //jar:file:/E:/source/skywalking-java/skywalking-agent/skywalking-agent.jar!/org/apache/skywalking/apm/agent/core/boot/AgentPackagePath.class
            LOGGER.debug("The beacon class location is {}.", urlString);

            // 判断 url 中是否包含!，如果包含则说明 AgentPackagePath.class 是包含在jar中。
            int insidePathIndex = urlString.indexOf('!');
            boolean isInJar = insidePathIndex > -1;

            if (isInJar) {
                // file:/E:/source/skywalking-java/skywalking-agent/skywalking-agent.jar
                urlString = urlString.substring(urlString.indexOf("file:"), insidePathIndex);
                File agentJarFile = null;
                try {
                    // E:\source\skywalking-java\skywalking-agent\skywalking-agent.jar
                    agentJarFile = new File(new URL(urlString).toURI());
                } catch (MalformedURLException | URISyntaxException e) {
                    LOGGER.error(e, "Can not locate agent jar file by url:" + urlString);
                }
                if (agentJarFile.exists()) {
                    // 返回 skywalking-agent.jar 文件所在的目录
                    return agentJarFile.getParentFile();
                }
            } else {
                int prefixLength = "file:".length();
                String classLocation = urlString.substring(
                    prefixLength, urlString.length() - classResourcePath.length());
                return new File(classLocation);
            }
        }

        LOGGER.error("Can not locate agent jar file.");
        throw new AgentPackageNotFoundException("Can not locate agent jar file.");
    }

}
```

通过类加载器 AppClassLoader 加载 AgentPackagePath.class 资源，定位到  skywalking-agent.jar 所在的目录，保存到静态成员变量 AGENT_PACKAGE_PATH 中，下次获取直接读取静态变量。

#### 配置优先级 

Agent Options > System.Properties(-D) > System environment variables > Config file

System.getProperties() 和 System.getenv() 区别，请参考文章 https://www.cnblogs.com/clarke157/p/6609761.html

- System.getProperties() 获取 Java 虚拟机相关的系统属性（比如 java.version、 java.io.tmpdir 等），通过 java -D配置；
- System.getenv() 获取系统环境变量（比如 JAVA_HOME、Path 等），通过操作系统配置。



#### 将配置信息映射到 Config 类
在我们的日常开发中一般是直接从 Properties 读取需要的配置项，SkyWalking Java Agent 并没有这么做，而是定义一个配置类 Config，将配置项映射到 Config 类的静态属性中，其他地方需要配置项的时候，直接从类的静态属性获取就可以了，非常方便使用。
ConfigInitializer 就是负责将 Properties 中的 key/value 键值对映射到类（比如 Config 类）的静态属性，其中 key 对应类的静态属性，value 赋值给静态属性的值。

```java
/**
 * This is the core config in sniffer agent.
 */
public class Config {

    public static class Agent {
        /**
         * Namespace isolates headers in cross process propagation. The HEADER name will be `HeaderName:Namespace`.
         */
        public static String NAMESPACE = "";

        /**
         * Service name is showed in skywalking-ui. Suggestion: set a unique name for each service, service instance
         * nodes share the same code
         */
        @Length(50)
        public static String SERVICE_NAME = "";
     
        // 省略部分代码....
    }
    
    public static class Collector {
        /**
         * Collector skywalking trace receiver service addresses.
         */
        public static String BACKEND_SERVICE = "";
        
        // 省略部分代码....
    }
    
    // 省略部分代码....

    public static class Logging {
        /**
         * Log file name.
         */
        public static String FILE_NAME = "skywalking-api.log";

        /**
         * Log files directory. Default is blank string, means, use "{theSkywalkingAgentJarDir}/logs  " to output logs.
         * {theSkywalkingAgentJarDir} is the directory where the skywalking agent jar file is located.
         * <p>
         * Ref to {@link WriterFactory#getLogWriter()}
         */
        public static String DIR = "";
    }

    // 省略部分代码....

}
```
比如通过 agent.config 配置文件配置服务名称
```text
# The service name in UI
agent.service_name=${SW_AGENT_NAME:Your_ApplicationName}
```
agent 对应 Config 类的静态内部类 Agent ；
service_name 对应静态内部类 Agent 的静态属性 SERVICE_NAME。
SkyWalking Java Agent 在这里面使用了下划线而不是驼峰来命名配置项，将类的静态属性名称转换成下划线配置名称非常方便，直接转成小写就可以通过 Properties 获取对应的值了。


ConfigInitializer 类源码：
```java
/**
 * Init a class's static fields by a {@link Properties}, including static fields and static inner classes.
 * <p>
 */
public class ConfigInitializer {
    public static void initialize(Properties properties, Class<?> rootConfigType) throws IllegalAccessException {
        initNextLevel(properties, rootConfigType, new ConfigDesc());
    }

    private static void initNextLevel(Properties properties, Class<?> recentConfigType,
                                      ConfigDesc parentDesc) throws IllegalArgumentException, IllegalAccessException {
        for (Field field : recentConfigType.getFields()) {
            if (Modifier.isPublic(field.getModifiers()) && Modifier.isStatic(field.getModifiers())) {
                String configKey = (parentDesc + "." + field.getName()).toLowerCase();
                Class<?> type = field.getType();

                if (type.equals(Map.class)) {
                    /*
                     * Map config format is, config_key[map_key]=map_value
                     * Such as plugin.opgroup.resttemplate.rule[abc]=/url/path
                     */
                    // Deduct two generic types of the map
                    ParameterizedType genericType = (ParameterizedType) field.getGenericType();
                    Type[] argumentTypes = genericType.getActualTypeArguments();

                    Type keyType = null;
                    Type valueType = null;
                    if (argumentTypes != null && argumentTypes.length == 2) {
                        // Get key type and value type of the map
                        keyType = argumentTypes[0];
                        valueType = argumentTypes[1];
                    }
                    Map map = (Map) field.get(null);
                    // Set the map from config key and properties
                    setForMapType(configKey, map, properties, keyType, valueType);
                } else {
                    /*
                     * Others typical field type
                     */
                    String value = properties.getProperty(configKey);
                    // Convert the value into real type
                    final Length lengthDefine = field.getAnnotation(Length.class);
                    if (lengthDefine != null) {
                        if (value != null && value.length() > lengthDefine.value()) {
                            value = value.substring(0, lengthDefine.value());
                        }
                    }
                    Object convertedValue = convertToTypicalType(type, value);
                    if (convertedValue != null) {
                        // 通过反射给静态属性设置值
                        field.set(null, convertedValue);
                    }
                }
            }
        }
        // recentConfigType.getClasses() 获取 public 的 classes 和 interfaces
        for (Class<?> innerConfiguration : recentConfigType.getClasses()) {
            // parentDesc 将类（接口）名入栈
            parentDesc.append(innerConfiguration.getSimpleName());
            // 递归调用
            initNextLevel(properties, innerConfiguration, parentDesc);
            // parentDesc 将类（接口）名出栈
            parentDesc.removeLastDesc();
        }
    }

    // 省略部分代码....
}

class ConfigDesc {
    private LinkedList<String> descs = new LinkedList<>();

    void append(String currentDesc) {
        if (StringUtil.isNotEmpty(currentDesc)) {
            descs.addLast(currentDesc);
        }
    }

    void removeLastDesc() {
        descs.removeLast();
    }

    @Override
    public String toString() {
        return String.join(".", descs);
    }
}

```
ConfigInitializer.initNextLevel 方法涉及到的技术点有反射、递归调用、栈等。

笔者在阅读源码过程对部分代码添加的注释已经提交到 GitHub 上了，具体参见 https://github.com/geekymv/skywalking-java/tree/v8.8.0-annotated

如有问题，欢迎交流。

