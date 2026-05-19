package com.life.controller;

import com.jfinal.core.Controller;
import com.jfinal.core.Path;
import com.life.service.RankService;

@Path("/")
public class IndexController extends Controller {

    public void index() {
        // 将 session 中的用户传给模板
        setAttr("loginUser", getSessionAttr("loginUser"));
        // 获取排行榜数据
        setAttr("achievementRank", RankService.me.getTopAchievement(10));
        setAttr("wealthRank", RankService.me.getTopWealth(10));
        setAttr("ageRank", RankService.me.getTopAge(10));
        render("index.html");
    }
}
