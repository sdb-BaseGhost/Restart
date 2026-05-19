package com.life.game;

import org.junit.jupiter.api.Test;
import java.util.HashMap;
import java.util.Map;
import static org.junit.jupiter.api.Assertions.*;

class ConditionParserTest {

    private Map<String, Integer> props(int chr, int intel, int strn, int mny, int spr, int lif, int age) {
        Map<String, Integer> map = new HashMap<>();
        map.put("CHR", chr);
        map.put("INT", intel);
        map.put("STR", strn);
        map.put("MNY", mny);
        map.put("SPR", spr);
        map.put("LIF", lif);
        map.put("AGE", age);
        return map;
    }

    @Test
    void testNullAndEmpty() {
        Map<String, Integer> p = props(10, 20, 30, 40, 50, 1, 25);
        assertTrue(ConditionParser.evaluate(null, p));
        assertTrue(ConditionParser.evaluate("", p));
        assertTrue(ConditionParser.evaluate("  ", p));
    }

    @Test
    void testSimpleComparison() {
        Map<String, Integer> p = props(10, 20, 30, 40, 50, 1, 25);
        assertTrue(ConditionParser.evaluate("INT>15", p));
        assertFalse(ConditionParser.evaluate("INT>25", p));
        assertTrue(ConditionParser.evaluate("INT>=20", p));
        assertTrue(ConditionParser.evaluate("INT<25", p));
        assertFalse(ConditionParser.evaluate("INT<15", p));
        assertTrue(ConditionParser.evaluate("INT<=20", p));
        assertTrue(ConditionParser.evaluate("INT=20", p));
        assertFalse(ConditionParser.evaluate("INT=30", p));
        assertTrue(ConditionParser.evaluate("INT!=30", p));
        assertFalse(ConditionParser.evaluate("INT!=20", p));
    }

    @Test
    void testNegativeValue() {
        Map<String, Integer> p = props(10, -5, 30, 40, 50, 1, 25);
        assertTrue(ConditionParser.evaluate("INT<0", p));
        assertFalse(ConditionParser.evaluate("INT>0", p));
    }

    @Test
    void testArrayContains() {
        Map<String, Integer> p = props(10, 20, 30, 40, 50, 1, 25);
        assertTrue(ConditionParser.evaluate("INT?[10,20,30]", p));
        assertFalse(ConditionParser.evaluate("INT?[10,30]", p));
        assertTrue(ConditionParser.evaluate("INT![10,30]", p));
        assertFalse(ConditionParser.evaluate("INT![10,20,30]", p));
    }

    @Test
    void testAndOperator() {
        Map<String, Integer> p = props(10, 20, 30, 40, 50, 1, 25);
        assertTrue(ConditionParser.evaluate("INT>15&STR>25", p));
        assertFalse(ConditionParser.evaluate("INT>25&STR>25", p));
        assertFalse(ConditionParser.evaluate("INT>15&STR>35", p));
    }

    @Test
    void testOrOperator() {
        Map<String, Integer> p = props(10, 20, 30, 40, 50, 1, 25);
        assertTrue(ConditionParser.evaluate("INT>25|STR>25", p));
        assertTrue(ConditionParser.evaluate("INT>15|STR>35", p));
        assertFalse(ConditionParser.evaluate("INT>25|STR>35", p));
    }

    @Test
    void testParentheses() {
        Map<String, Integer> p = props(10, 20, 30, 40, 50, 1, 25);
        assertTrue(ConditionParser.evaluate("(INT>25|STR>25)&CHR>5", p));
        assertFalse(ConditionParser.evaluate("(INT>25|STR>35)&CHR>5", p));
        assertTrue(ConditionParser.evaluate("(INT>25|STR>25)|(CHR>5&MNY>35)", p));
    }

    @Test
    void testComplexExpression() {
        Map<String, Integer> p = props(10, 20, 30, 40, 50, 1, 25);
        assertTrue(ConditionParser.evaluate("INT>15&STR>25|CHR>5", p));
        assertTrue(ConditionParser.evaluate("INT>15&(STR>25|CHR>5)", p));
    }

    @Test
    void testPropertyLIF() {
        Map<String, Integer> p = props(10, 20, 30, 40, 50, 0, 25);
        assertTrue(ConditionParser.evaluate("LIF=0", p));
        assertFalse(ConditionParser.evaluate("LIF=1", p));
    }

    @Test
    void testPropertyAGE() {
        Map<String, Integer> p = props(10, 20, 30, 40, 50, 1, 80);
        assertTrue(ConditionParser.evaluate("AGE>=80", p));
        assertFalse(ConditionParser.evaluate("AGE>=90", p));
    }
}
