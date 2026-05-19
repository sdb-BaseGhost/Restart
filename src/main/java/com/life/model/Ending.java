package com.life.model;

import com.jfinal.plugin.activerecord.Model;

/**
 * Ending model - maps to `ending` table.
 * Fields: id, name, description, condition_type, condition_value, priority
 */
public class Ending extends Model<Ending> {

    public static final Ending dao = new Ending().dao();
}
