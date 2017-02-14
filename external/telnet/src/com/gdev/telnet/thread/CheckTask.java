package com.gdev.telnet.thread;

import com.gdev.telnet.TelnetLinux;
import com.gdev.telnet.TelnetWin;
import com.gdev.telnet.bean.VdiJob;
import com.gdev.telnet.db.DbcpConnect;

public class CheckTask implements Runnable {
    private VdiJob vdiJob;

    private String win = "win";

    private String linux = "linux";

    public CheckTask(VdiJob vdiJob) {
        this.vdiJob = vdiJob;
    }

    private String getOsType(VdiJob vdiJob) {
        String result = vdiJob.getOsType().contains(win) ? win : linux;
        return result;
    }

    public void run() {
        DbcpConnect dt = new DbcpConnect(vdiJob.getDbName(), vdiJob
                .getDbPassword(), vdiJob.getDbIp(), vdiJob.getDbUser());
        if (linux.equals(getOsType(vdiJob))) {
            VdiJob job = dt.findAllJobById(vdiJob.getJobId());
            TelnetLinux telnetLinux = new TelnetLinux(job.getDns(), job
                    .getUser(), job.getPassword());
            System.out.print(telnetLinux.connect());
            if (telnetLinux.connect()) {
                dt.updateJobStatusById(job.getId());
            }
            telnetLinux.disconnect();
        } else {
            VdiJob job = dt.findAllJobById(vdiJob.getJobId());
            TelnetWin telnetWin = new TelnetWin(job.getDns(), job.getUser(),
                    job.getPassword());
            if (telnetWin.connect()) {
                dt.updateJobStatusById(job.getId());
            }
        }
    }

}
