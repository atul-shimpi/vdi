package com.iland.api;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;

import org.apache.http.HttpException;

import com.vmware.vcloud.api.rest.schema.CaptureVAppParamsType;
import com.vmware.vcloud.api.rest.schema.ReferenceType;
import com.vmware.vcloud.sdk.VCloudException;
import com.vmware.vcloud.sdk.VM;
import com.vmware.vcloud.sdk.Vapp;
import com.vmware.vcloud.sdk.VappTemplate;
import com.vmware.vcloud.sdk.Vdc;

public class CaptureTemplate extends BasevCloud {

	/**
	 * 
	 * @param templateName
	 * @param ipString
	 * @return
	 * @throws KeyManagementException
	 * @throws UnrecoverableKeyException
	 * @throws NoSuchAlgorithmException
	 * @throws KeyStoreException
	 * @throws VCloudException
	 * @throws HttpException
	 * @throws IOException
	 * @throws InterruptedException
	 */
	public String generateTemplate(String configPath, String templateName,
			ReferenceType vmRef) throws KeyManagementException,
			UnrecoverableKeyException, NoSuchAlgorithmException,
			KeyStoreException, VCloudException, HttpException, IOException,
			InterruptedException {
		VM rightVm = null;
		// login

		login(configPath);
		// get Vdc
		Vdc vdc = findVdc(configPath);

		rightVm = VM.getVMByReference(vcloudClient, vmRef);
		ReferenceType vappRef1 = rightVm.getParentVappReference();
		Vapp rightVapp = Vapp.getVappByReference(vcloudClient, vappRef1);

		if (rightVapp.getResource().getStatus() != 8) {
			return null;
		}

		CaptureVAppParamsType captureVappParamsType = new CaptureVAppParamsType();
		captureVappParamsType.setSource(vappRef1);
		captureVappParamsType.setName(templateName);
		captureVappParamsType.setDescription("This is my template");
		VappTemplate vt = vdc.captureVapp(captureVappParamsType);
		return vt.getReference().getHref();
	}

	public static void main(String[] args) {
		try {
			ReferenceType vmRef = new ReferenceType();
			vmRef.setHref(args[2]);
			System.out.println(new CaptureTemplate().generateTemplate(args[0],
					args[1], vmRef));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
