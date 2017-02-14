package com.iland.api;

import java.io.FileInputStream;
import java.io.IOException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.util.HashMap;
import java.util.Properties;
import java.util.logging.Level;

import org.apache.http.HttpException;
import org.apache.http.conn.ssl.SSLSocketFactory;

import com.vmware.vcloud.api.rest.schema.ReferenceType;
import com.vmware.vcloud.sdk.Organization;
import com.vmware.vcloud.sdk.VCloudException;
import com.vmware.vcloud.sdk.VcloudClient;
import com.vmware.vcloud.sdk.Vdc;
import com.vmware.vcloud.sdk.constants.Version;

public class BasevCloud {
	public static VcloudClient vcloudClient;
	public static String vCloudURL = "";
	public static String orgName = "";
	public static String vdcName = "";
	public static String catalogName = "";
	public static String username = "";
	public static String password = "";
	public static String networkName = "";

	public static void getValuesFromConfigFile(String configPath) {
		Properties pro = new Properties();
		configPath = configPath + "vcloudConfig.properties";
		try {
			FileInputStream fis = new FileInputStream(configPath);
			pro.load(fis);
			vCloudURL = pro.getProperty("vCloudURL");
			orgName = pro.getProperty("orgName");
			vdcName = pro.getProperty("vdcName");
			catalogName = pro.getProperty("catalogName");
			username = pro.getProperty("username");
			password = pro.getProperty("password");
			networkName = pro.getProperty("networkName");
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	/**
	 * 
	 * @param vCloudURL
	 * @param username
	 * @param password
	 * @throws VCloudException
	 * @throws HttpException
	 * @throws IOException
	 * @throws KeyManagementException
	 * @throws NoSuchAlgorithmException
	 * @throws UnrecoverableKeyException
	 * @throws KeyStoreException
	 */
	public static void login(String configPath) throws VCloudException,
			HttpException, IOException, KeyManagementException,
			NoSuchAlgorithmException, UnrecoverableKeyException,
			KeyStoreException {
		getValuesFromConfigFile(configPath);
		VcloudClient.setLogLevel(Level.ALL);
		vcloudClient = new VcloudClient(vCloudURL, Version.V1_5);
		vcloudClient.registerScheme("https", 443, SSLSocketFactory
				.getSocketFactory());
		vcloudClient.login(username + "@" + orgName, password);
		HashMap<String, ReferenceType> organizationsMap = vcloudClient
				.getOrgRefsByName();
		if (organizationsMap.isEmpty()) {
			System.err.println("	Invalid login for user " + username);
			System.exit(0);
		}

	}

	/**
	 * 
	 * @param orgName
	 * @param vdcName
	 * @return
	 * @throws VCloudException
	 */
	public static Vdc findVdc(String configPath) throws VCloudException {
		getValuesFromConfigFile(configPath);
		ReferenceType orgRef = vcloudClient.getOrgRefByName(orgName);
		Organization org = Organization.getOrganizationByReference(
				vcloudClient, orgRef);
		ReferenceType vdcRef = org.getVdcRefByName(vdcName);
		return Vdc.getVdcByReference(vcloudClient, vdcRef);
	}
}
