---
title: skywalking-java
date: 2021-12-29 10:41:08
tags:
---

**基于 SkyWalking Java Agent 8.8.0 版本**

SkyWalkingAgent 类是 SkyWalking Java Agent 的入口 premain 方法所在类，今天我们要分析的不是 premain 方法，而是任何一个应用程序都需要的日志框架，SkyWalking Java Agent 并没有依赖现有的日志框架如 log4j 之类的，而是自己实现了一套。

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
        // 省略部分代码....
    }
}
```

SkyWalkingAgent 类的第一行代码就是自己实现的日志组件，看起来和其他常用的日志组件的使用方式没什么区别。
```java
private static ILog LOGGER = LogManager.getLogger(SkyWalkingAgent.class);
```
首先通过日志管理器 LogManager 获取 ILog 接口的一个具体实现，这是典型的Java多态 - 父类（接口）的引用指向子类的实现。

#### ILog 接口

ILog 接口提供了我们常用的打印日志的方法，定义了一套日志使用规范。

```java
/**
 * The Log interface. It's very easy to understand, like any other log-component. Do just like log4j or log4j2 does.
 * <p>
 */
public interface ILog {
    void info(String format);
    
    void info(String format, Object... arguments);

    void info(Throwable t, String format, Object... arguments);

    void debug(String format);

    void debug(String format, Object... arguments);

    // 省略部分代码....
}    
```

#### LogManager

我们看下 LogManager 类的具体实现

```java
/**
 * LogManager is the {@link LogResolver} implementation manager. By using {@link LogResolver}, {@link
 * LogManager#getLogger(Class)} returns a {@link ILog} implementation. This module use this class as the main entrance,
 * and block the implementation detail about log-component. In different modules, like server or sniffer, it will use
 * different implementations.
 *
 * <p> If no {@link LogResolver} is registered, return {@link NoopLogger#INSTANCE} to avoid
 * {@link NullPointerException}. If {@link LogManager#setLogResolver(LogResolver)} is called twice, the second will
 * override the first without any warning or exception.
 *
 * <p> Created by xin on 2016/11/10.
 */
public class LogManager {
    private static LogResolver RESOLVER = new PatternLogResolver();

    public static void setLogResolver(LogResolver resolver) {
        LogManager.RESOLVER = resolver;
    }

    public static ILog getLogger(Class<?> clazz) {
        if (RESOLVER == null) {
            return NoopLogger.INSTANCE;
        }
        return LogManager.RESOLVER.getLogger(clazz);
    }

    public static ILog getLogger(String clazz) {
        if (RESOLVER == null) {
            return NoopLogger.INSTANCE;
        }
        return LogManager.RESOLVER.getLogger(clazz);
    }
}
```

LogManager 类是 LogResolver 实现类的管理器，通过使用 LogResolver，LogManager.getLogger(Class) 返回了 ILog 接口的一个实现，LogManager 类是日志组件的主要入口，内部封装了日志组件的实现细节。

LogManager 内部提供了setLogResolver 方法用于注册指定的 LogResolver，如果设置 LogResolver 为 null，则返回 NoopLogger 实例。

LogResolver 只是返回 ILog 接口的实现
```java
/**
 * {@link LogResolver} just do only one thing: return the {@link ILog} implementation.
 * <p>
 */
public interface LogResolver {
    /**
     * @param clazz the class is showed in log message.
     * @return {@link ILog} implementation.
     */
    ILog getLogger(Class<?> clazz);

    /**
     * @param clazz the class is showed in log message.
     * @return {@link ILog} implementation.
     */
    ILog getLogger(String clazz);
}
```

LogResolver 接口目前提供了2个实现类：PatternLogResolver 、JsonLogResolver 分别返回 PatternLogger 和 JsonLogger。
{% asset_img LogResolver.png LogResolver %}


#### ILog 接口的实现类

{% asset_img ILog.png ILog %}

- NoopLogger 枚举
NoopLogger 直接继承了 ILog，NoopLogger 只是实现了 ILog 接口，所有方法都是空实现，NoopLogger 存在的意义是为了防止 NullPointerException，因为调用者可以通过 LogManager 的 setLogResolver 方法设置不同的日志解析器 LogResolver，如果为null，则返回 ILog 接口的默认实现 NoopLogger。

- AbstractLogger 抽象类
    - PatternLogger
    - JsonLogger

#### AbstractLogger 

AbstractLogger 抽象类是为了简化 ILog 接口的具体实现，主要功能：

1. 它持有logger类名 targetClass；
2. 负责日志级别检查；
3. 解析用户输入的 message，将{}替换为对应的参数值；
4. 提供格式化日志内容的抽象方法，需要具体子类实现，目前支持 pattern 和 json 两种，默认为pattern。

输出的日志格式
```text
%level %timestamp %thread %class : %msg %throwable
```
每一项代表的意义如下：
```text
%level 日志级别.
%timestamp 时间戳 yyyy-MM-dd HH:mm:ss:SSS 格式.
%thread 线程名.
%msg 用户指定的日志信息.
%class 类名.
%throwable 异常信息.
%agent_name agent名称.
```

对于日志格式中的每一项， SkyWalking Java Agent 分别提供了对应的转换器解析，比如 ThreadConverter、LevelConverter 等。

```java
/**
 * An abstract class to simplify the real implementation of the loggers.
 * It hold the class name of the logger, and is responsible for log level check,
 * message interpolation, etc.
 */
