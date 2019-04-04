---
title: 用 LinkedHashMap 实现一个 LRU 
date: 2019-04-04 11:04:54
tags:
---
参考 org.apache.kafka.common.cache.LRUCache

```java
/**
 * Interface for caches, semi-peristent maps which store key-value mappings until either an eviction criteria is met
 * or the entries are manually invalidated. Caches are not required to be thread-safe, but some implementations may be.
 */
public interface Cache<K, V> {

    /**
     * Look up a value in the cache.
     * @param key the key to
     * @return the cached value, or null if it is not present.
     */
    V get(K key);

    /**
     * Insert an entry into the cache.
     * @param key the key to insert
     * @param value the value to insert
     */
    void put(K key, V value);

    /**
     * Manually invalidate a key, clearing its entry from the cache.
     * @param key the key to remove
     * @return true if the key existed in the cache and the entry was removed or false if it was not present
     */
    boolean remove(K key);

    /**
     * Get the number of entries in this cache. If this cache is used by multiple threads concurrently, the returned
     * value will only be approximate.
     * @return the number of entries in the cache
     */
    long size();
}

```

```java
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * A cache implementing a least recently used policy.
 */
public class LRUCache<K, V> implements Cache<K, V> {
    private final LinkedHashMap<K, V> cache;

    public LRUCache(final int maxSize) {
        cache = new LinkedHashMap<K, V>(16, .75f, true) {
            @Override
            protected boolean removeEldestEntry(Map.Entry eldest) {
                return size() > maxSize;
            }
        };
    }

    @Override
    public V get(K key) {
        return cache.get(key);
    }

    @Override
    public void put(K key, V value) {
        cache.put(key, value);
    }

    @Override
    public boolean remove(K key) {
        return cache.remove(key) != null;
    }

    @Override
    public long size() {
        return cache.size();
    }
}


```