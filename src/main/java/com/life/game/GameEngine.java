package com.life.game;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.life.model.Ending;
import com.life.model.Event;
import com.life.model.Talent;

import java.util.*;

/**
 * 游戏引擎：包含所有游戏核心逻辑的静态方法
 */
public class GameEngine {

    /**
     * 应用天赋效果到游戏状态
     * - 直接属性加成（如 luck+10）直接加到 state 对应属性
     * - 成长加成（如 intelligence_growth）记录到 talentBonuses map
     * - 特殊天赋处理
     */
    public static void applyTalents(GameState state, List<Talent> talents) {
        if (talents == null || talents.isEmpty()) {
            return;
        }

        for (Talent talent : talents) {
            String effectsJson = talent.getStr("effects");
            if (effectsJson == null || effectsJson.isEmpty()) {
                continue;
            }

            JSONObject effects = JSON.parseObject(effectsJson);
            if (effects == null) {
                continue;
            }

            for (Map.Entry<String, Object> entry : effects.entrySet()) {
                String key = entry.getKey();
                int value = ((Number) entry.getValue()).intValue();

                // 成长加成：记录到 talentBonuses
                if (key.endsWith("_growth")) {
                    if (state.getTalentBonuses() == null) {
                        state.setTalentBonuses(new HashMap<>());
                    }
                    state.getTalentBonuses().merge(key, value, Integer::sum);
                    continue;
                }

                // 特殊天赋标记
                switch (key) {
                    case "zen_youth":
                        // 佛系青年：标记所有属性变化减半
                        if (state.getTalentBonuses() == null) {
                            state.setTalentBonuses(new HashMap<>());
                        }
                        state.getTalentBonuses().put("zen_youth", 1);
                        continue;
                    case "worker_fate":
                        // 天选打工人：标记财富增长+50%
                        if (state.getTalentBonuses() == null) {
                            state.setTalentBonuses(new HashMap<>());
                        }
                        state.getTalentBonuses().put("worker_fate", 1);
                        continue;
                    case "master_slacker":
                        // 摆烂大师：标记成就增长减半
                        if (state.getTalentBonuses() == null) {
                            state.setTalentBonuses(new HashMap<>());
                        }
                        state.getTalentBonuses().put("master_slacker", 1);
                        continue;
                    default:
                        break;
                }

                // 直接属性加成
                applyAttributeBonus(state, key, value);
            }

            // 记录已选天赋
            if (state.getSelectedTalents() == null) {
                state.setSelectedTalents(new ArrayList<>());
            }
            state.getSelectedTalents().add(talent.getInt("id"));
        }
    }

    /**
     * 每岁推进时应用天赋成长加成
     */
    public static void applyTalentGrowth(GameState state) {
        Map<String, Integer> bonuses = state.getTalentBonuses();
        if (bonuses == null || bonuses.isEmpty()) {
            return;
        }

        for (Map.Entry<String, Integer> entry : bonuses.entrySet()) {
            String key = entry.getKey();
            int value = entry.getValue();

            if (!key.endsWith("_growth")) {
                continue;
            }

            // 提取属性名（去掉 _growth 后缀）
            String attr = key.substring(0, key.length() - "_growth".length());

            // 佛系青年：成长加成减半
            if (bonuses.containsKey("zen_youth")) {
                value = value / 2;
                if (value == 0) {
                    continue;
                }
            }

            applyAttributeBonus(state, attr, value);
        }
    }

    /**
     * 按年龄过滤事件：只保留 min_age <= age <= max_age 的事件
     */
    public static List<Event> filterEventsByAge(int age, List<Event> events) {
        if (events == null || events.isEmpty()) {
            return events;
        }
        List<Event> filtered = new ArrayList<>();
        for (Event event : events) {
            int minAge = event.getInt("min_age");
            int maxAge = event.getInt("max_age");
            if (age >= minAge && age <= maxAge) {
                filtered.add(event);
            }
        }
        return filtered;
    }

