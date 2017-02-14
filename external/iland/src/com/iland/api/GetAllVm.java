package com.iland.api;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

import org.apache.http.HttpException;

import com.vmware.vcloud.api.rest.schema.ReferenceType;
import com.vmware.vcloud.sdk.VCloudException;
import com.vmware.vcloud.sdk.VM;
import com.vmware.vcloud.sdk.Vapp;
import com.vmware.vcloud.sdk.Vdc;

public class GetAllVm extends BasevCloud {

	public void getAllVm(String configPath) throws KeyManagementException,
			UnrecoverableKeyException, NoSuchAlgorithmException,
			KeyStoreException, VCloudException, HttpException, IOException {
		login(configPath);
		Vdc vdc = findVdc(configPath);
		Collection<ReferenceType> vappRefs = vdc.getVappRefs();
		Iterator<ReferenceType> vappIt = vappRefs.iterator();
		StringBuffer result = new StringBuffer();
		while (vappIt.hasNext()) {
			ReferenceType vappRef = vappIt.next();
			String vapphref = vappRef.getHref();
			Vapp vapp = Vapp.getVappByReference(vcloudClient, vappRef);
			List<VM> vms = vapp.getChildrenVms();
			String vmip = "";
			String operation = "";
			String cpu = "";
			String memory = "";
			String state = "";
			for (VM vm : vms) {
				String vmhref = vm.getResource().getHref();
				operation = vm.getOperatingSystemSection().getDescription()
						.getValue();
				cpu = vm.getCpu().getNoOfCpus() + "";
				memory = vm.getMemory().getMemorySize().toString();
				state = vm.getResource().getStatus() + "";
				for (String ip : vm.getIpAddressesById().values()) {
					vmip = ip;
				}
				result.append(vapphref).append("#").append(vmhref).append("#")
						.append(vmip).append("#").append(operation).append("#")
						.append(state).append("#").append(memory).append("#")
						.append(cpu).append(",");
			}
		}
		System.out.println(result.substring(0, result.length() - 1));
	}

	public static void main(String[] args) {
		try {
			new GetAllVm().getAllVm(args[0]);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
