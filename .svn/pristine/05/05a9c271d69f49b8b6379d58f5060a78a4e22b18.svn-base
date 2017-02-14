package com.gdev.telnet.thread;

import java.util.ArrayList;
import java.util.List;

import com.gdev.telnet.TelnetLinux;
import com.gdev.telnet.TelnetWin;
import com.gdev.telnet.bean.Command;
import com.gdev.telnet.bean.VdiJob;
import com.gdev.telnet.db.DbcpConnect;
import com.gdev.telnet.utils.GevUtils;

public class CallTask implements Runnable {
    private VdiJob vdiJob;

    private String win = "win";

    private String linux = "linux";

    private String noRun = "This commond is not runned";

    private String driveMiss = "cannot find the drive specified";

    private String runSuccessful = "This commond run successful";
    
    private GevUtils gevUtils;
    
    private String[] symbol = new String[]{"c","c:","c:/",":"};
    
    private String cmdBack = "cd..";
    
    private String cd = "cd ";

    public CallTask(VdiJob vdiJob) {
        this.vdiJob = vdiJob;
    }

    private String getOsType() {
        String result = vdiJob.getOsType().contains(win) ? win : linux;
        return result;
    }

    public void run() {
        DbcpConnect dbcpConnect = new DbcpConnect(vdiJob.getDbName(), vdiJob
                .getDbPassword(), vdiJob.getDbIp(), vdiJob.getDbUser());

        List<VdiJob> vdiJobList = getListById(dbcpConnect);

        updateToRun(dbcpConnect, vdiJobList);
        boolean flag = true;
        for (VdiJob job : vdiJobList) {
            String id = job.getId();
            String cmmond = job.getCommand();
            String commandPath = job.getCommandPath();
            Command commandObject = new Command();
            ;
            if (!flag) {
                updateUnRun(id, dbcpConnect);
                continue;
            }
            if (win.endsWith(getOsType())) {
                commandObject = winService(cmmond, commandPath);
            } else {
                commandObject = linuxService(cmmond, commandPath);
                
            }
            if (commandObject.getResult()) {

                dbcpConnect.updateById(id, commandObject.getReturnStr());
            } else {
                flag = false;
                System.out.println("3333333333333");
                String faileMessage=gevUtils.toHtmlString(commandObject.getReturnStr());
                dbcpConnect.updateFailById(id,faileMessage );
            }
        }
    }

    private void updateUnRun(String id, DbcpConnect dbcpConnect) {
        Command commandObject = new Command();
        commandObject.setResult(false);
        commandObject.setReturnStr(noRun);
        dbcpConnect.updateFailById(id, commandObject.getReturnStr());
    }

    private void winCD(String commandPath, TelnetWin telnetWin) {
        if (commandPath.length() < 4
                && (commandPath.toLowerCase().indexOf(symbol[1]) == symbol[1].length() - 1
                        || commandPath.toLowerCase().indexOf(symbol[2]) == symbol[2]
                                .length() - 1 || commandPath.toLowerCase()
                        .indexOf(symbol[0]) == symbol[0].length() - 1)) {
            telnetWin.setCommant(cmdBack);
            telnetWin.setCommant(cmdBack);
        } else if (commandPath.toLowerCase().indexOf(symbol[0]) == 0) {
            telnetWin.setCommant(cd + commandPath);
        } else {
            String drive = "";
            if (commandPath.length() > 1) {
                drive = commandPath.substring(0, commandPath.indexOf(symbol[3]));
            }
            telnetWin.setCommant(drive + symbol[3]);
            telnetWin.setCommant(cd + commandPath);
        }
    }

    private boolean checkCommandPath(String commandPath, TelnetWin telnetWin) {
        String drive = "";
        if (commandPath.length() > 1) {
            drive = commandPath.substring(0, commandPath.indexOf(symbol[3]));
        }
        telnetWin.setCommant(drive + symbol[3]);
        String error = telnetWin.getErrResult();
        if (error.length() == 0) {
            return true;
        } else {
            return false;
        }
    }

    private Command winService(String command, String commandPath) {
        Command commandObject = new Command();
        TelnetWin telnetWin = new TelnetWin(vdiJob.getIp(), vdiJob.getUser(),
                vdiJob.getPassword());
        telnetWin.connect();
        winCD(commandPath, telnetWin);
        System.out.println("  running command is   : " + command);
        telnetWin.setCommant(command);
        String out = telnetWin.getOutResult();
        String err = telnetWin.getErrResult();
        if (checkCommandPath(commandPath, telnetWin)) {
            if (err.length() == 0) {
                if (out.length() == 0) {
                    out = runSuccessful;
                }
                commandObject.setResult(true);
                commandObject.setReturnStr(out);
            } else {
                commandObject.setResult(false);
                commandObject.setReturnStr(err);
            }
        } else {
            commandObject.setResult(false);
            commandObject.setReturnStr(driveMiss);
        }
        telnetWin.disConnect();
        return commandObject;
    }

