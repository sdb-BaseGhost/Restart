package com.life.config;

import com.jfinal.config.*;
import com.jfinal.plugin.activerecord.ActiveRecordPlugin;
import com.jfinal.plugin.druid.DruidPlugin;
import com.jfinal.template.Engine;
import com.life.model.*;
import com.life.interceptor.LoginInterceptor;
import com.life.controller.*;
import com.life.service.CacheService;
import com.life.service.RedisManager;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

/**
 * JFinal 全局配置类
 */
public class LifeConfig extends JFinalConfig {

    @Override
    public void configConstant(Constants me) {
        me.setDevMode(true);
        me.setEncoding("UTF-8");
    }

    @Override
    public void configRoute(Routes me) {
        me.add("/", IndexController.class);
        me.add("/user", UserController.class);
        me.add("/game", GameController.class);
    }

    @Override
    public void configEngine(Engine me) {
        me.setBaseTemplatePath("src/main/webapp/WEB-INF/view/");
    }

    @Override
    public void configPlugin(Plugins me) {
        // MySQL + Druid
        DruidPlugin druidPlugin = new DruidPlugin(
                "jdbc:mysql://localhost:3306/life_restart?characterEncoding=utf8&serverTimezone=Asia/Shanghai",
                "root", "1234",
                "com.mysql.cj.jdbc.Driver"
        );
        me.add(druidPlugin);

        ActiveRecordPlugin arp = new ActiveRecordPlugin(druidPlugin);
        arp.addMapping("user", User.class);
        arp.addMapping("game_result", GameResult.class);
        arp.addMapping("event", Event.class);
        arp.addMapping("talent", Talent.class);
        arp.addMapping("ending", Ending.class);
        me.add(arp);

        // Redis - 使用 JedisPool
        JedisPoolConfig poolConfig = new JedisPoolConfig();
        poolConfig.setMaxTotal(20);
        JedisPool jedisPool = new JedisPool(poolConfig, "localhost", 6379);
        RedisManager.init(jedisPool);
    }

    @Override
    public void configInterceptor(Interceptors me) {
        me.add(new LoginInterceptor());
    }

    @Override
    public void configHandler(Handlers me) {
    }

    @Override
    public void afterJFinalStart() {
        CacheService.me.init();
    }
}
