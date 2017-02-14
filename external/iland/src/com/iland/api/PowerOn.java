package com.iland.api;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;

import org.apache.http.HttpException;

import com.vmware.vcloud.api.rest.schema.ReferenceType;
import com.vmware.vcloud.sdk.VCloudException;
import com.vmware.vcloud.sdk.Vapp;

public class PowerOn extends BasevCloud {

	/**
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
	public boolean powerOnVM(String configPath, ReferenceType vappRef)
			throws KeyManagementException, UnrecoverableKeyException,
			NoSuchAlgorithmException, KeyStoreException, VCloudException,
			HttpException, IOException {
		// login
		login(configPath);
		Vapp rightVapp = Vapp.getVappByReference(vcloudClient, vappRef);
		try {
			rightVapp.powerOn();
		} catch (Exception e) {
			return false;
		}
		return true;
	}

	public static void main(String[] args) {
		try {
			ReferenceType ref = new ReferenceType();
			ref.setHref(args[1]);
			System.out.print(new PowerOn().powerOnVM(args[0], ref));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
