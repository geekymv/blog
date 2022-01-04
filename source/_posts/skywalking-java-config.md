---
title: skywalking-java-config
date: 2022-01-04 08:47:28
tags:
---
SkyWalking Java Agent 配置初始化流程分析
上一篇文章我们通过 SkyWalking Java Agent 日志组件分析一文详细介绍了日志相关的底层实现原理，今天我们要正式进入 premain 方法了，
premain 方法见名知义就是在我们 Java 程序的 main 方法之前运行的方法，一般我们通过 JVM 参数 -javaagent:/path/to/skywalking-agent.jar 的方式指定代理程序。
java agent 相关内容不是本文重点，更多内容请参考文末相关阅读连接。


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
今天我们要重点分析的就是这行代码内部实现
```java
SnifferConfigInitializer.initializeCoreConfig(agentArgs);
```
SnifferConfigInitializer 使用多种方式初始化配置

我们进入 initializeCoreConfig 方法看下具体实现过程

loadConfig() 加载配置文件
replacePlaceholders 解析 placeholder
overrideConfigBySystemProp() 读取 System.Properties 属性
overrideConfigByAgentOptions() 解析 agentArgs 参数配置
initializeConfig() 将以上读取到的配置信息映射到 Config 类的静态属性
验证非空参数 agent.service_name 和 collector.servers。

1. 从指定的配置文件路径读取配置文件内容，通过 -Dskywalking_config=/xxx/yyyy
2. 如果没有指定配置文件路径，则从默认配置文件读取；
3. 将配置文件内容加载到 Properties；
4. 从系统属性读取配置覆盖配置
5. 从
6. 将配置信息映射到 Config 类的静态属性

1、如何定位 skywalking-agent.jar 所在目录
读取默认配置文件，以及后面加载插件都需要用到 SkyWalking agent.jar 所在目录

2、配置优先级 Setting-override.md
Agent Options > System.Properties(-D) > System environment variables > Config file

System.getProperties() 和 System.getenv() 区别
System.getProperties() 获取 Java 虚拟机相关的系统属性（比如 java.version、 java.io.tmpdir 等），通过 java -D配置；
System.getenv() 获取系统环境变量（比如 JAVA_HOME、Path 等），通过操作系统配置。
请参考 https://www.cnblogs.com/clarke157/p/6609761.html


其中涉及到大量的字符串操作，大家对这部分感兴趣的可以看源码研究。

3、如何将配置值映射到 Config 类

ConfigInitializer 负责将 Properties 中的 key/value 键值对映射到类的静态属性，其中 key 对应类的静态属性，value 赋值给静态属性值。
比如 Config 类
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
        
    }

```

