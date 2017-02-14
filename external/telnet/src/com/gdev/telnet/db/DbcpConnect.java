package com.gdev.telnet.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.dbcp.ConnectionFactory;
import org.apache.commons.dbcp.DriverManagerConnectionFactory;
import org.apache.commons.dbcp.PoolableConnectionFactory;
import org.apache.commons.dbcp.PoolingDriver;
import org.apache.commons.pool.ObjectPool;
import org.apache.commons.pool.impl.GenericObjectPool;

import com.gdev.telnet.bean.VdiJob;

public class DbcpConnect {

    private static PoolingDriver driver = null;

    private String dbName;

    private String dbPassword;

    private String dbIp;

    private String dbUser;

    public DbcpConnect(String dbName, String dbPassword, String dbIp,
            String dbUser) {
        this.dbIp = dbIp;
        this.dbPassword = dbPassword;
        this.dbName = dbName;
        this.dbUser = dbUser;

    }

    /**
     * set Driver Pool
     * 
     * @param name
     * @param url
     * @throws SQLException
     */
    private static void setUpDriverPool(String name, String url)
            throws SQLException {
        if (driver == null || driver.getPoolNames().length < 2) {
            try {
                ObjectPool op = new GenericObjectPool();
                ConnectionFactory cf = new DriverManagerConnectionFactory(url,
                        null);
                PoolableConnectionFactory pcf = new PoolableConnectionFactory(
                        cf, op, null, null, false, true);
                Class.forName("org.apache.commons.dbcp.PoolingDriver");
                driver = (PoolingDriver) DriverManager
                        .getDriver("jdbc:apache:commons:dbcp:");
                driver.registerPool(name, op);
            } catch (ClassNotFoundException exception) {
                throw new RuntimeException(exception);
            }
        }
    }

    /***************************************************************************
     * shut down driver
     * 
     */
    public void shutDownDriver() {
        try {
            PoolingDriver pd = (PoolingDriver) DriverManager
                    .getDriver("jdbc:apache:commons:dbcp:");
            for (int i = 0; i < pd.getPoolNames().length; i++) {
                driver.closePool("pool");
            }
        } catch (SQLException exception) {
            throw new RuntimeException();
        }
    }

    /***************************************************************************
     * creat a connect with db
     * 
     * @param dbName
     * @param dbPassword
     * @param dbIp
     * @param dbUser
     * @return
     */
    public static Connection getConnection(String dbName, String dbPassword,
            String dbIp, String dbUser) {
        Connection conn = null;
        try {
            String driver = "com.mysql.jdbc.Driver";
            String url = "jdbc:mysql://" + dbIp + ":3306/" + dbName + "?user="
                    + dbUser + "&password=" + dbPassword;
            String poolName = "pool";
            Class.forName(driver);
            setUpDriverPool(poolName, url);
            conn = DriverManager.getConnection("jdbc:apache:commons:dbcp:"
                    + poolName, dbUser, dbPassword);
        } catch (ClassNotFoundException cnfe) {
            throw new RuntimeException("");
        } catch (SQLException sqle) {
            System.out.println(sqle.getMessage());
            throw new RuntimeException("");
        }
        return conn;
    }

    /***************************************************************************
     * close all conect
     * 
     * @param con
     * @param s
     * @param rs
     */
    public static void closeAll(Connection con, Statement s, ResultSet rs) {
        try {
            if (rs != null) {
                rs.close();
                rs = null;
            }
            if (s != null) {
                s.close();
                s = null;
            }
            if (con != null) {
                con.close();
                con = null;
            }
        } catch (SQLException sqle) {
            // nothing to do, forget it;
        }
    }

    /***************************************************************************
     * find all commond and it's stast is Pendding By jobId
     * 
     * @param jobId
     * @return
     */

