package com.life.service;

import com.life.game.GameState;
import com.life.model.User;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.resps.Tuple;

public class RankService {
    public static final RankService me = new RankService();

    private static final String RANK_ACHIEVEMENT = "game:rank:achievement";
    private static final String RANK_WEALTH = "game:rank:wealth";
    private static final String RANK_AGE = "game:rank:age";

    /**
     * 更新排行榜
     */
    public void updateRank(int userId, GameState state) {
        String member = String.valueOf(userId);
        try (Jedis jedis = RedisManager.getJedis()) {
            jedis.zadd(RANK_ACHIEVEMENT, state.getAchievement(), member);
            jedis.zadd(RANK_WEALTH, state.getWealth(), member);
            jedis.zadd(RANK_AGE, state.getAge(), member);
        } catch (Exception e) {
            System.err.println("排行榜更新失败: " + e.getMessage());
        }
    }

    /**
     * 获取成就排行榜 Top N
     */
    public List<Map<String, String>> getTopAchievement(int count) {
        return getTop(RANK_ACHIEVEMENT, count);
    }

    /**
     * 获取财富排行榜
     */
    public List<Map<String, String>> getTopWealth(int count) {
        return getTop(RANK_WEALTH, count);
    }

    /**
     * 获取长寿排行榜
     */
    public List<Map<String, String>> getTopAge(int count) {
        return getTop(RANK_AGE, count);
    }

    private List<Map<String, String>> getTop(String key, int count) {
        List<Map<String, String>> result = new ArrayList<>();
        try (Jedis jedis = RedisManager.getJedis()) {
            List<Tuple> tuples = jedis.zrevrangeWithScores(key, 0, count - 1);
            for (Tuple tuple : tuples) {
                Map<String, String> item = new HashMap<>();
                item.put("userId", tuple.getElement());
                item.put("score", String.valueOf((long) tuple.getScore()));
                User user = User.dao.findById(Integer.parseInt(tuple.getElement()));
                item.put("nickname", user != null ? user.getStr("nickname") : "未知");
                result.add(item);
            }
        } catch (Exception e) {
            System.err.println("排行榜查询失败: " + e.getMessage());
        }
        return result;
    }
}
