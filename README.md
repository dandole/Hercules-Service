# Hercules-Service
Hercules as a service with startup and clean system shutdown

you will need hercules installed
  in this case, I did a sdl hyperion build, reflected in the location of my hercules
  (used the helper -> github.com/wrljet/hercules-helper  LIKE!!!)
  
you will need some "system" to run on hercules 
  in this case I have a "sysgened" version of MVS/CE (github.com/MVS-sysgen/sysgen) 

you will need to know how to initiate a clean shutdown of the "system"
  in this case I used the jcl found in tk4-  edited for a fast shutdown (careful that leaves 10 seconds to get out of the system)
  this will need to be edited for your "system"  like USER and PASSWORD

you will need a way to submit the shutdown job (many way to do this)
  in this case I am using the hercjis (you can find at -> github.com/wfjm/mvs38j-langtest) LIKE THAT TOO!!

you will need to find a place for controlmvs.sh to be located
you will need to edit many of the starting environment vars to point to all your locations

and after all that move
hercules.service -->  /etc/systemd/system/

systemctl enable hercules.service

systemctl start hercules.service

--- connected to your running hercules (or use hercules web interface)
screen -r   

--- once your system is fully up, try the clean shutdown

systemctl stop hercules.service
---  watch you system for clean shutdown and if using screen -r it should close once hercules exits 

---  hercules system will start with host start, and system will clean shutdown with a host shutdown or reboot

--- ALL of this is theoretical

good luck