    /**
     * 按条件过滤事件：只保留 include_cond 满足且 exclude_cond 不满足的事件
     * 条件为空/null 表示无条件（通过）
     */
    public static List<Event> filterEventsByCondition(GameState state, List<Event> events) {
        if (events == null || events.isEmpty()) {
            return events;
        }
        Map<String, Integer> props = state.toConditionMap();
        Map<String, Set<Integer>> setProps = state.toSetConditionMap();
        List<Event> filtered = new ArrayList<>();
        for (Event event : events) {
            // 标记为 no_repeat 的事件只触发一次
            if (event.getInt("no_repeat") == 1 && state.hasTriggeredEvent(event.getInt("id"))) {
                continue;
            }

            String includeCond = event.getStr("include_cond");
            String excludeCond = event.getStr("exclude_cond");

            // include_cond 为空表示无条件触发，非空则必须满足
            if (includeCond != null && !includeCond.isEmpty()) {
                if (!ConditionParser.evaluate(includeCond, props, setProps)) {
                    continue;
                }
            }

            // exclude_cond 为空表示不排除，非空则满足时排除
            if (excludeCond != null && !excludeCond.isEmpty()) {
                if (ConditionParser.evaluate(excludeCond, props, setProps)) {
                    continue;
                }
            }

            filtered.add(event);
        }
        return filtered;
    }

    /**
     * 按 weight 加权随机选择一个事件
     */
    public static Event selectRandomEvent(List<Event> events) {
        if (events == null || events.isEmpty()) {
            return null;
        }

        int totalWeight = 0;
        for (Event event : events) {
            totalWeight += event.getInt("weight");
        }

        if (totalWeight <= 0) {
            return events.get(0);
        }

        int roll = new Random().nextInt(totalWeight);
        int cumulative = 0;
        for (Event event : events) {
            cumulative += event.getInt("weight");
            if (roll < cumulative) {
                return event;
            }
        }

        return events.get(events.size() - 1);
    }

    /**
     * 解析 effects JSON，修改 state 的属性值
     * - 属性值 clamp 到 0-100
     * - 应用天赋修正
     * - 属性联动
     */
    public static void applyEventEffect(GameState state, String effectsJson) {
        if (effectsJson == null || effectsJson.isEmpty()) {
            return;
        }

        JSONObject effects = JSON.parseObject(effectsJson);
        if (effects == null) {
            return;
        }

        Map<String, Integer> bonuses = state.getTalentBonuses();
        boolean isZenYouth = bonuses != null && bonuses.containsKey("zen_youth");
        boolean isWorkerFate = bonuses != null && bonuses.containsKey("worker_fate");
        boolean isMasterSlacker = bonuses != null && bonuses.containsKey("master_slacker");

        for (Map.Entry<String, Object> entry : effects.entrySet()) {
            String attr = entry.getKey();
            int value = ((Number) entry.getValue()).intValue();

            // 佛系青年：所有属性变化减半
            if (isZenYouth && value != 0) {
                value = value > 0 ? Math.max(1, value / 2) : Math.min(-1, value / 2);
            }

            // 天选打工人：财富变化增加50%
            if (isWorkerFate && "wealth".equals(attr) && value > 0) {
                value = (int) (value * 1.5);
            }

            // 摆烂大师：成就增长减半
            if (isMasterSlacker && "achievement".equals(attr) && value > 0) {
                value = Math.max(1, value / 2);
            }

            applyAttributeBonus(state, attr, value);
        }

        // 属性联动
        applyAttributeLinks(state);
    }

