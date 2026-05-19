package com.life.validator;

import com.jfinal.core.Controller;
import com.jfinal.validate.Validator;

public class GameValidator extends Validator {
    @Override
    protected void validate(Controller c) {
        // 验证属性分配：总点数 = 20，每项 >= 0
        String[] attrs = {"intelligence", "appearance", "constitution", "family", "luck"};
        int total = 0;
        for (String attr : attrs) {
            String val = c.getPara(attr);
            if (val == null || val.isEmpty()) {
                addError("errMsg", "属性 " + attr + " 不能为空");
                return;
            }
            try {
                int v = Integer.parseInt(val);
                if (v < 0) {
                    addError("errMsg", "属性值不能为负数");
                    return;
                }
                total += v;
            } catch (NumberFormatException e) {
                addError("errMsg", "属性值必须为数字");
                return;
            }
        }
        if (total != 20) {
            addError("errMsg", "属性总点数必须为 20（当前：" + total + "）");
            return;
        }

        // 验证天赋选择：必须 3 个
        String[] talents = c.getParaValues("talents");
        if (talents == null || talents.length != 3) {
            addError("errMsg", "必须选择 3 个天赋");
        }
    }

    @Override
    protected void handleError(Controller c) {
        c.setAttr("errMsg", c.getAttr("errMsg"));
        c.render("start.html");
    }
}
