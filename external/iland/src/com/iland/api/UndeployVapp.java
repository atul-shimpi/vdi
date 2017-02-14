package com.iland.api;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.util.concurrent.TimeoutException;

import org.apache.http.HttpException;

import com.vmware.vcloud.api.rest.schema.ReferenceType;
import com.vmware.vcloud.sdk.VCloudException;
import com.vmware.vcloud.sdk.VM;
import com.vmware.vcloud.sdk.Vapp;

public class UndeployVapp extends BasevCloud{
	/**
	 * 
	 * @param configPath
	 * @param vmRef
	 * @return
	 * @throws KeyManagementException
	 * @throws UnrecoverableKeyException
	 * @throws NoSuchAlgorithmException
	 * @throws KeyStoreException
	 * @throws VCloudException
	 * @throws HttpException
	 * @throws IOException
	 */
	public boolean undeployVapp(String configPath, ReferenceType vappRef)
			throws KeyManagementException, UnrecoverableKeyException,
			NoSuchAlgorithmException, KeyStoreException, VCloudException,
			HttpException, IOException, TimeoutException {
		// login
		login(configPath);
		Vapp vapp = Vapp.getVappByReference(vcloudClient, vappRef);
		if (vapp.getResource().getStatus() != 8) {
			new PowerOff().powerOffVM(configPath, vapp.getReference());
			return false;
		} else {
			vapp.delete().waitForTask(0);
		}
		return true;
	}

	public static void main(String[] args) {
		try {
			ReferenceType ref = new ReferenceType();
			ref.setHref(args[1]);
			System.out.print(new UndeployVapp().undeployVapp(args[0], ref));
		} catch (Exception e) {
			e.printStackTrace();
		} 
	}
}