    /**
     * 强制死亡：health <= 0
     * 概率死亡（age >= 50 时）
     */
    public static void checkDeath(GameState state) {
        if (!state.isAlive()) {
            return;
        }

        // 强制死亡
        if (state.getHealth() <= 0) {
            state.setAlive(false);
            state.setHealth(0);
            state.addEventLog("你的健康降为0，你去世了...");
            return;
        }

        // 概率死亡（age >= 50）
        if (state.getAge() >= 50) {
            double baseProb = (state.getAge() - 50) * 0.005;     // (age - 50) * 0.5%
            double luckMod = state.getLuck() * 0.001;             // luck * 0.1%
            double healthMod = (50 - state.getHealth()) * 0.002;  // (50 - health) * 0.2%

            double finalProb = baseProb - luckMod + healthMod;

            // clamp 到 0%~30%
            finalProb = Math.max(0.0, Math.min(0.30, finalProb));

            if (Math.random() < finalProb) {
                state.setAlive(false);
                state.addEventLog("在" + state.getAge() + "岁时，你没能抵挡住命运的安排...");
            }
        }
    }

    /**
     * 按 priority 降序遍历结局，匹配条件
     * 返回匹配的结局名称，无匹配返回 null
     */
    public static String checkEnding(GameState state, List<Ending> endings) {
        if (endings == null || endings.isEmpty()) {
            return null;
        }

        // 按 priority 降序排序
        List<Ending> sorted = new ArrayList<>(endings);
        sorted.sort((a, b) -> Integer.compare(b.getInt("priority"), a.getInt("priority")));

        for (Ending ending : sorted) {
            if (matchesEnding(state, ending)) {
                return ending.getStr("name");
            }
        }

        return null;
    }

    /**
     * 创建新 GameState，设置初始属性
     */
    public static GameState initGameState(int intelligence, int appearance,
                                          int constitution, int family, int luck) {
        GameState state = new GameState();

        // 基础属性
        state.setIntelligence(intelligence);
        state.setAppearance(appearance);
        state.setConstitution(constitution);
        state.setFamily(family);
        state.setLuck(luck);

        // 固定初始值
        state.setAge(0);
        state.setHealth(100);
        state.setKnowledge(0);
        state.setSocial(50);
        state.setWealth(20);
        state.setAchievement(0);

        // 存活状态
        state.setAlive(true);

        // 初始化集合
        state.setSelectedTalents(new ArrayList<>());
        state.setEventLog(new ArrayList<>());
        state.setTalentBonuses(new HashMap<>());

        return state;
    }

    // ========== 内部辅助方法 ==========

    /**
     * 将属性变化应用到 state，支持的属性名：
     * intelligence, appearance, constitution, family, luck,
     * wealth, health, knowledge, social, achievement,
     * life, age_change
     * 变化后 clamp 到 0-100（财富和成就无上限）
     */
    private static void applyAttributeBonus(GameState state, String attr, int value) {
        switch (attr) {
            case "intelligence":
                state.setIntelligence(clamp(state.getIntelligence() + value, 0, 100));
                break;
            case "appearance":
                state.setAppearance(clamp(state.getAppearance() + value, 0, 100));
                break;
            case "constitution":
                state.setConstitution(clamp(state.getConstitution() + value, 0, 100));
                break;
            case "family":
                state.setFamily(clamp(state.getFamily() + value, 0, 100));
                break;
            case "luck":
                state.setLuck(clamp(state.getLuck() + value, 0, 100));
                break;
            case "wealth":
                state.setWealth(state.getWealth() + value); // 财富无上限
                break;
            case "health":
                state.setHealth(clamp(state.getHealth() + value, 0, 100));
                break;
            case "knowledge":
                state.setKnowledge(clamp(state.getKnowledge() + value, 0, 100));
                break;
            case "social":
                state.setSocial(clamp(state.getSocial() + value, 0, 100));
                break;
            case "achievement":
                state.setAchievement(state.getAchievement() + value); // 成就无上限
                break;
            case "life":
                // life=-1 表示死亡，life=1 表示复活
                if (value < 0) {
                    state.setAlive(false);
                    state.setHealth(0);
                } else if (value > 0) {
                    state.setAlive(true);
                    if (state.getHealth() <= 0) {
                        state.setHealth(1);
                    }
                }
                break;
            case "age_change":
                state.setAge(state.getAge() + value);
                break;
            default:
                // 未知属性忽略
                break;
        }
    }

