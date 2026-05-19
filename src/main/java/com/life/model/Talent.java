package com.life.model;

import com.jfinal.plugin.activerecord.Model;

/**
 * Talent model - maps to `talent` table.
 * Fields: id, name, description, effects
 */
public class Talent extends Model<Talent> {

    public static final Talent dao = new Talent().dao();
}
