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

public class UndeployVM extends BasevCloud {

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
	public boolean undeployVM(String configPath, ReferenceType vmRef)
			throws KeyManagementException, UnrecoverableKeyException,
			NoSuchAlgorithmException, KeyStoreException, VCloudException,
			HttpException, IOException, TimeoutException {
		// login
		login(configPath);
		VM rightVm = VM.getVMByReference(vcloudClient, vmRef);
		Vapp vapp = Vapp.getVappByReference(vcloudClient, rightVm
				.getParentVappReference());

		if (vapp.getResource().getStatus() != 8) {
			new PowerOff().powerOffVM(configPath, vapp.getReference());
			return false;
		} else {
			rightVm.delete().waitForTask(0);
		}
		return true;
	}

	public static void main(String[] args) {
		try {
			ReferenceType ref = new ReferenceType();
			ref.setHref(args[1]);
			System.out.print(new UndeployVM().undeployVM(args[0], ref));
		} catch (Exception e) {
			e.printStackTrace();
		} 
	}
}
