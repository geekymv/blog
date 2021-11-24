---
title: perfect-code
date: 2021-10-12 10:27:18
tags:
---

com.netflix.discovery.shared.resolver.ResolverUtils 类

```java
/**
 * Randomize server list.
 * 随机化list
 * @return a copy of the original list with elements in the random order
 */
public static <T extends EurekaEndpoint> List<T> randomize(List<T> list) {
    // 新创建一个List是为了不改变原有的list
    List<T> randomList = new ArrayList<>(list);
    if (randomList.size() < 2) {
        return randomList;
    }
    // 洗牌操作
    Collections.shuffle(randomList,ThreadLocalRandom.current());
    return randomList;
}
```


com.netflix.discovery.DiscoveryClient 类
创建线程池
```text
// default size of 2 - 1 each for heartbeat and cacheRefresh
scheduler = Executors.newScheduledThreadPool(2,
        new ThreadFactoryBuilder()
                .setNameFormat("DiscoveryClient-%d")
                .setDaemon(true)
                .build());

heartbeatExecutor = new ThreadPoolExecutor(
        1, clientConfig.getHeartbeatExecutorThreadPoolSize(), 0, TimeUnit.SECONDS,
        new SynchronousQueue<Runnable>(),
        new ThreadFactoryBuilder()
                .setNameFormat("DiscoveryClient-HeartbeatExecutor-%d")
                .setDaemon(true)
                .build()
);  // use direct handoff

cacheRefreshExecutor = new ThreadPoolExecutor(
        1, clientConfig.getCacheRefreshExecutorThreadPoolSize(), 0, TimeUnit.SECONDS,
        new SynchronousQueue<Runnable>(),
        new ThreadFactoryBuilder()
                .setNameFormat("DiscoveryClient-CacheRefreshExecutor-%d")
                .setDaemon(true)
                .build()
);  // use direct handoff
```

Eureka 每30s 执行一次renew操作

EurekaHttpClient 接口