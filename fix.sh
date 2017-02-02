#!/bin/bash


#Checking result code. 
checking()
{
	if [ $? -eq 0 ]; then      
 	   res="[OK]"
	else
	   res="[FAIL]"   
	fi
}





########Setting correct java version in alternatives
#Define best java version (with output text processing)
date >/vagrant/fixing.log
best_java_tmp=$(alternatives --display java | grep Current)
best_java_tmp=${best_java_tmp//Current \`best\' version is /}
best_java="${best_java_tmp%?}"
echo $best_java
alternatives --set java $best_java
checking $?
echo "Setting correct java version in alternatives      $res" >> /vagrant/fixing.log


/bin/cp /vagrant/configs/bashrc /home/tomcat/.bashrc
checking $?
echo "Copying .bashrc file                              $res" >> /vagrant/fixing.log



########Correcting workers.properties file
service httpd stop
checking $?
echo "Stopping httpd service                            $res" >> /vagrant/fixing.log

/bin/cp /vagrant/configs/workers.properties /etc/httpd/conf.d/
checking $?
echo "Copying workers.properties file                   $res" >> /vagrant/fixing.log

/bin/cp /vagrant/configs/vhost.conf /etc/httpd/conf.d/
checking $?
echo "Copying vhost.conf file                           $res" >> /vagrant/fixing.log

/bin/cp /vagrant/configs/httpd.conf /etc/httpd/conf/
checking $?
echo "Copying httpd.conf file                           $res" >> /vagrant/fixing.log

service httpd start
checking $?
echo "Starting httpd service                            $res" >> /vagrant/fixing.log

chown -R tomcat:tomcat /opt/apache/tomcat/current/logs/
checking $?
echo "Changing user/group for tomcat logs               $res" >> /vagrant/fixing.log



chkconfig --level 2345 tomcat on
checking $?
echo "Adding tomcat to autostart                        $res" >> /vagrant/fixing.log


service tomcat start
checking $?
echo "Starting tomcat                                   $res" >> /vagrant/fixing.log



sudo iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
checking $?
echo "Adding rule to iptables (port 22)                 $res" >> /vagrant/fixing.log

sudo iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
checking $?
echo "Adding rule to iptables (port 80)                 $res" >> /vagrant/fixing.log

sudo iptables -A INPUT -p tcp -m tcp --dport 2222 -j ACCEPT
checking $?
echo "Adding rule to iptables (port 2222)               $res" >> /vagrant/fixing.log



chattr -i /etc/sysconfig/iptables
service iptables save

checking $?
echo "Saving iptables                                   $res" >> /vagrant/fixing.log
chattr +i /etc/sysconfig/iptables


service iptables restart
checking $?
echo "Restart iptables                                  $res" >> /vagrant/fixing.log

