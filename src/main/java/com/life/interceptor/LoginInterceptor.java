package com.life.interceptor;

import com.jfinal.aop.Interceptor;
import com.jfinal.aop.Invocation;
import com.jfinal.core.Controller;

public class LoginInterceptor implements Interceptor {
    @Override
    public void intercept(Invocation inv) {
        Controller c = inv.getController();
        String actionKey = inv.getActionKey();

        // 未登录可访问的路径（登录、注册、首页）
        if (actionKey.equals("/user/login") ||
            actionKey.equals("/user/doLogin") ||
            actionKey.equals("/user/register") ||
            actionKey.equals("/user/doRegister") ||
            actionKey.equals("/") ||
            actionKey.equals("/index")) {
            inv.invoke();
            return;
        }

        // 其他路径需要登录
        Object loginUser = c.getSessionAttr("loginUser");
        if (loginUser == null) {
            c.redirect("/user/login");
            return;
        }

        inv.invoke();
    }
}