    public List<VdiJob> findById(String jobId) {
        List<VdiJob> result = new ArrayList<VdiJob>();
        DbcpConnect dt = new DbcpConnect(dbName, dbPassword, dbIp, dbUser);
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            System.out.println("Now working jobId is "+jobId);
            conn = dt.getConnection(dbName, dbPassword, dbIp, dbUser);
            stmt = conn.createStatement();
            String sql = "select id,commands,cmd" +
                    "_path,job_id from runcommands where state='Pendding' and cmd_type='telnet' and job_id="
                    + jobId;
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                VdiJob vdiJob = new VdiJob();
                vdiJob.setId(rs.getString(1));
                vdiJob.setCommand(rs.getString(2));
                vdiJob.setCommandPath(rs.getString(3));
                vdiJob.setJobId(rs.getString(4));
              
                result.add(vdiJob);
            }
            dt.closeAll(conn, stmt, rs);
            dt.shutDownDriver();
        } catch (SQLException sqle) {
          
        } finally {
            dt.closeAll(conn, stmt, rs);
        }
        return result;

    }

    /***************************************************************************
     * if commond run success ,update his stats is success
     * 
     * @param sql
     */
    public int updateById(String jobId, String ret) {
        DbcpConnect dt = new DbcpConnect(dbName, dbPassword, dbIp, dbUser);
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
           
             conn = dt
                    .getConnection(dbName, dbPassword, dbIp, dbUser);
             stmt = conn.createStatement();
            String sql = "update runcommands set state='Success', ret_mark ='"
                    + ret + "'where id =" + jobId;
            
          
            int status = stmt.executeUpdate(sql);

            conn.close();
            stmt.close();

            dt.shutDownDriver();
            return status;
        } catch (SQLException sqle) {         
            System.out.print(sqle.getMessage());
        } finally {
            dt.closeAll(conn, stmt, rs);
        }
        return 0;
    }

    /***************************************************************************
     * lock the commond that will run ,and set it's state is run
     * 
     * @param sql
     */
    public int updateStateById(String id) {
        DbcpConnect dt = new DbcpConnect(dbName, dbPassword, dbIp, dbUser);
        Statement stmt = null;
        ResultSet rs = null;
        Connection conn = null;
        try {
            conn = dt
            .getConnection(dbName, dbPassword, dbIp, dbUser);
             stmt = conn.createStatement();
            String sql = "update runcommands set state='run' where id =" + id;

            int status = stmt.executeUpdate(sql);

            conn.close();
            stmt.close();

            dt.shutDownDriver();
            return status;
        } catch (SQLException sqle) {
            System.out.print(sqle.getMessage());
        } finally {
            dt.closeAll(conn, stmt, rs);
        }
        return 0;
    }

    /***************************************************************************
     * update the commod stats is fail By jobId
     * 
     * @param sql
     */
    public int updateFailById(String id, String ret) {
        DbcpConnect dt = new DbcpConnect(dbName, dbPassword, dbIp, dbUser);
        Statement stmt = null;
        ResultSet rs = null;
        Connection conn = null;
        try {
            conn = dt
            .getConnection(dbName, dbPassword, dbIp, dbUser);
             stmt = conn.createStatement();
             String sql = "update runcommands set state='Fail',ret_mark ='"
                    + ret + "' where id =" + id;

            int status = stmt.executeUpdate(sql);

            conn.close();
            stmt.close();

            dt.shutDownDriver();
            return status;
        } catch (SQLException sqle) {
            System.out.print(sqle.getMessage());
        } finally {
            dt.closeAll(conn, stmt, rs);
        }
        return 0;
    }

    /***************************************************************************
     * find job status By jobId
     * 
     * @param jobId
     * @return
     */
    public String findJobStatusById(String jobId) {
        DbcpConnect dt = new DbcpConnect(dbName, dbPassword, dbIp, dbUser);
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = dt.getConnection(dbName, dbPassword, dbIp, dbUser);
            stmt = conn.createStatement();
            String sql = "select  telnet_service from jobs where  id=" + jobId;
            rs = stmt.executeQuery(sql);
            String retStr = "";
            while (rs.next()) {
                retStr = retStr + rs.getString(1);
            }
            dt.closeAll(conn, stmt, rs);
            dt.shutDownDriver();
            return retStr;
        } catch (SQLException sqle) {
            System.out.println(sqle.getMessage());
        } finally {
            dt.closeAll(conn, stmt, rs);
        }
        return null;

    }

    /***************************************************************************
     * find all job's dns and id .
     * 
     * @return
     */
    public List<VdiJob> findAllJob() {
        List<VdiJob> result = new ArrayList<VdiJob>();
        DbcpConnect dt = new DbcpConnect(dbName, dbPassword, dbIp, dbUser);
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = dt.getConnection(dbName, dbPassword, dbIp, dbUser);
            stmt = conn.createStatement();
            String sql = "select job.id, ec.public_dns, tem.user,tem.password from jobs job , ec2machines ec , templates tem where job.ec2machine_id = ec.id and template_id=tem.id";
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                VdiJob vdiJob = new VdiJob();
                vdiJob.setId(rs.getString(1));
                vdiJob.setDns(rs.getString(2));
                vdiJob.setUser(rs.getString(3));
                vdiJob.setPassword(rs.getString(4));
                result.add(vdiJob);
            }
            dt.closeAll(conn, stmt, rs);
            dt.shutDownDriver();
        } catch (SQLException sqle) {
            System.out.println(sqle.getMessage());
        } finally {
            dt.closeAll(conn, stmt, rs);
        }
        return result;

    }

    public VdiJob findAllJobById(String jobId) {
        List<VdiJob> result = new ArrayList<VdiJob>();
        DbcpConnect dt = new DbcpConnect(dbName, dbPassword, dbIp, dbUser);
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = dt.getConnection(dbName, dbPassword, dbIp, dbUser);
            stmt = conn.createStatement();
            String sql = "select job.id, ec.public_dns, tem.user,tem.password from jobs job , ec2machines ec , templates tem where job.ec2machine_id = ec.id and template_id=tem.id  and job.id="
                    + jobId;
       
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                VdiJob vdiJob = new VdiJob();
                vdiJob.setId(rs.getString(1));
                vdiJob.setDns(rs.getString(2));
                vdiJob.setUser(rs.getString(3));
                vdiJob.setPassword(rs.getString(4));
                result.add(vdiJob);
            }           
            dt.closeAll(conn, stmt, rs);
            dt.shutDownDriver();
        } catch (SQLException sqle) {
            System.out.println(sqle.getMessage());
        } finally {
            dt.closeAll(conn, stmt, rs);
        }
        if(result != null&& result.size()!=0 ){
            return result.get(0);
        }
       return null;

    }

    /***************************************************************************
     * if connect servers is success , set his status is start.
     * 
     * @param id
     * @return
     */
    public int updateJobStatusById(String id) {
        DbcpConnect dt = new DbcpConnect(dbName, dbPassword, dbIp, dbUser);
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
             conn = dt
                    .getConnection(dbName, dbPassword, dbIp, dbUser);
             stmt = conn.createStatement();
            String sql = "update jobs set telnet_service='start'  where id ="
                    + id;

            int status = stmt.executeUpdate(sql);

            conn.close();
            stmt.close();

            dt.shutDownDriver();
            return status;
        } catch (SQLException sqle) {
            System.out.println(sqle.getMessage());
        } finally {
            dt.closeAll(conn, stmt, rs);
        }
        return 0;
    }
    

}