public abstract class AbstractLogger implements ILog {
    public static final Map<String, Class<? extends Converter>> DEFAULT_CONVERTER_MAP = new HashMap<>();
    protected List<Converter> converters = new ArrayList<>();

    static {
        DEFAULT_CONVERTER_MAP.put("thread", ThreadConverter.class);
        DEFAULT_CONVERTER_MAP.put("level", LevelConverter.class);
        DEFAULT_CONVERTER_MAP.put("agent_name", AgentNameConverter.class);
        DEFAULT_CONVERTER_MAP.put("timestamp", DateConverter.class);
        DEFAULT_CONVERTER_MAP.put("msg", MessageConverter.class);
        DEFAULT_CONVERTER_MAP.put("throwable", ThrowableConverter.class);
        DEFAULT_CONVERTER_MAP.put("class", ClassConverter.class);
    }
 
    // 省略部分代码....
}    
```

比如 ThreadConverter 类用于解析 %thread 输出当前线程的 name。

```java
/**
 * Just return the Thread.currentThread().getName()
 */
public class ThreadConverter implements Converter {
    @Override
    public String convert(LogEvent logEvent) {
        return Thread.currentThread().getName();
    }

    @Override
    public String getKey() {
        return "thread";
    }
}
```


#### 日志格式化 format

AbstractLogger 类实现了 ILog 接口，实现了打印日志方法，最终都调用了下面这个通用的方法

```java
protected void logger(LogLevel level, String message, Throwable e) {
    WriterFactory.getLogWriter().write(this.format(level, message, e));
}
```

其中 logger 方法内部调用了 format 方法，format  是一个抽象方法，留给子类去实现日志输出的格式，返回字符串的字符串将输出到文件或标准输出。
```java
 /**
 * The abstract method left for real loggers.
 * Any implementation MUST return string, which will be directly transferred to log destination,
 * i.e. log files OR stdout
 *
 * @param level log level
 * @param message log message, which has been interpolated with user-defined parameters.
 * @param e throwable if exists
 * @return string representation of the log, for example, raw json string for {@link JsonLogger}
 */
protected abstract String format(LogLevel level, String message, Throwable e);
```


抽象类对接口中的方法做了实现，每个实现中都调用了一个抽象方法，这个抽象方法让子类来实现具体的业务逻辑。

下面是 AbstractLogger  抽象类其中一个实现类 PatternLogger 类对 format 方法的实现，调用转换器相应的 Converter ，将日志拼接成字符串。

```java
@Override
protected String format(LogLevel level, String message, Throwable t) {
    LogEvent logEvent = new LogEvent(level, message, t, targetClass);
    StringBuilder stringBuilder = new StringBuilder();
    for (Converter converter : this.converters) {
        stringBuilder.append(converter.convert(logEvent));
    }
    return stringBuilder.toString();
}

public void setPattern(String pattern) {
    if (StringUtil.isEmpty(pattern)) {
        pattern = DEFAULT_PATTERN;
    }
    this.pattern = pattern;
    this.converters = new Parser(pattern, DEFAULT_CONVERTER_MAP).parse();
}
```


PatternLogger 将日志格式 pattern 转换成对应的转换器 Converter 是在 PatternLogger.setPattern 方法实现的，内部调用了 Parser.parse 方法，具体实现参见 Parser 类源码。



#### WriterFactory 

日志已经拼装完毕，接下来就该将日志内容输出到指定的位置，WriterFactory 工厂类就是负责创建 IWriter 接口的实现类，用于将日志信息写入到目的地。

```java
public interface IWriter {
    void write(String message);
}
```


IWriter 接口有2种实现 FileWriter 和 SystemOutWriter

- FileWriter：使用一个阻塞队列 ArrayBlockingQueue 作为缓冲，线程池 ScheduledExecutorService 异步从队列中取出日志信息，使用 FileOutputStream 将日志信息写入日志文件中，典型的生产者-消费者模式；

- SystemOutWriter：将日志信息输出到控制台；

{% asset_img IWriter.png IWriter %}

#### FileWriter 工作原理

下面我们看下 FileWriter 是如何将日志写入日志文件的

{% asset_img FileWriter.png FileWriter %}

- FileWriter 负责将日志信息写入 ArrayBlockingQueue 队列中

- ScheduledExecutorService 定时任务
  a）每秒从 ArrayBlockingQueue 取出所有日志信息，写入到文件中；
  b）判断文件大小是否超过最大值Config.Logging.MAX_FILE_SIZE；
  c）如果超过最大值将当前文件重命名。

```java
/**
 * Write log to the queue. W/ performance trade off.
 *
 * @param message to log
 */
@Override
public void write(String message) {
    logBuffer.offer(message);
}
```

![10_write](skywalking-java/10_write.png)

#### 日志组件涉及到的设计模式：

- 工厂模式
- 单例模式（懒汉模式、枚举类）
- 生产者-消费者模式

好了，今天的内容就到这里了，看完之后自己是否也能模仿写一个日志组件呢

[SkyWalking Java Agent 源码](https://github.com/apache/skywalking-java)