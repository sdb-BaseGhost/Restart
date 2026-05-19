package com.life.model;

import com.jfinal.plugin.activerecord.Model;

/**
 * AgeEvent model - maps to `age_event` table.
 * Fields: id, age, event_id
 */
public class AgeEvent extends Model<AgeEvent> {

    public static final AgeEvent dao = new AgeEvent().dao();
}
