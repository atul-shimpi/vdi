package com.iland.api;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;

import org.apache.http.HttpException;

import com.vmware.vcloud.api.rest.schema.CatalogItemType;
import com.vmware.vcloud.api.rest.schema.ReferenceType;
import com.vmware.vcloud.sdk.Catalog;
import com.vmware.vcloud.sdk.Organization;
import com.vmware.vcloud.sdk.VCloudException;
import com.vmware.vcloud.sdk.VappTemplate;
import com.vmware.vcloud.sdk.Vdc;

public class GetTemplateStatus extends BasevCloud {

	public static int getTemplateStatus(String configPath,
			ReferenceType vappTemplRef) throws KeyManagementException,
			UnrecoverableKeyException, NoSuchAlgorithmException,
			KeyStoreException, VCloudException, HttpException, IOException {
		login(configPath);
		VappTemplate template = VappTemplate.getVappTemplateByReference(
				vcloudClient, vappTemplRef);
		// put my template to "aaa" catalog
		if (template.getResource().getStatus() == 8) {
			ReferenceType catalogRef = findCatalogRef(configPath);
			Catalog catalog = Catalog.getCatalogByReference(vcloudClient,
					catalogRef);
			catalog.addCatalogItem(createNewCatalogItem(template.getReference()));
		}
		return template.getResource().getStatus();
	}

	/**
	 * findCatalogRef gets the href of the Catalog named on the command line.
	 * 
	 * @param catalogName
	 * @return {@link Vdc}
	 * @throws VCloudException
	 */
	public static ReferenceType findCatalogRef(String configPath)
			throws VCloudException {
		getValuesFromConfigFile(configPath);
		ReferenceType orgRef = vcloudClient.getOrgRefsByName().get(orgName);
		Organization org = Organization.getOrganizationByReference(
				vcloudClient, orgRef);
		ReferenceType catalogRef = null;
		for (ReferenceType ref : org.getCatalogRefs()) {
			if (ref.getName().equals(catalogName))
				catalogRef = ref;
		}
		return catalogRef;
	}

	/**
	 * Create a new catalog item type with the specified vapp template reference
	 * 
	 * @param vAppTemplatereference
	 *            {@link ReferenceType}
	 * @return {@link CatalogItemType}
	 */
	public static CatalogItemType createNewCatalogItem(
			ReferenceType vAppTemplatereference) {
		CatalogItemType catalogItemType = new CatalogItemType();
		catalogItemType.setName(vAppTemplatereference.getName());
		catalogItemType.setDescription(vAppTemplatereference.getName()
				+ " Description");
		catalogItemType.setEntity(vAppTemplatereference);
		return catalogItemType;

	}

	public static void main(String[] args) {
		try {
			ReferenceType vappTemplRef = new ReferenceType();
			vappTemplRef.setHref(args[1]);
			System.out.println(getTemplateStatus(args[0], vappTemplRef));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
