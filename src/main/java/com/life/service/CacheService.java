package com.life.service;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.life.model.Ending;
import com.life.model.Event;
import com.life.model.Talent;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import redis.clients.jedis.Jedis;

public class CacheService {
    public static final CacheService me = new CacheService();

    private static final String KEY_EVENTS = "game:events";
    private static final String KEY_TALENTS = "game:talents";
    private static final String KEY_ENDINGS = "game:endings";

    /**
     * 初始化：从数据库加载到 Redis
     */
    public void init() {
        try {
            loadEvents();
            loadTalents();
            loadEndings();
        } catch (Exception e) {
            System.err.println("Redis 初始化失败，降级到数据库: " + e.getMessage());
        }
    }

    private void loadEvents() {
        List<Event> events = Event.dao.find("SELECT * FROM event");
        try (Jedis jedis = RedisManager.getJedis()) {
            jedis.del(KEY_EVENTS);
            for (Event event : events) {
                jedis.hset(KEY_EVENTS, String.valueOf(event.getInt("id")),
                        JSON.toJSONString(event.toMap()));
            }
        }
    }

    private void loadTalents() {
        List<Talent> talents = Talent.dao.find("SELECT * FROM talent");
        try (Jedis jedis = RedisManager.getJedis()) {
            jedis.del(KEY_TALENTS);
            for (Talent talent : talents) {
                jedis.hset(KEY_TALENTS, String.valueOf(talent.getInt("id")),
                        JSON.toJSONString(talent.toMap()));
            }
        }
    }

    private void loadEndings() {
        List<Ending> endings = Ending.dao.find("SELECT * FROM ending");
        try (Jedis jedis = RedisManager.getJedis()) {
            jedis.del(KEY_ENDINGS);
            for (Ending ending : endings) {
                jedis.hset(KEY_ENDINGS, String.valueOf(ending.getInt("id")),
                        JSON.toJSONString(ending.toMap()));
            }
        }
    }

    /**
     * 获取所有天赋（优先从 Redis，降级到 DB）
     */
    public List<Talent> getAllTalents() {
        try (Jedis jedis = RedisManager.getJedis()) {
            if (jedis.exists(KEY_TALENTS)) {
                List<Talent> result = new ArrayList<>();
                Map<String, String> all = jedis.hgetAll(KEY_TALENTS);
                for (String json : all.values()) {
                    Talent t = new Talent();
                    JSONObject obj = JSON.parseObject(json);
                    for (Map.Entry<String, Object> entry : obj.entrySet()) {
                        t.set(entry.getKey(), entry.getValue());
                    }
                    result.add(t);
                }
                return result;
            }
        } catch (Exception ignored) {
        }
        return Talent.dao.find("SELECT * FROM talent");
    }

    /**
     * 获取所有事件
     */
    public List<Event> getAllEvents() {
        try (Jedis jedis = RedisManager.getJedis()) {
            if (jedis.exists(KEY_EVENTS)) {
                List<Event> result = new ArrayList<>();
                Map<String, String> all = jedis.hgetAll(KEY_EVENTS);
                for (String json : all.values()) {
                    Event e = new Event();
                    JSONObject obj = JSON.parseObject(json);
                    for (Map.Entry<String, Object> entry : obj.entrySet()) {
                        e.set(entry.getKey(), entry.getValue());
                    }
                    result.add(e);
                }
                return result;
            }
        } catch (Exception ignored) {
        }
        return Event.dao.find("SELECT * FROM event");
    }

    /**
     * 按年龄阶段获取事件
     */
    public List<Event> getEventsByPool(String pool) {
        List<Event> all = getAllEvents();
        List<Event> filtered = new ArrayList<>();
        for (Event e : all) {
            String stage = getEventStage(e.getInt("min_age"));
            if (stage.equals(pool)) {
                filtered.add(e);
            }
        }
        return filtered.isEmpty() ? all : filtered;
    }

    private String getEventStage(int age) {
        if (age <= 6) return "childhood";
        if (age <= 18) return "school";
        if (age <= 30) return "youth";
        if (age <= 50) return "middle";
        return "elder";
    }

    /**
     * 获取所有结局
     */
    public List<Ending> getAllEndings() {
        try (Jedis jedis = RedisManager.getJedis()) {
            if (jedis.exists(KEY_ENDINGS)) {
                List<Ending> result = new ArrayList<>();
                Map<String, String> all = jedis.hgetAll(KEY_ENDINGS);
                for (String json : all.values()) {
                    Ending e = new Ending();
                    JSONObject obj = JSON.parseObject(json);
                    for (Map.Entry<String, Object> entry : obj.entrySet()) {
                        e.set(entry.getKey(), entry.getValue());
                    }
                    result.add(e);
                }
                return result;
            }
        } catch (Exception ignored) {
        }
        return Ending.dao.find("SELECT * FROM ending");
    }
}
