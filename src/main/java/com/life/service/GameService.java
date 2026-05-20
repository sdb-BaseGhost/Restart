package com.life.service;

import com.jfinal.plugin.activerecord.Db;
import com.jfinal.plugin.activerecord.Page;
import com.life.game.GameEngine;
import com.life.game.GameState;
import com.life.model.Ending;
import com.life.model.Event;
import com.life.model.GameResult;
import com.life.model.Talent;

import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class GameService {
    public static final GameService me = new GameService();

    /**
     * 获取随机天赋列表
     */
    public List<Talent> getRandomTalents(int count) {
        List<Talent> all = CacheService.me.getAllTalents();
        if (all.size() <= count) {
            return all;
        }
        Collections.shuffle(all);
        return all.subList(0, count);
    }

    /**
     * 创建游戏：初始化状态，应用天赋
     */
    public GameState createGame(int intelligence, int appearance, int constitution,
                                int family, int luck, List<Integer> talentIds) {
        GameState state = GameEngine.initGameState(intelligence, appearance, constitution, family, luck);

        List<Talent> allTalents = CacheService.me.getAllTalents();
        List<Talent> selected = allTalents.stream()
                .filter(t -> talentIds.contains(t.getInt("id")))
                .collect(Collectors.toList());

        state.setSelectedTalents(talentIds);
        GameEngine.applyTalents(state, selected);
        return state;
    }

    /**
     * 推进一年：核心游戏循环
     */
    public Map<String, Object> nextYear(GameState state) {
        Map<String, Object> result = new HashMap<>();

        state.setAge(state.getAge() + 1);
        GameEngine.applyTalentGrowth(state);

        List<Event> allEvents = CacheService.me.getAllEvents();
        List<Event> ageFiltered = GameEngine.filterEventsByAge(state.getAge(), allEvents);
        List<Event> filtered = GameEngine.filterEventsByCondition(state, ageFiltered);
        Event event = GameEngine.selectRandomEvent(filtered);

        if (event != null) {
            state.markEventTriggered(event.getInt("id"));
            GameEngine.applyEventEffect(state, event.getStr("effects"));
            state.addEventLog("【" + state.getAge() + "岁】" + event.getStr("name") + "：" + event.getStr("description"));
            result.put("event", event);
        }

        GameEngine.checkDeath(state);

        if (!state.isAlive()) {
            // 死亡时才检查结局，作为人生总结
            List<Ending> endings = CacheService.me.getAllEndings();
            String ending = GameEngine.checkEnding(state, endings);
            state.setEndingName(ending != null ? ending : "英年早逝");
            state.addEventLog("你在 " + state.getAge() + " 岁时离开了人世...");
            result.put("dead", true);
        }

        result.put("state", state);
        return result;
    }

    /**
     * 保存游戏结果
     */
    public void saveResult(int userId, GameState state) {
        GameResult gr = new GameResult();
        gr.set("user_id", userId);
        gr.set("final_age", state.getAge());
        gr.set("wealth", state.getWealth());
        gr.set("health", state.getHealth());
        gr.set("knowledge", state.getKnowledge());
        gr.set("social", state.getSocial());
        gr.set("achievement", state.getAchievement());
        gr.set("ending_name", state.getEndingName());
        gr.set("talents", state.getSelectedTalents().stream()
                .map(String::valueOf)
                .collect(Collectors.joining(",")));
        gr.set("create_time", new Date());
        gr.save();

        // 更新排行榜
        RankService.me.updateRank(userId, state);
    }

    /**
     * 查询历史记录（分页）
     */
    public Page<GameResult> getHistory(int userId, int pageNum, int pageSize) {
        return GameResult.dao.paginate(pageNum, pageSize,
                "SELECT *", "FROM game_result WHERE user_id = ? ORDER BY create_time DESC", userId);
    }

    /**
     * 删除历史记录
     */
    public boolean deleteHistory(int id, int userId) {
        return Db.delete("DELETE FROM game_result WHERE id = ? AND user_id = ?", id, userId) > 0;
    }
}
