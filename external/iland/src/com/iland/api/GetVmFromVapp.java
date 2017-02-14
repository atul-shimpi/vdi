package com.iland.api;

import java.io.IOException;
import java.math.BigInteger;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.TimeoutException;

import org.apache.http.HttpException;

import com.vmware.vcloud.api.rest.schema.NetworkConnectionSectionType;
import com.vmware.vcloud.api.rest.schema.NetworkConnectionType;
import com.vmware.vcloud.api.rest.schema.ReferenceType;
import com.vmware.vcloud.sdk.VCloudException;
import com.vmware.vcloud.sdk.VM;
import com.vmware.vcloud.sdk.Vapp;
import com.vmware.vcloud.sdk.Vdc;
import com.vmware.vcloud.sdk.VirtualCpu;
import com.vmware.vcloud.sdk.VirtualMemory;
import com.vmware.vcloud.sdk.constants.IpAddressAllocationModeType;

public class GetVmFromVapp extends BasevCloud {

	/**
	 * Configuring all the vms in the vapp to static ip addressing mode.
	 * 
	 * @param vapp
	 * @param vdc
	 * @param memorySize
	 * @throws VCloudException
	 * @throws TimeoutException 
	 * @throws TimeoutException
	 */
	public static String configureVMs(Vapp vapp, Vdc vdc, String vmName,
			BigInteger memorySize, int cpuSize) throws VCloudException, TimeoutException {
		String ipString = null;
		VM vm = null;
		List<VM> childVms = vapp.getChildrenVms();
		if (childVms.size() == 0) {
			System.out.println("no vm");
			return null;
		}
		for (VM childVm : childVms) {
			vm = childVm;
			NetworkConnectionSectionType networkConnectionSectionType = childVm
					.getNetworkConnectionSection();
			List<NetworkConnectionType> networkConnections = networkConnectionSectionType
					.getNetworkConnection();
			
			Iterator<ReferenceType> it = vdc.getAvailableNetworkRefs().iterator();
			String networknameString = "";
			while (it.hasNext()) {
				ReferenceType refType =  it.next();
				if (refType.getName().equalsIgnoreCase(networkName)) {
					networknameString = refType.getName();
					break;
				}
			}
			
			for (NetworkConnectionType networkConnection : networkConnections) {
				networkConnection
						.setIpAddressAllocationMode(IpAddressAllocationModeType.POOL
								.value());
				networkConnection.setNetwork(networknameString);
				//Have the network connected
				networkConnection.setIsConnected(true);
			}
            //If there is no network, add one.
            if(networkConnections.size() == 0) {
            	NetworkConnectionType nc = new NetworkConnectionType();
            	nc.setIpAddressAllocationMode(IpAddressAllocationModeType.POOL.value());
            	nc.setNetwork(networknameString);
            	nc.setIsConnected(true);
            	networkConnections.add(nc);
            }
			// set vm memory configuration
			VirtualMemory virtualMemory = childVm.getMemory();
			virtualMemory.setMemorySize(memorySize);
			childVm.updateMemory(virtualMemory).waitForTask(0);

			// set vm cpu configuration
			VirtualCpu virtualCpu = childVm.getCpu();
			virtualCpu.setNoOfCpus(cpuSize);
			childVm.updateCpu(virtualCpu).waitForTask(0);

			childVm.updateSection(networkConnectionSectionType).waitForTask(0);
			for (String ip : VM.getVMByReference(vcloudClient,
					childVm.getReference()).getIpAddressesById().values()) {
				ipString = ip;
			}

		}
		vm.getResource().setName(vmName);
		System.out.println(ipString + "," + vm.getReference().getHref());
		return ipString + "," + vm.getReference().getHref();
	}

	/**
	 * 
	 * @param templateName
	 * @param vmName
	 * @param memorySize
	 * @return
	 * @throws KeyManagementException
	 * @throws UnrecoverableKeyException
	 * @throws NoSuchAlgorithmException
	 * @throws KeyStoreException
	 * @throws VCloudException
	 * @throws HttpException
	 * @throws IOException
	 * @throws TimeoutException 
	 * @throws TimeoutException
	 */
	public String newVmFromVapp(String configPath, ReferenceType vappRef,
			String vmName, BigInteger memorySize, int cupSize)
			throws KeyManagementException, UnrecoverableKeyException,
			NoSuchAlgorithmException, KeyStoreException, VCloudException,
			HttpException, IOException, TimeoutException {
		ReferenceType vAppReferenceType = null;
		// login

		login(configPath);
		// new vApp from vAppTemplate
		Vapp vapp = null;
		vapp = Vapp.getVappByReference(vcloudClient, vappRef);
		// Get the new vDC after new a Vapp
		Vdc vdcAfter = findVdc(configPath);
		Collection<ReferenceType> vAppReferences = vdcAfter.getVappRefs();
		if (!vAppReferences.isEmpty()) {
			for (ReferenceType vAppRef : vAppReferences) {
				if (vAppRef.getHref().equalsIgnoreCase(
						vapp.getReference().getHref())) {
					vAppReferenceType = vAppRef;
				}
			}
		} else {
			System.err.println("No vApp's Found");
		}

		Vapp vapp1 = Vapp.getVappByReference(vcloudClient, vAppReferenceType);
		return configureVMs(vapp1, vdcAfter, vmName, memorySize, cupSize);
	}

	public static void main(String[] args) {
		try {
		    ReferenceType vappRef = new ReferenceType();
			vappRef
					.setHref(args[1]);
			new GetVmFromVapp().newVmFromVapp(args[0],
					vappRef, args[2], new BigInteger(args[3]), Integer
							.parseInt(args[4]));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
