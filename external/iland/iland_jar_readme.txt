How to use Iland.jar

First
    There are 6 classes in this jar:
	                             com.iland.api.BasevCloud
                                 com.iland.api.NewVappFromTemplate
                                 com.iland.api.GetVmFromVapp
                                 com.iland.api.CaptureTemplate
                                 com.iland.api.PowerOn
								 com.iland.api.PowerOff
                                 com.iland.api.UndeployVM
                                 com.iland.api.GetVmStatus
								 com.iland.api.GetTemplateStatus
								 com.iland.api.GetVappStatus
								 com.iland.api.RebootVM
								 com.iland.api.UndeployVapp


Second
    Each of class's introduction

   1,The base of each class(com.iland.api.BasevCloud)
   
   
   2,New a Vapp (com.iland.api.NewVappFromTemplate)
        The input in command line: java -cp jarPath packagePath param1(configPath) param2(template's href) param3(vapp's name)
            Example: java -cp C:\Sandbox\gdevVDI\external\iland\out\dist\Iland.jar com.iland.api.NewVappFromTemplate C:\Sandbox\gdevVDI\external\iland\ https://dal01.ilandcloud.com/api/vAppTemplate/vappTemplate-277a6c5b-dcbe-4e94-b408-f09c7b640168 MyVapp

      Return:(String Type) vapp's href (such as: https://dal01.ilandcloud.com/api/vApp/vapp-ef9a10e1-3b94-49bd-9ff9-c9595902c407)
      Total time to new a vapp: about 5min
	  

   3, Get a VM according to Vapp (com.iland.api.GetVmFromVapp)
       The input in command line: java -cp jarPath packagePath param1(configPath) param2(vapp's href) param3(vm's name) param4(memorysize) param5(cpusize)
           Example: java -cp C:\Sandbox\gdevVDI\external\iland\out\dist\Iland.jar com.iland.api.GetVmFromVapp C:\Sandbox\gdevVDI\external\iland\ https://dal01.ilandcloud.com/api/vApp/vapp-ef9a10e1-3b94-49bd-9ff9-c9595902c407 MyVapp 1024 2

     Return: (String Type) vmip,vmhref (such as: 192.168.0.1,https://dal01.ilandcloud.com/api/vApp/vm-ef9a10e1-3b94-49bd-9ff9-c9595902c407)
	 Total time to get vm : about 50s


   4, Capture a Template (com.iland.api.CaptureTemplate)
        The input in command line: java -cp jarPath packagePath param1(configPath) param2(template name) param3(vm's href)
            Example: java -cp C:\Sandbox\gdevVDI\external\iland\out\dist\Iland.jar com.iland.api.CaptureTemplate C:\Sandbox\gdevVDI\external\iland\ MyTemplate https://dal01.ilandcloud.com/api/vApp/vm-ef9a10e1-3b94-49bd-9ff9-c9595902c407

      Return: (String Type) template's href (such as: https://dal01.ilandcloud.com/api/vAppTemplate/vappTemplate-277a6c5b-dcbe-4e94-b408-f09c7b640168)
	  Total time to capture a template: about 10min


   5, Power on VM (com.iland.api.PowerOn)
        The input in command line: java -cp jarPath packagePath param1(configPath) param2(vapp's href)
            Example: java -cp C:\Sandbox\gdevVDI\external\iland\out\dist\Iland.jar com.iland.api.PowerOn C:\Sandbox\gdevVDI\external\iland\ https://dal01.ilandcloud.com/api/vApp/vapp-ef9a10e1-3b94-49bd-9ff9-c9595902c407

      Return:boolean
	  Total time to power on a vm : about 30s
	  
	  
   6, Power off VM (com.iland.api.PowerOff)
        The input in command line: java -cp jarPath packagePath param1(configPath) param2(vapp's href)
            Example: java -cp C:\Sandbox\gdevVDI\external\iland\out\dist\Iland.jar com.iland.api.PowerOff C:\Sandbox\gdevVDI\external\iland\ https://dal01.ilandcloud.com/api/vApp/vapp-ef9a10e1-3b94-49bd-9ff9-c9595902c407

      Return:boolean
	  Total time to power on a vm : about 30s


   7, Delete a VM (com.iland.api.UndeployVM)  
        The input in command line: java -cp jarPath packagePath param1(configPath) param2(vm's href)
            Example: java -cp C:\Sandbox\gdevVDI\external\iland\out\dist\Iland.jar com.iland.api.UndeployVM C:\Sandbox\gdevVDI\external\iland\ https://dal01.ilandcloud.com/api/vApp/vm-ef9a10e1-3b94-49bd-9ff9-c9595902c407

      Return:boolean
	  Total times to delete a vm: about 30s


   8, Get status of a VM (com.iland.api.GetVmStatus)
        The input in command line: java -cp jarPath packagePath param1(configPath) param2(vm's href)
            Example: java -cp C:\Sandbox\gdevVDI\external\iland\out\dist\Iland.jar com.iland.api.GetVmStatus C:\Sandbox\gdevVDI\external\iland\ https://dal01.ilandcloud.com/api/vApp/vm-ef9a10e1-3b94-49bd-9ff9-c9595902c407

      Return:(int Type) 0(deploying) 4(poweron) 8(poweroff) 3(suspend)
	  Total time to get status of a template: 5s

	  
   9, Get status of a Template (com.iland.api.GetTemplateStatus)
        The input in command line: java -cp jarPath packagePath param1(configPath) param2(vappTemplate's href)
            Example: java -cp C:\Sandbox\gdevVDI\external\iland\out\dist\Iland.jar com.iland.api.GetTemplateStatus C:\Sandbox\gdevVDI\external\iland\ https://dal01.ilandcloud.com/api/vAppTemplate/vappTemplate-277a6c5b-dcbe-4e94-b408-f09c7b640168
	  
	  Return: (int Type) 0(deploying) 8(deployed)	
	  Total time to get status of a template: 5s
	  
	  
  10, Get staus of a Vapp (com.iland.api.GetVappStatus)
        The input in command line: java -cp jarPath packagePath param1(configPath) param2(vapp's href)
	        Example: java -cp C:\Sandbox\gdevVDI\external\iland\out\dist\Iland.jar com.iland.api.GetVappStatus C:\Sandbox\gdevVDI\external\iland\ https://dal01.ilandcloud.com/api/vApp/vapp-ef9a10e1-3b94-49bd-9ff9-c9595902c407
			
	  Return: (int Type) 0(deploying) 4(poweron) 8(poweroff) 3(suspend)
	  Total time to get status of a vm: 5s
	  
  11, Reboot vm (com.iland.api.RebootVM)
        The input in command line: java -cp jarPath packagePath param1(configPath) param2(vm's href)
		    Example: java -cp C:\Sandbox\gdevVDI\external\iland\out\dist\Iland.jar com.iland.api.RebootVM C:\Sandbox\gdevVDI\external\iland\ https://dal01.ilandcloud.com/api/vApp/vm-ef9a10e1-3b94-49bd-9ff9-c9595902c407    
	  
	  Return: boolean
	  Total time to get status of a vm: 30s

  12, Delete a Vapp (com.iland.api.UndeployVapp)  
        The input in command line: java -cp jarPath packagePath param1(configPath) param2(vapp's href)
            Example: java -cp C:\Sandbox\gdevVDI\external\iland\out\dist\Iland.jar com.iland.api.UndeployVapp C:\Sandbox\gdevVDI\external\iland\ https://dal01.ilandcloud.com/api/vApp/vapp-ef9a10e1-3b94-49bd-9ff9-c9595902c407

      Return:boolean
	  Total times to delete a vm: about 30s  
	  
	  