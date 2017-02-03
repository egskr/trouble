## Web Server Troubleshooting
### Found and fixed troubles

||Issue| How to find | Time to find|How to fix|Time to fix|
|---:|:--------:|:-------:|:-------:|:---:|:----:|
|1| Service Unavailable | <p align="left">[root@mntlab httpd] <b>curl -sL -w "%{http_code}" localhost -o /dev/null</b> <br>503 (Service Unavailable)</p><p align ="left"><b>modjk.log file:</b> <br>[Thu Feb 02 11:27:31 2017][1367:140056883599328] [error] ajp_service::jk_ajp_common.c (2643): (tomcat.worker) connecting to tomcat failed.[Thu Feb 02 11:27:31 2017][1367:140056883599328] [info] jk_handler::mod_jk.c (2788): Service error=-3 for worker=tomcat.worker[Thu Feb 02 11:27:31 2017]tomcat.worker localhost 0.101289</p>| 5 min| <p align="left"><b>Changing workers.properties file:</b><br>Changing worker.list=tomcat.worker to <br>worker.list=tomcat-worker <br> and changing: <br>worker.worker-jk@ppname.port=8009, worker.worker-jk@ppname.host=192.168.56.100, worker.worker-jk@ppname.reference=worker.template <br>to <br>worker.tomcat-worker.port=8009, worker.tomcat-worker.host=192.168.56.10, worker.tomcat-worker.reference=worker.template  </p>| 20 min
|2| Could not find worker with name 'tomcat.worker'  | <p align="left"><b>Check again modjk.log:</b><br>[Thu Feb 02 13:41:27 2017][2835:140039460317152] [error] extension_fix::jk_uri_worker_map.c (564): Could not find worker with name 'tomcat.worker' in uri map post processing.</p> |10 min | <p align="left"><b>Changing file vhost.conf:</b><br>\<VirtualHost mntlab:80\> to <br>\<VirtualHost \*:80\><br>and<br>JkMount /* tomcat.worker to<br>JkMount /* tomcat-worker</p> |20 min 
|3|   Error 302 Found | <p align="left">[vagrant@mntlab ~]$ <b>curl localhost</b><br>302 Found (Moved Temporarily)</p>| 10 min  | <p align="left"><b>Changing file vhost.conf:</b><br>comment block<br>\<VirtualHost mnt:80\><br>ErrorDocument 404 /error<br>ErrorDocument 500 /error<br>ErrorDocument 503 /error<br>ErrorDocument 504 /error<br>Redirect "/" "http://mntlab/"<br>\</VirtualHost\></p> |20 min
|4|   Tomcat not running | <p align="left">[vagrant@mntlab ~]$ <b>curl localhost</b><br>Site is broken<br>Problem with tomcat:<br>[vagrant@mntlab bin]$ <b>sudo service tomcat restart</b><br><b>ps aux \| grep tomcat\| grep -v grep</b><br>Tomcat not running<br><br>Checking java:<br><b>java -version</b><br><b>alternatives --display java</b><br>Current \`best' version is /opt/oracle/java/x64//jdk1.7.0_79/bin/java<br><b>java -version</b><br>-bash: /usr/bin/java: /lib/ld-linux.so.2: bad ELF interpreter: No such file or directory</p>| 15 min | <p align="left"><b>Use script to select right java:</b><br>best_java_tmp=$(alternatives --display java \| grep Current)<br>best_java_tmp=${best_java_tmp//Current \`best\' version is /}<br>best_java="${best_java_tmp%?}"<br>alternatives --set java $best_java</p>|20 min
|5|  Tomcat not starting from user tomcat | <p align="left">Now we have correct current java version but tomcat can not start properly from user tomcat. But from root it starts properly and opens ports<br>[tomcat@mntlab vagrant]$ <b>/opt/apache/tomcat/current/bin/startup.sh</b><br>Cannot find /tmp/bin/setclasspath.sh<br>This file is needed to run this program</p>| 10 min  | <p align="left">[tomcat@mntlab vagrant]$ <b>env \| grep HOME</b><br> CATALINA_HOME=/tmp/<br>JAVA_HOME=/tmp<br>HOME=/home/tomcat<br>This are wrong pathes. We can fix it by removing strings in file /home/tomcat/.bashrc:<br>Comment strings:<br>export CATALINA_HOME=/tmp<br>export JAVA_HOME=/tmp </p> |25 min
|6|  User tomcat have no rights for logs directory | <p align="left">We must to check tomcat logs. But there no logs in directory<br>/opt/apache/tomcat/current/logs/<br>Why?<br>Because user tomcat have no rights for logs directory:<br>drwxr-xr-x 2 root   root    4096 Фев  2 12:13 logs</p>| 10 min  | <p align="left"><b>sudo chown -R tomcat:tomcat /opt/apache/tomcat/current/logs/</b></p> |20 min
|7|   Tomcat does not start after reboot | <p align="left">Tomcat does not start after reboot<br>[vagrant@mntlab vagrant]# <b>chkconfig \| grep tomcat</b><br>tomcat  	0:off	1:off	2:off	3:off	4:off	5:off	6:off</p>| 5 min  | <p align="left"><b>chkconfig --level 2345 tomcat on</b><br>chkconfig \| grep tomcat<br>tomcat 0:off 1:off 2:on 3:on 4:on 5:on 6:off</p> |10 min
|8|   Add rules in iptables | <p align="left">There are no iptables rules:<br><b>sudo iptables -n -L -v --line-numbers</b><br>Chain INPUT (policy ACCEPT 376 packets, 98080 bytes)<br>num   pkts bytes target     prot opt in     out     source               destination<br>Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)<br>num   pkts bytes target     prot opt in     out     source               destination<br>Chain OUTPUT (policy ACCEPT 344 packets, 133K bytes)<br>num   pkts bytes target     prot opt in     out     source               destination </p>| 10 min  | <p align="left">Add iptables rules:<br><b>sudo iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT</b><br><b>sudo iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT</b><br><b>sudo chattr -i /etc/sysconfig/iptables</b><br><b>sudo service iptables save</b><br><b>chattr +i /etc/sysconfig/iptables<br>sudo service iptables restart</b></p> |30 min
|9|   Changing tomcat log location | <p align="left">Logs for tomcat located by default in /opt/apache/tomcat/current/logs/<br></p>| 10 min  | <p align="left"><b>mkdir -p /var/log/tomcat<br>cd /var/log<br>chown -R tomcat:tomcat tomcat/<br>sed -i 's/${catalina.base}\/logs/\/var\/log\/tomcat/' /opt/apache/tomcat/current/conf/logging.properties</b></p> |30 min





###What java version is installed?
<b>java -version</b>
    java version "1.7.0_79"
    
###How was it installed and configured?
[vagrant@mntlab ~]$ <b>rpm -qa | grep java</b><br>[vagrant@mntlab ~]$ <b>yum list installed | grep java</b><br>[vagrant@mntlab ~]$ <br>Java was copied manually from archive

###Where are log files of tomcat and httpd?
Httpd logs located in /var/log/httpd
Tomcat logs were located in /opt/apache/tomcat/current/logs/ but i changed it location to /var/log/tomcat

###Where is JAVA_HOME and what is it?
JAVA_HOME is variable which used by Java applications and shows directory where java installed

###Where is tomcat installed?
/opt/apache/tomcat

###What is CATALINA_HOME?
CATALINA_HOME is the folder where Tomcat is installed 

###What users run httpd and tomcat processes? How is it configured?
Parent process starts from root, children processes start from user, defined in config httpd.conf.<br>In our casi this is:<br>User apache<br>Group apache<br>[vagrant@mntlab 7.0.62]$ ps aux | grep httpd<br>root      2832  0.0  0.7 173460  3832 ?        Ss   Feb02   0:01 /usr/sbin/httpd<br>apache    2834  0.0  0.6 249372  3328 ?        Sl   Feb02   0:03 /usr/sbin/httpd<br>apache    2835  0.0  0.6 249372  3300 ?        Sl   Feb02   0:03 /usr/sbin/httpd<br>apache    2836  0.0  0.6 249372  3300 ?        Sl   Feb02   0:03 /usr/sbin/httpd<br>apache    2838  0.0  0.5 249372  2600 ?        Sl   Feb02   0:03 /usr/sbin/httpd<br>In tomcat process works from user tomcat<br>It defines in script:<br>su - tomcat -c "sh /opt/apache/tomcat//current/bin/shutdown.sh" > /dev/null from /etc/init.d/tomcat script

###What configuration files are used to make components work with each other?
httpd.conf, vhost.conf, workers.properties

###What does it mean: “load average: 1.18, 0.95, 0.83”?
These are average cpu load values for 1,5,15 minutes.<br>It depends on total quantity of processor cores.<br>Load in % =load value / (cpu quantity * cores quantity) * 100% <br>For example, we have 2 cpu with 2 cores for every cpu. Load in % = 1.18/(2*2) * 100%=30%



