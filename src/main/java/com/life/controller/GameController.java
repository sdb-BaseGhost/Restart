package com.life.controller;

import com.jfinal.aop.Before;
import com.jfinal.core.Controller;
import com.jfinal.core.Path;
import com.jfinal.plugin.activerecord.Page;
import com.life.game.GameState;
import com.life.model.*;
import com.life.service.*;
import com.life.validator.GameValidator;
import com.life.interceptor.GameInterceptor;

import java.util.*;

@Path("/game")
public class GameController extends Controller {

    // 开局页面
    public void start() {
        setAttr("loginUser", getSessionAttr("loginUser"));
        // 获取 10 个随机天赋供选择
        List<Talent> talents = GameService.me.getRandomTalents(10);
        setAttr("talents", talents);
        render("start.html");
    }

    // 创建游戏（提交属性 + 天赋）
    @Before(GameValidator.class)
    public void create() {
        int intelligence = getParaToInt("intelligence", 5);
        int appearance = getParaToInt("appearance", 5);
        int constitution = getParaToInt("constitution", 5);
        int family = getParaToInt("family", 5);
        int luck = getParaToInt("luck", 0);

        String[] talentStrs = getParaValues("talents");
        List<Integer> talentIds = new ArrayList<>();
        if (talentStrs != null) {
            for (String s : talentStrs) {
                talentIds.add(Integer.parseInt(s));
            }
        }

        GameState state = GameService.me.createGame(intelligence, appearance, constitution, family, luck, talentIds);
        setSessionAttr("gameState", state);
        redirect("/game/playing");
    }

    // 游戏主界面
    @Before(GameInterceptor.class)
    public void playing() {
        setAttr("loginUser", getSessionAttr("loginUser"));
        GameState state = getSessionAttr("gameState");
        setAttr("state", state);
        render("playing.html");
    }

    // 推进一年
    @Before(GameInterceptor.class)
    public void nextYear() {
        GameState state = getSessionAttr("gameState");

        Map<String, Object> result = GameService.me.nextYear(state);
        setSessionAttr("gameState", state);

        if (state.isGameOver()) {
            // 游戏结束，保存结果
            User user = getSessionAttr("loginUser");
            if (user != null) {
                GameService.me.saveResult(user.getInt("id"), state);
            }
            redirect("/game/result");
        } else {
            redirect("/game/playing");
        }
    }

    // 结局页面
    public void result() {
        setAttr("loginUser", getSessionAttr("loginUser"));
        GameState state = getSessionAttr("gameState");
        if (state == null) {
            redirect("/game/start");
            return;
        }
        String description = EndingService.me.getEndingDescription(state.getEndingName());
        setAttr("state", state);
        setAttr("description", description);
        render("result.html");
    }

    // 历史记录（分页）
    public void history() {
        User user = getSessionAttr("loginUser");
        setAttr("loginUser", user);
        int pageNum = getParaToInt("page", 1);
        Page<GameResult> page = GameService.me.getHistory(user.getInt("id"), pageNum, 10);
        setAttr("page", page);
        render("history.html");
    }

    // 删除历史记录
    public void delete() {
        User user = getSessionAttr("loginUser");
        int id = getParaToInt("id");
        GameService.me.deleteHistory(id, user.getInt("id"));
        redirect("/game/history");
    }
}
