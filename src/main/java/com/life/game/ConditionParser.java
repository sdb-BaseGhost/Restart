package com.life.game;

import java.util.*;

/**
 * 条件表达式解析器
 * 支持语法：PROP>10, PROP>=5, PROP<3, PROP<=1, PROP=0, PROP!=0
 *           PROP?[1,2,3]（包含）, PROP![1,2,3]（不包含）
 *           EVT?[10000]（事件历史包含）, TLT?[1048]（天赋包含）
 *           & (AND), | (OR), () 分组
 */
public class ConditionParser {

    private String expr;
    private int pos;

    /**
     * 评估条件表达式
     * @param condition 条件字符串，null 或空返回 true
     * @param props 属性键值对（标量属性）
     * @return 条件是否满足
     */
    public static boolean evaluate(String condition, Map<String, Integer> props) {
        return evaluate(condition, props, null);
    }

    /**
     * 评估条件表达式（支持集合属性）
     * @param condition 条件字符串，null 或空返回 true
     * @param props 属性键值对（标量属性）
     * @param setProps 集合属性键值对（EVT=已触发事件ID集合, TLT=已选天赋ID集合）
     * @return 条件是否满足
     */
    public static boolean evaluate(String condition, Map<String, Integer> props, Map<String, Set<Integer>> setProps) {
        if (condition == null || condition.trim().isEmpty()) {
            return true;
        }
        ConditionParser parser = new ConditionParser();
        parser.expr = condition.trim();
        parser.pos = 0;
        boolean result = parser.parseOr(props, setProps);
        return result;
    }

    // orExpr = andExpr ( '|' andExpr )*
    private boolean parseOr(Map<String, Integer> props, Map<String, Set<Integer>> setProps) {
        boolean left = parseAnd(props, setProps);
        while (pos < expr.length() && current() == '|') {
            pos++; // skip '|'
            boolean right = parseAnd(props, setProps);
            left = left || right;
        }
        return left;
    }

    // andExpr = atom ( '&' atom )*
    private boolean parseAnd(Map<String, Integer> props, Map<String, Set<Integer>> setProps) {
        boolean left = parseAtom(props, setProps);
        while (pos < expr.length() && current() == '&') {
            pos++; // skip '&'
            boolean right = parseAtom(props, setProps);
            left = left && right;
        }
        return left;
    }

    // atom = '(' orExpr ')' | comparison
    private boolean parseAtom(Map<String, Integer> props, Map<String, Set<Integer>> setProps) {
        skipSpaces();
        if (pos < expr.length() && current() == '(') {
            pos++; // skip '('
            boolean result = parseOr(props, setProps);
            skipSpaces();
            if (pos < expr.length() && current() == ')') {
                pos++; // skip ')'
            }
            return result;
        }
        return parseComparison(props, setProps);
    }

    // comparison = PROP OP VALUE | PROP '?' '[' LIST ']' | PROP '!' '[' LIST ']'
    private boolean parseComparison(Map<String, Integer> props, Map<String, Set<Integer>> setProps) {
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

            // Set-based properties (EVT, TLT): check if any value in list is in the set
            if (setProps != null && setProps.containsKey(prop)) {
                Set<Integer> set = setProps.get(prop);
                boolean found = false;
                for (int id : list) {
                    if (set.contains(id)) {
                        found = true;
                        break;
                    }
                }
                return isContains ? found : !found;
            }

            // Scalar properties: check if the scalar value is in the list
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
