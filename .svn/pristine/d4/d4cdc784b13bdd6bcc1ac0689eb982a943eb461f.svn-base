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

public class RebootVM extends BasevCloud{
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
	 * @throws TimeoutException 
	 */
	public boolean rebootVM(String configPath, ReferenceType vmRef)
			throws KeyManagementException, UnrecoverableKeyException,
			NoSuchAlgorithmException, KeyStoreException, VCloudException,
			HttpException, IOException{
		// login
		login(configPath);
		VM rightVapp = VM.getVMByReference(vcloudClient, vmRef);
		rightVapp.reset();
		return true;
	}

	public static void main(String[] args) {
		try {
			ReferenceType ref = new ReferenceType();
			ref.setHref(args[1]);
			System.out.println(new RebootVM().rebootVM(args[0], ref));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