    private Command linuxService(String command, String commandPath) {
        Command commandObject = new Command();
        TelnetLinux telnetLinux = new TelnetLinux(vdiJob.getIp(), vdiJob
                .getUser(), vdiJob.getPassword());
        System.out.println(vdiJob.getIp());
        System.out.println(vdiJob.getUser());
        System.out.println(vdiJob.getPassword());
        
        telnetLinux.connect();
        telnetLinux.sendSimpleCommand(cd + commandPath);
        System.out.println(cd + commandPath);
        telnetLinux.sendCommand(command);
        commandObject = telnetLinux.getCommandResult();

        telnetLinux.disconnect();
        return commandObject;
    }

    private List<VdiJob> getListById(DbcpConnect dbcpConnect) {
        List<VdiJob> vdiJobList = new ArrayList<VdiJob>();
        vdiJobList = dbcpConnect.findById(vdiJob.getJobId());
        return vdiJobList;
    }

    private void updateToRun(DbcpConnect dbcpConnect, List<VdiJob> vdiJobList) {
        for (VdiJob vdiJob : vdiJobList) {
            String id = vdiJob.getId();
            // set all result status is 'run'
            dbcpConnect.updateStateById(id);
        }
    }

    // public void run() {
    // DbcpConnect dt = new DbcpConnect(vdiJob.getDbName(), vdiJob
    // .getDbPassword(), vdiJob.getDbIp(), vdiJob.getDbUser());
    // List<VdiJob> vdiJobList = new ArrayList<VdiJob>();
    // vdiJobList = dt.findById(vdiJob.getJobId());
    // String flag = "1";
    // Command command = new Command();
    // TelnetWindows telnetUtils = new TelnetWindows();
    // if (vdiJobList == null || vdiJobList.size() == 0) {
    // System.out.print("No job ....");
    // }
    // int len = vdiJobList.size();
    // for (int i = 0; i < len; i++) {
    // VdiJob vdiJob = new VdiJob();
    // vdiJob = vdiJobList.get(i);
    // String id = vdiJob.getId();
    // // set all result status is 'run'
    // dt.updateStateById(id);
    // }
    // for (int i = 0; i < len; i++) {
    // VdiJob job = new VdiJob();
    // job = vdiJobList.get(i);
    // String id = job.getId();
    // String cmmond = job.getCommand();
    // String drict = job.getCommandPath();
    //
    // if ("0".equals(flag)) {
    //               
    // dt.updateFailById(id, noRun);
    //               
    // } else {
    // if (win.equals(getOsType())) {
    // Connection connection = new Connection();
    // try {
    // if (drict.length() >= 2) {
    // String drict1 = drict.substring(0, 2);
    // if (("c:".equals(drict1)) || ("C:".equals(drict1))) {
    // command = connection.runCDiskCommand(drict,
    // vdiJob.getIp(), 23, vdiJob.getUser(),
    // vdiJob.getPassword(), cmmond);
    // } else {
    // command = connection.runCommand(drict, vdiJob
    // .getIp(), 23, vdiJob.getUser(), vdiJob
    // .getPassword(), cmmond);
    // }
    //
    // } else {
    //
    // command = connection.runCommand(drict, vdiJob
    // .getIp(), 23, vdiJob.getUser(), vdiJob
    // .getPassword(), cmmond);
    // }
    //
    // } catch (Exception e) {
    // e.printStackTrace();
    // System.out.print(e.getMessage());
    // }
    // } else {
    //
    // TelnetLinux telnetLinux = new TelnetLinux(vdiJob.getIp(),
    // vdiJob.getUser(), vdiJob.getPassword());
    //
    // if (!"".equals(drict) && drict != null) {
    //
    // telnetLinux.sendSimpleCommand("cd " + drict);
    // }
    // telnetLinux.sendCommand(cmmond);
    // command = telnetLinux.getCommandResult();
    // telnetLinux.disconnect();
    // }
    // if ((command == null) && ("1".equals(flag))) {
    // flag = "0";
    //                   
    // dt.updateFailById(id, noRun);
    // }
    // if (("false".equals(String.valueOf(command.getResult())))
    // && ("1".equals(flag))) {
    // flag = "0";
    // String ret = command.getReturnStr();
    // ret =
    // gevUtils.toHtmlString(ret);
    // // telnetUtils.toHtmlString(ret);
    // dt.updateFailById(id, ret);
    // }
    // if (("true".equals(String.valueOf(command.getResult())))
    // && ("1".equals(flag))) {
    // int status = dt.updateById(id, command.getReturnStr());
    // if (status == 0) {
    // break;
    // } else {
    // }
    // }
    //
    // }
    //
    // }
    // }

}
