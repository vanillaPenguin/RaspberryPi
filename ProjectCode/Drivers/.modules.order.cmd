cmd_/home/pi/working/ProjectCode/CTesting/Drivers/modules.order := {   echo /home/pi/working/ProjectCode/CTesting/Drivers/buttonDriver.ko;   echo /home/pi/working/ProjectCode/CTesting/Drivers/segmentDriver.ko;   echo /home/pi/working/ProjectCode/CTesting/Drivers/ledDriver.ko; :; } | awk '!x[$$0]++' - > /home/pi/working/ProjectCode/CTesting/Drivers/modules.order