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

public class GetVappStatus extends BasevCloud {
	public int getVappStatus(String configPath, ReferenceType vappRef)
			throws KeyManagementException, UnrecoverableKeyException,
			NoSuchAlgorithmException, KeyStoreException, VCloudException,
			HttpException, IOException {
		login(configPath);
		Vapp vapp = Vapp.getVappByReference(vcloudClient, vappRef);
		return vapp.getResource().getStatus();
	}

	public static void main(String[] args) {
		try {
			ReferenceType vappRef = new ReferenceType();
			vappRef.setHref(args[1]);
			System.out.println(new GetVappStatus().getVappStatus(args[0], vappRef));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
