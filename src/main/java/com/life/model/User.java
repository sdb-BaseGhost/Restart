package com.life.model;

import com.jfinal.plugin.activerecord.Model;

/**
 * User model - maps to `user` table.
 * Fields: id, username, password, nickname, create_time
 */
public class User extends Model<User> {

    public static final User dao = new User().dao();
}
