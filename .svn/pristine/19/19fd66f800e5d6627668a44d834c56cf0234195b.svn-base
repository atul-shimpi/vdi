package com.gdev.telnet;

import java.io.InputStream;
import java.io.PrintStream;

import org.apache.commons.net.telnet.TelnetClient;

import com.gdev.telnet.bean.Command;

/**
 * this until for Linux
 */
public class TelnetLinux {
    private TelnetClient telnet = new TelnetClient("VT220");
    private InputStream in;
    private PrintStream out;
    private static final String DEFAULT_AIX_PROMPT = "#";
    private String outFile = "stdout";
    private String errFile = "stderr";
    private String port;
    private String user;
    private String readCommand = "cat";
    private String password;
    private String ip;
    private String loginName ="login: ";
    private String psWord ="Password: ";
    private static final int DEFAULT_TELNET_PORT = 23;

    public TelnetLinux(String ip, String user, String password) {
        this.ip = ip;
        this.port = String.valueOf(TelnetLinux.DEFAULT_TELNET_PORT);
        this.user = user;
        this.password = password;
    }

    public TelnetLinux(String ip, String port, String user, String password) {
        this.ip = ip;
        this.port = port;
        this.user = user;
        this.password = password;
    }

    /**
     * @return boolean
     * use telnet connect server
     */
    public boolean connect() {
        boolean isConnect = true;
        try {
            telnet.connect(ip, Integer.parseInt("23"));
            in = telnet.getInputStream();
            out = new PrintStream(telnet.getOutputStream());

            /** Log the user on* */
            readUntil(loginName);
            write(user);

            readUntil(psWord);
            write(password);

            /** Advance to a prompt */
            readUntil(DEFAULT_AIX_PROMPT);

        } catch (Exception e) {
            isConnect = false;
            e.printStackTrace();
            return isConnect;
        }
        return isConnect;
    }
    
    
    public String readUntil(String pattern) {
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

    public void write(String value) {
        try {
            out.println(value);
            out.flush();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * sent command to server,result should create 2 file,
     * stdout and stderr
     */
    public String sendCommand(String command) {
        try {
            write(command + " 1>" + outFile + " 2>" + errFile);
            return readUntil(DEFAULT_AIX_PROMPT);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * sent command to server,
     */
    public String sendSimpleCommand(String command) {
        try {
            write(command);
            return readUntil(DEFAULT_AIX_PROMPT);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void disconnect() {
        try {
            telnet.disconnect();
        } catch (Exception e) {
            e.printStackTrace();
        }
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

    /**
     * get the command result Object
     */
    public Command getCommandResult() {
        Command commandObject = new Command();
        String command = readCommand + " " + errFile;
        String result = readContent(this.sendSimpleCommand(command), command);
        boolean resultFlag = false;
        if (result.length() == 0) {
            resultFlag = true;
            command = readCommand + " " + outFile;
            result = readContent(this.sendSimpleCommand(command), command);
        }
        commandObject.setResult(resultFlag);
        commandObject.setReturnStr(result);
        this.sendSimpleCommand("rm " + errFile);
        this.sendSimpleCommand("rm " + outFile);
        return commandObject;
    }

}
