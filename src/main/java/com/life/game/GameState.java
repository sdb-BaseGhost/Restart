package com.life.game;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GameState implements Serializable {

    private static final long serialVersionUID = 1L;

    private int age;                          // 当前年龄，从 0 开始
    private int intelligence;                 // 智力
    private int appearance;                   // 颜值
    private int constitution;                 // 体质
    private int family;                       // 家境
    private int luck;                         // 幸运
    private int wealth;                       // 财富
    private int health;                       // 健康（初始 50）
    private int happiness;                    // 快乐（初始 50）
    private int social;                       // 社交（初始 50）
    private int achievement;                  // 成就
    private List<Integer> selectedTalents;    // 已选天赋 ID
    private List<String> eventLog;            // 事件日志
    private Map<String, Integer> talentBonuses; // 天赋成长加成标记
    private boolean alive;                    // 是否存活
    private String endingName;                // 结局名称

    // ========== Getter / Setter ==========

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public int getIntelligence() {
        return intelligence;
    }

    public void setIntelligence(int intelligence) {
        this.intelligence = intelligence;
    }

    public int getAppearance() {
        return appearance;
    }

    public void setAppearance(int appearance) {
        this.appearance = appearance;
    }

    public int getConstitution() {
        return constitution;
    }

    public void setConstitution(int constitution) {
        this.constitution = constitution;
    }

    public int getFamily() {
        return family;
    }

    public void setFamily(int family) {
        this.family = family;
    }

    public int getLuck() {
        return luck;
    }

    public void setLuck(int luck) {
        this.luck = luck;
    }

    public int getWealth() {
        return wealth;
    }

    public void setWealth(int wealth) {
        this.wealth = wealth;
    }

    public int getHealth() {
        return health;
    }

    public void setHealth(int health) {
        this.health = health;
    }

    public int getHappiness() {
        return happiness;
    }

    public void setHappiness(int happiness) {
        this.happiness = happiness;
    }

    public int getSocial() {
        return social;
    }

    public void setSocial(int social) {
        this.social = social;
    }

    public int getAchievement() {
        return achievement;
    }

    public void setAchievement(int achievement) {
        this.achievement = achievement;
    }

    public List<Integer> getSelectedTalents() {
        return selectedTalents;
    }

    public void setSelectedTalents(List<Integer> selectedTalents) {
        this.selectedTalents = selectedTalents;
    }

    public List<String> getEventLog() {
        return eventLog;
    }

    public void setEventLog(List<String> eventLog) {
        this.eventLog = eventLog;
    }

    public Map<String, Integer> getTalentBonuses() {
        return talentBonuses;
    }

    public void setTalentBonuses(Map<String, Integer> talentBonuses) {
        this.talentBonuses = talentBonuses;
    }

    public boolean isAlive() {
        return alive;
    }

    public void setAlive(boolean alive) {
        this.alive = alive;
    }

    public String getEndingName() {
        return endingName;
    }

    public void setEndingName(String endingName) {
        this.endingName = endingName;
    }

    // ========== 业务方法 ==========

    /**
     * 添加一条事件日志
     */
    public void addEventLog(String log) {
        if (this.eventLog == null) {
            this.eventLog = new ArrayList<>();
        }
        this.eventLog.add(log);
    }

    /**
     * 游戏是否结束：死亡或已有结局
     */
    public boolean isGameOver() {
        return !alive || endingName != null;
    }
}
