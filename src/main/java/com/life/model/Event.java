package com.life.model;

import com.jfinal.plugin.activerecord.Model;

/**
 * Event model - maps to `event` table.
 * Fields: id, name, description, min_age, max_age, rarity, type, effects, weight
 */
public class Event extends Model<Event> {

    public static final Event dao = new Event().dao();
}
