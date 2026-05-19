package com.life.model;

import com.jfinal.plugin.activerecord.Model;

/**
 * GameResult model - maps to `game_result` table.
 * Fields: id, user_id, final_age, wealth, health, happiness, social, achievement, ending_name, talents, create_time
 */
public class GameResult extends Model<GameResult> {

    public static final GameResult dao = new GameResult().dao();
}
