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
import com.vmware.vcloud.sdk.constants.UndeployPowerActionType;

public class PowerOff extends BasevCloud {
	/**
	 * 
	 * @param ipString
	 * @return
	 * @throws KeyManagementException
	 * @throws UnrecoverableKeyException
	 * @throws NoSuchAlgorithmException
	 * @throws KeyStoreException
	 * @throws VCloudException
	 * @throws HttpException
	 * @throws IOException
	 */
	public boolean powerOffVM(String configPath, ReferenceType vappRef)
			throws KeyManagementException, UnrecoverableKeyException,
			NoSuchAlgorithmException, KeyStoreException, VCloudException,
			HttpException, IOException {
		// login
		login(configPath);
		Vapp rightVapp = Vapp.getVappByReference(vcloudClient, vappRef);
		try {
			UndeployPowerActionType[] aActionTypes = UndeployPowerActionType
					.values();
			for (int i = 0; i < aActionTypes.length; i++) {
				if (i == 1) {
					rightVapp.undeploy(aActionTypes[i]);
				}
			}

		} catch (Exception e) {
			return false;
		}
		return true;
	}

	public static void main(String[] args) {
		try {
			ReferenceType ref = new ReferenceType();
			ref.setHref(args[1]);
			System.out.println(new PowerOff().powerOffVM(args[0], ref));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
