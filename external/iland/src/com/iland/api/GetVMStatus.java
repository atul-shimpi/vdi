package com.iland.api;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;

import org.apache.http.HttpException;

import com.vmware.vcloud.api.rest.schema.ReferenceType;
import com.vmware.vcloud.sdk.VCloudException;
import com.vmware.vcloud.sdk.VM;

public class GetVMStatus extends BasevCloud{

	public int getVmStatus(String configPath, ReferenceType vmRef)
			throws KeyManagementException, UnrecoverableKeyException,
			NoSuchAlgorithmException, KeyStoreException, VCloudException,
			HttpException, IOException {
		login(configPath);
		VM vm = VM.getVMByReference(vcloudClient, vmRef);
		return vm.getResource().getStatus();
	}

	public static void main(String[] args) {
		try {
			ReferenceType vmRef = new ReferenceType();
			vmRef.setHref(args[1]);
			System.out.println(new GetVMStatus().getVmStatus(args[0], vmRef));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
