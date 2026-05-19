package com.life.controller;

import com.jfinal.aop.Before;
import com.jfinal.core.Controller;
import com.jfinal.core.Path;
import com.life.model.User;
import com.life.service.UserService;
import com.life.validator.UserValidator;

@Path("/user")
public class UserController extends Controller {

    // 登录页面 GET
    public void login() {
        render("login.html");
    }

    // 登录提交 POST - 带验证器
    @Before(UserValidator.class)
    public void doLogin() {
        String username = getPara("username");
        String password = getPara("password");
        User user = UserService.me.login(username, password);
        if (user != null) {
            setSessionAttr("loginUser", user);
            redirect("/");
        } else {
            setAttr("errMsg", "用户名或密码错误");
            render("login.html");
        }
    }

    // 注册页面 GET
    public void register() {
        render("register.html");
    }

    // 注册提交 POST
    @Before(UserValidator.class)
    public void doRegister() {
        String username = getPara("username");
        String password = getPara("password");
        String nickname = getPara("nickname");
        boolean success = UserService.me.register(username, password, nickname);
        if (success) {
            redirect("/user/login");
        } else {
            setAttr("errMsg", "用户名已存在");
            render("register.html");
        }
    }

    // 退出登录
    public void logout() {
        removeSessionAttr("loginUser");
        redirect("/user/login");
    }

    // 个人信息页面
    public void profile() {
        User user = getSessionAttr("loginUser");
        setAttr("loginUser", user);
        setAttr("user", user);
        render("profile.html");
    }

    // 修改昵称
    public void update() {
        User user = getSessionAttr("loginUser");
        String nickname = getPara("nickname");
        if (nickname != null && !nickname.trim().isEmpty()) {
            UserService.me.updateNickname(user.getInt("id"), nickname);
            user.set("nickname", nickname);
            setSessionAttr("loginUser", user);
            setAttr("success", "昵称修改成功");
        }
        setAttr("loginUser", user);
        setAttr("user", user);
        render("profile.html");
    }

    // 注销账号
    public void deleteAccount() {
        User user = getSessionAttr("loginUser");
        if (user != null) {
            UserService.me.deleteAccount(user.getInt("id"));
            removeSessionAttr("loginUser");
        }
        redirect("/user/login");
    }
}
