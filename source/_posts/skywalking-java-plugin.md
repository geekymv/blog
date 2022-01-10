---
title: skywalking-java-plugin
date: 2022-01-06 10:40:57
tags:
---

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
            // 配置初始化过程可能会抛出异常（验证非空参数），这里为了使用新的 LogResolver 需要重新获取日志对象
            LogManager.getLogger(SkyWalkingAgent.class)
                    .error(e, "SkyWalking agent initialized failure. Shutting down.");
            return;
        } finally {
            // refresh logger again after initialization finishes
            LOGGER = LogManager.getLogger(SkyWalkingAgent.class);
        }

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


今天我们要分析的源码是插件加载部分
```java
pluginFinder = new PluginFinder(new PluginBootstrap().loadPlugins());
```

PluginBootstrap 是一个插件查找器，使用 PluginResourcesResolver 查找所有插件，使用 PluginCfg 加载所有插件。


抽象类定义属性，并为属性提供 Setter 和 Getter 方法，子类通过构造方法内调用super(xx)将属性赋值给父类。