    /**
     * 属性联动：在事件效果应用后调用
     * - wealth <= 0 时，health 每岁 -1
     */
    private static void applyAttributeLinks(GameState state) {
        if (state.getWealth() <= 0) {
            state.setHealth(clamp(state.getHealth() - 1, 0, 100));
        }
    }

    /**
     * 检查结局是否匹配
     */
    private static boolean matchesEnding(GameState state, Ending ending) {
        String conditionType = ending.getStr("condition_type");
        String conditionValueStr = ending.getStr("condition_value");
        JSONObject conditionValue = conditionValueStr != null ? JSON.parseObject(conditionValueStr) : null;

        if (conditionType == null) {
            return false;
        }

        switch (conditionType) {
            case "health_zero":
                return state.getHealth() <= 0;

            case "age_reach":
                if (conditionValue != null && conditionValue.containsKey("age")) {
                    return state.getAge() >= conditionValue.getIntValue("age");
                }
                return false;

            case "attribute_high":
                if (conditionValue != null) {
                    String attr = conditionValue.getString("attribute");
                    int threshold = conditionValue.getIntValue("threshold");
                    int value = getAttributeValue(state, attr);
                    // 负阈值表示"低于该值"触发（如财富 < -10）
                    if (threshold < 0) {
                        return value <= threshold;
                    }
                    return value >= threshold;
                }
                return false;

            case "special":
                // 特殊条件：特定天赋+属性组合（talent_id=0 表示无天赋要求）
                if (conditionValue != null) {
                    String specialAttr = conditionValue.getString("attribute");
                    int specialThreshold = conditionValue.getIntValue("threshold");
                    int talentId = conditionValue.getIntValue("talent_id");

                    boolean hasTalent = talentId == 0
                            || (state.getSelectedTalents() != null
                                && state.getSelectedTalents().contains(talentId));
                    int specialValue = getAttributeValue(state, specialAttr);
                    boolean attrMet = specialThreshold < 0
                            ? specialValue <= specialThreshold
                            : specialValue >= specialThreshold;

                    return hasTalent && attrMet;
                }
                return false;

            case "dual_attribute":
                // 双属性条件：两个属性同时满足阈值
                if (conditionValue != null) {
                    String attr1 = conditionValue.getString("attr1");
                    int threshold1 = conditionValue.getIntValue("threshold1");
                    String attr2 = conditionValue.getString("attr2");
                    int threshold2 = conditionValue.getIntValue("threshold2");

                    int val1 = getAttributeValue(state, attr1);
                    int val2 = getAttributeValue(state, attr2);

                    boolean met1 = threshold1 < 0 ? val1 <= threshold1 : val1 >= threshold1;
                    boolean met2 = threshold2 < 0 ? val2 <= threshold2 : val2 >= threshold2;

                    return met1 && met2;
                }
                return false;

            default:
                return false;
        }
    }

    /**
     * 根据属性名获取 state 中的属性值
     */
    private static int getAttributeValue(GameState state, String attr) {
        switch (attr) {
            case "intelligence": return state.getIntelligence();
            case "appearance":   return state.getAppearance();
            case "constitution": return state.getConstitution();
            case "family":       return state.getFamily();
            case "luck":         return state.getLuck();
            case "wealth":       return state.getWealth();
            case "health":       return state.getHealth();
            case "knowledge":    return state.getKnowledge();
            case "social":       return state.getSocial();
            case "achievement":  return state.getAchievement();
            default:             return 0;
        }
    }

    /**
     * 将值限制在 [min, max] 范围内
     */
    private static int clamp(int value, int min, int max) {
        return Math.max(min, Math.min(max, value));
    }
}
