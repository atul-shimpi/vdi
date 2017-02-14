package com.iland.api;


import java.util.List;
import java.util.concurrent.TimeoutException;

import javax.xml.bind.JAXBElement;

import com.vmware.vcloud.api.rest.schema.InstantiateVAppTemplateParamsType;
import com.vmware.vcloud.api.rest.schema.InstantiationParamsType;
import com.vmware.vcloud.api.rest.schema.NetworkConfigSectionType;
import com.vmware.vcloud.api.rest.schema.NetworkConfigurationType;
import com.vmware.vcloud.api.rest.schema.ObjectFactory;
import com.vmware.vcloud.api.rest.schema.ReferenceType;
import com.vmware.vcloud.api.rest.schema.VAppNetworkConfigurationType;
import com.vmware.vcloud.api.rest.schema.ovf.MsgType;
import com.vmware.vcloud.api.rest.schema.ovf.SectionType;
import com.vmware.vcloud.sdk.VCloudException;
import com.vmware.vcloud.sdk.Vapp;
import com.vmware.vcloud.sdk.Vdc;
import com.vmware.vcloud.sdk.constants.FenceModeValuesType;

public class NewVappFromTemplate extends BasevCloud{

	/**
	 * 
	 * @param vAppTemplateReference
	 * @param vdc
	 * @param templateName
	 * @return
	 * @throws VCloudException
	 * @throws TimeoutException
	 */
	public Vapp newVappFromTemplate(ReferenceType vAppTemplateReference,
			Vdc vdc, String vappName) throws VCloudException, TimeoutException {

		NetworkConfigurationType networkConfigurationType = new NetworkConfigurationType();
		if (vdc.getAvailableNetworkRefs().size() == 0) {
			System.err.println("No Networks in vdc to instantiate the vapp");
			System.exit(0);
		}

		networkConfigurationType.setParentNetwork(vdc.getAvailableNetworkRefs().iterator().next());
		networkConfigurationType.setFenceMode(FenceModeValuesType.BRIDGED.value());
		
		VAppNetworkConfigurationType vAppNetworkConfigurationType = new VAppNetworkConfigurationType();
		vAppNetworkConfigurationType.setConfiguration(networkConfigurationType);
		vAppNetworkConfigurationType.setNetworkName(vdc
				.getAvailableNetworkRefs().iterator().next().getName());

		NetworkConfigSectionType networkConfigSectionType = new NetworkConfigSectionType();
		MsgType networkInfo = new MsgType();
		networkConfigSectionType.setInfo(networkInfo);
		List<VAppNetworkConfigurationType> vAppNetworkConfigs = networkConfigSectionType
				.getNetworkConfig();
		vAppNetworkConfigs.add(vAppNetworkConfigurationType);


		InstantiationParamsType instantiationParamsType = new InstantiationParamsType();
		List<JAXBElement<? extends SectionType>> sections = instantiationParamsType
				.getSection();
		sections.add(new ObjectFactory()
				.createNetworkConfigSection(networkConfigSectionType));


		InstantiateVAppTemplateParamsType instVappTemplParamsType = new InstantiateVAppTemplateParamsType();
		instVappTemplParamsType.setName(vappName);
		instVappTemplParamsType.setSource(vAppTemplateReference);
		instVappTemplParamsType.setInstantiationParams(instantiationParamsType);

		Vapp vapp = vdc.instantiateVappTemplate(instVappTemplParamsType);
		System.out.println(vapp.getReference().getHref());
		return vapp;

	}

	public static void main(String[] args) {
		try {
			ReferenceType templateRef = new ReferenceType();
			templateRef
					.setHref(args[1]);
			login(args[0]);
			Vdc vdc = findVdc(args[0]);
			new NewVappFromTemplate().newVappFromTemplate(templateRef, vdc, args[2]);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
