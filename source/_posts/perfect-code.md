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