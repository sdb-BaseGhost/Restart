package com.life.game;

import java.util.*;

/**
 * 条件表达式解析器
 * 支持语法：PROP>10, PROP>=5, PROP<3, PROP<=1, PROP=0, PROP!=0
 *           PROP?[1,2,3]（包含）, PROP![1,2,3]（不包含）
 *           & (AND), | (OR), () 分组
 */
public class ConditionParser {

    private String expr;
    private int pos;

    /**
     * 评估条件表达式
     * @param condition 条件字符串，null 或空返回 true
     * @param props 属性键值对
     * @return 条件是否满足
     */
    public static boolean evaluate(String condition, Map<String, Integer> props) {
        if (condition == null || condition.trim().isEmpty()) {
            return true;
        }
        ConditionParser parser = new ConditionParser();
        parser.expr = condition.trim();
        parser.pos = 0;
        boolean result = parser.parseOr(props);
        return result;
    }

    // orExpr = andExpr ( '|' andExpr )*
    private boolean parseOr(Map<String, Integer> props) {
        boolean left = parseAnd(props);
        while (pos < expr.length() && current() == '|') {
            pos++; // skip '|'
            boolean right = parseAnd(props);
            left = left || right;
        }
        return left;
    }

    // andExpr = atom ( '&' atom )*
    private boolean parseAnd(Map<String, Integer> props) {
        boolean left = parseAtom(props);
        while (pos < expr.length() && current() == '&') {
            pos++; // skip '&'
            boolean right = parseAtom(props);
            left = left && right;
        }
        return left;
    }

    // atom = '(' orExpr ')' | comparison
    private boolean parseAtom(Map<String, Integer> props) {
        skipSpaces();
        if (pos < expr.length() && current() == '(') {
            pos++; // skip '('
            boolean result = parseOr(props);
            skipSpaces();
            if (pos < expr.length() && current() == ')') {
                pos++; // skip ')'
            }
            return result;
        }
        return parseComparison(props);
    }

    // comparison = PROP OP VALUE | PROP '?' '[' LIST ']' | PROP '!' '[' LIST ']'
    private boolean parseComparison(Map<String, Integer> props) {
        skipSpaces();
        String prop = parsePropName();
        skipSpaces();

        if (pos >= expr.length()) {
            return props.getOrDefault(prop, 0) != 0;
        }

        char c = current();

        // Array operations: ?[...] or ![
        // Must check that '!' is followed by '[' (not '!=')
        if (c == '?' || (c == '!' && pos + 1 < expr.length() && expr.charAt(pos + 1) == '[')) {
            boolean isContains = (c == '?');
            pos++; // skip '?' or '!'
            skipSpaces();
            List<Integer> list = parseValueList();
            int val = props.getOrDefault(prop, 0);
            boolean inList = list.contains(val);
            return isContains ? inList : !inList;
        }

        // Comparison operations
        String op = parseOperator();
        skipSpaces();
        int value = parseNumber();

        int propVal = props.getOrDefault(prop, 0);
        switch (op) {
            case ">":  return propVal > value;
            case "<":  return propVal < value;
            case ">=": return propVal >= value;
            case "<=": return propVal <= value;
            case "=":  return propVal == value;
            case "!=": return propVal != value;
            default:   return false;
        }
    }

    private String parsePropName() {
        int start = pos;
        while (pos < expr.length() && (Character.isUpperCase(expr.charAt(pos)) || expr.charAt(pos) == '_')) {
            pos++;
        }
        return expr.substring(start, pos);
    }

    private String parseOperator() {
        if (pos + 1 < expr.length()) {
            String two = expr.substring(pos, pos + 2);
            if (two.equals(">=") || two.equals("<=") || two.equals("!=")) {
                pos += 2;
                return two;
            }
        }
        if (pos < expr.length()) {
            char c = current();
            if (c == '>' || c == '<' || c == '=') {
                pos++;
                return String.valueOf(c);
            }
        }
        return "";
    }

    private int parseNumber() {
        int start = pos;
        if (pos < expr.length() && (current() == '-' || current() == '+')) {
            pos++;
        }
        while (pos < expr.length() && Character.isDigit(expr.charAt(pos))) {
            pos++;
        }
        return Integer.parseInt(expr.substring(start, pos));
    }

    private List<Integer> parseValueList() {
        List<Integer> list = new ArrayList<>();
        skipSpaces();
        if (pos < expr.length() && current() == '[') {
            pos++; // skip '['
            while (pos < expr.length() && current() != ']') {
                skipSpaces();
                if (current() == ']') break;
                if (current() == ',') {
                    pos++;
                    continue;
                }
                list.add(parseNumber());
                skipSpaces();
            }
            if (pos < expr.length() && current() == ']') {
                pos++; // skip ']'
            }
        }
        return list;
    }

    private char current() {
        return expr.charAt(pos);
    }

    private void skipSpaces() {
        while (pos < expr.length() && expr.charAt(pos) == ' ') {
            pos++;
        }
    }
}
