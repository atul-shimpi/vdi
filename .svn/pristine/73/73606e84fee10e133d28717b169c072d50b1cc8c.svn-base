package com.gdev.telnet;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.net.SocketException;

import org.apache.commons.net.telnet.TelnetClient;

public class TelnetWin {
    private String ip;
    private int port = 23;
    private String username;
    private String password;
    private TelnetClient telnet = new TelnetClient("VT220");
    private String endStingOne = "The system cannot find the file specified.";
    private String endStingTwo = "Error occurred while processing: #.";
    private String commandEndKey = ">";
    private String outFile = "stdout";
    private String errFile = "stderr";
    private String readFileCommand = "type";
    private String readFileCommandFlag = "#";
    private String readFileCommandEndFlag = "#.";
    private String loginLine = "login: ";
    private String passwordLine = "password: ";

    public TelnetWin(String ip, String username, String password) {
        this.ip = ip;
        this.username = username;
        this.password = password;
    }

    public void disConnect() {
        try {
            telnet.disconnect();
        } catch (IOException e) {
            System.out.println(e.getMessage());
        }
    }

    public void setCommant(String command) {
        PrintStream out = new PrintStream(telnet.getOutputStream());
        write(command + " 1>" + outFile + " 2>" + errFile + "", out);
        readUntil(commandEndKey, telnet.getInputStream());
    }

    private String getResult(String filename) {
        PrintStream out = new PrintStream(telnet.getOutputStream());
        String command = readFileCommand + " " + filename + " "
                + readFileCommandFlag;
        write(command, out);
        String result = readUntil(readFileCommandEndFlag, telnet
                .getInputStream());
        result = subCommandString(command, result);
        return result;
    }

    public String getOutResult() {
        return getResult(outFile);
    }

    public String getErrResult() {
        return getResult(errFile);
    }

    private String subCommandString(String command, String str) {
        str = str.substring(str.lastIndexOf(command), str.length());
        str = str.substring(command.length(), str.length());
        str = str.substring(0, str.indexOf(endStingTwo));
        str = str.substring(0, str.indexOf(endStingOne));
        return str.trim();
    }

    public boolean connect() {
        InputStream in;
        PrintStream out;
        boolean result = false;
        try {
            telnet.connect(ip, port);
            in = telnet.getInputStream();
            out = new PrintStream(telnet.getOutputStream());
            readUntil(loginLine, in);
            write(username, out);
            readUntil(passwordLine, in);
            write(password, out);
            readUntil(commandEndKey, in);
            result = true;
        } catch (SocketException e) {
            System.out.println(e.getMessage());
        } catch (IOException e) {
            System.out.println(e.getMessage());
        }
        return result;
    }

    public String readUntil(String pattern, InputStream in) {
        try {
            char lastChar = pattern.charAt(pattern.length() - 1);
            StringBuffer sb = new StringBuffer();
            char ch = (char) in.read();
            while (true) {
                sb.append(ch);
                if (ch == lastChar) {
                    if (sb.toString().endsWith(pattern)) {
                        return sb.toString();
                    }
                }
                ch = (char) in.read();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void write(String value, PrintStream out) {
        try {
            out.println(value);
            out.flush();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
