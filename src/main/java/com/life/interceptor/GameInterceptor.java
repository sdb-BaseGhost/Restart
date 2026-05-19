package com.life.interceptor;

import com.jfinal.aop.Interceptor;
import com.jfinal.aop.Invocation;
import com.jfinal.core.Controller;
import com.life.game.GameState;

public class GameInterceptor implements Interceptor {
    @Override
    public void intercept(Invocation inv) {
        Controller c = inv.getController();
        String actionKey = inv.getActionKey();

        // 只拦截游戏进行中的页面
        if (actionKey.equals("/game/playing") || actionKey.equals("/game/nextYear")) {
            GameState state = c.getSessionAttr("gameState");
            if (state == null || state.isGameOver()) {
                c.redirect("/game/start");
                return;
            }
        }

        inv.invoke();
    }
}
