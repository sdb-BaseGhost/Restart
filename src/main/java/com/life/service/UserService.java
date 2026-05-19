package com.life.service;

import com.jfinal.kit.HashKit;
import com.jfinal.plugin.activerecord.Db;
import com.life.model.GameResult;
import com.life.model.User;

import java.util.Date;

public class UserService {
    public static final UserService me = new UserService();

    /**
     * 注册：检查用户名是否存在，MD5 加密密码，创建用户
     */
    public boolean register(String username, String password, String nickname) {
        User existing = User.dao.findFirst("SELECT id FROM user WHERE username = ?", username);
        if (existing != null) {
            return false;
        }

        User user = new User();
        user.set("username", username);
        user.set("password", HashKit.md5(password));
        user.set("nickname", nickname);
        user.set("create_time", new Date());
        user.save();
        return true;
    }

    /**
     * 登录：验证用户名密码，返回 User 对象或 null
     */
    public User login(String username, String password) {
        return User.dao.findFirst("SELECT * FROM user WHERE username = ? AND password = ?",
                username, HashKit.md5(password));
    }

    /**
     * 修改昵称
     */
    public boolean updateNickname(int userId, String nickname) {
        User user = User.dao.findById(userId);
        if (user == null) {
            return false;
        }
        user.set("nickname", nickname);
        return user.update();
    }

    /**
     * 修改密码
     */
    public boolean updatePassword(int userId, String oldPwd, String newPwd) {
        User user = User.dao.findById(userId);
        if (user == null) {
            return false;
        }
        if (!user.getStr("password").equals(HashKit.md5(oldPwd))) {
            return false;
        }
        user.set("password", HashKit.md5(newPwd));
        return user.update();
    }

    /**
     * 注销账号：先删除游戏记录，再删除用户
     */
    public boolean deleteAccount(int userId) {
        Db.delete("DELETE FROM game_result WHERE user_id = ?", userId);
        return User.dao.deleteById(userId);
    }
}
