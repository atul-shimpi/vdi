package com.gdev.telnet.utils;

import com.gdev.telnet.utils.Constant;

public class GevUtils {

    public static String toHtmlString(String str) {
        if (str == null || ("").equals(str.trim())) {
            return "";
        }
        StringBuffer stringbuffer = new StringBuffer();
        int j = str.length();
        for (int i = 0; i < j; i++) {
            char c = str.charAt(i);
            switch (c) {
                case 39:
                    stringbuffer.append("");
                    break;
                default:
                    stringbuffer.append(c);
                    break;
            }
        }
        return new String(stringbuffer.toString());
    }

    public String getOsType(String OsType) {
        String result = OsType.contains(Constant.GEV_OS_WIN) ? Constant.GEV_OS_WIN
                : Constant.GEV_OS_LINUX;
        return result;
    }
    
    /**
     * read the command result
     */
    public String readContent(String str, String commandStr) {
        int index = commandStr.length();
        int lastIndex = str.lastIndexOf("[");
        String result = str.substring(index + 1, lastIndex).trim();
        return result;
    }
}
