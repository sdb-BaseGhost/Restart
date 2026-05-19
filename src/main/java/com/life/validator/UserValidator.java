package com.life.validator;

import com.jfinal.core.Controller;
import com.jfinal.validate.Validator;

public class UserValidator extends Validator {
    @Override
    protected void validate(Controller c) {
        String actionKey = getActionKey();

        if (actionKey.equals("/user/doRegister")) {
            // 注册验证
            validateString("username", 3, 20, "errMsg", "用户名长度 3-20 位");
            validateString("password", 6, 20, "errMsg", "密码长度 6-20 位");
            validateString("nickname", 1, 50, "errMsg", "昵称不能为空");
        } else if (actionKey.equals("/user/doLogin")) {
            // 登录验证
            validateRequired("username", "errMsg", "用户名不能为空");
            validateRequired("password", "errMsg", "密码不能为空");
        }
    }

    @Override
    protected void handleError(Controller c) {
        // 将错误信息设置到请求属性中，供页面展示
        c.setAttr("errMsg", c.getAttr("errMsg"));
        if (getActionKey().equals("/user/doRegister")) {
            c.render("register.html");
        } else {
            c.render("login.html");
        }
    }
}
