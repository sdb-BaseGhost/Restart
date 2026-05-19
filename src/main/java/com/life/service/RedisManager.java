package com.life.service;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

/**
 * Redis 连接管理器
 */
public class RedisManager {
    private static JedisPool jedisPool;

    public static void init(JedisPool pool) {
        jedisPool = pool;
    }

    public static Jedis getJedis() {
        if (jedisPool == null) {
            throw new RuntimeException("Redis 未初始化");
        }
        return jedisPool.getResource();
    }

    public static JedisPool getPool() {
        return jedisPool;
    }
}
