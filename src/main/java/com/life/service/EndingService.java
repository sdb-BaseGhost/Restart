package com.life.service;

import com.life.model.Ending;

import java.util.List;

public class EndingService {
    public static final EndingService me = new EndingService();

    /**
     * 获取结局描述
     */
    public String getEndingDescription(String endingName) {
        List<Ending> endings = CacheService.me.getAllEndings();
        for (Ending e : endings) {
            if (e.getStr("name").equals(endingName)) {
                return e.getStr("description");
            }
        }
        return "一段平凡的人生。";
    }
}
