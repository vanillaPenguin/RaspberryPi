cmd_/home/pi/working/week10/Homework/button_driver.mod := printf '%s\n'   button_driver.o | awk '!x[$$0]++ { print("/home/pi/working/week10/Homework/"$$0) }' > /home/pi/working/week10/Homework/button_driver.mod