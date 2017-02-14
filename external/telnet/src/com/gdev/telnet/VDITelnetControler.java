package com.gdev.telnet;

import com.gdev.telnet.bean.VdiJob;
import com.gdev.telnet.thread.CallTask;
import com.gdev.telnet.thread.CheckTask;

public class VDITelnetControler {

    /**
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        VdiJob vdiJob = new VdiJob();
        if (args.length == 6) {
            vdiJob.setDbPassword(args[2]);
            vdiJob.setDbName(args[1]);
            vdiJob.setDbIp(args[3]);
            vdiJob.setJobId(args[4]);
            vdiJob.setDbUser(args[5]);
            vdiJob.setOsType(args[0].toLowerCase());
            Thread thread = new Thread(new CheckTask(vdiJob));
            thread.start();
        } else if (args.length == 10) {
             vdiJob.setDbPassword(args[6]);
             vdiJob.setDbName(args[5]);
             vdiJob.setDbIp(args[7]);
             vdiJob.setJobId(args[8]);
             vdiJob.setDbUser(args[9]);
             vdiJob.setOsType(args[4].toLowerCase());
             vdiJob.setIp(args[0]);
             vdiJob.setUser(args[2]);
             vdiJob.setPassword(args[3]);

            Thread thread = new Thread(new CallTask(vdiJob));
            thread.start();

        } else {
            System.out.print("Incorrect number of parameters");
        }
 
    }
}
