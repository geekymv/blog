---
title: skywalking-java
date: 2021-11-29 10:41:08
tags:
---

**基于 SkyWalking Java Agent 8.8.0 版本**

SkyWalkingAgent 类包含 Java Agent 的入口 premain 方法

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
今天我们要分析的不是 premain 方法，而是任何一个应用程序都需要的日志框架，SkyWalking Java Agent 并没有依赖现有的日志框架如 log4j 之类的，而是自己实现了一套。

SkyWalkingAgent 类的第一行代码就是 SkyWalking Java Agent 自己实现的日志组件，看起来和其他常用的日志组件的使用方式没什么区别。
```java
private static ILog LOGGER = LogManager.getLogger(SkyWalkingAgent.class);
```
首先通过日志管理器 LogManager 获取 ILog 接口的一个具体实现，这是典型的Java多态 - 父类（接口）的引用指向子类的实现。
ILog 接口提供了我们常用的打印日志的方法
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

LogManager 类的具体实现：
```java
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
LogManager 类是 LogResolver 实现类的管理器，通过使用 LogResolver，LogManager.getLogger(Class) 返回了 ILog 接口的一个实现，
LogManager 类是日志组件的主要入口，内部封装了日志组件的实现细节。

LogResolver 类只是返回 ILog 接口的实现
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

#### ILog 接口的实现类
- NoopLogger 枚举
NoopLogger 直接继承了 ILog，NoopLogger 只是实现了 ILog 接口，所有方法都是空实现，NoopLogger 存在的意义是为了防止 NullPointerException。
因为调用者可以通过 LogManager 的 setLogResolver 方法设置不同的日志解析器 LogResolver，如果为null，则返回 ILog 接口的默认实现 NoopLogger。

- AbstractLogger 抽象类
    - PatternLogger
    - JsonLogResolver

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

AbstractLogger 类实现了 ILog 接口，实现了打印日志方法，最终都调用了下面这个通用的方法
```java
protected void logger(LogLevel level, String message, Throwable e) {
    WriterFactory.getLogWriter().write(this.format(level, message, e));
}
```

其中 format 方法是一个抽象方法，留给子类去实现日志输出的格式，返回字符串的字符串将输出到文件或标准输出。
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