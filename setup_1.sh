#! /bin/bash
echo "--------------------------------------------"
echo "● Cloudera CDH 6.3 Install Script           "
echo "● Editor                                    "
echo "  - Shin Seok Rho (joyer@kolon.com)         "
echo "  - Min Heum Kang (minheum_kang@kolon.com)  "
echo "--------------------------------------------"
echo ""
echo ""
echo "------------------------------- Print /etc/hosts ------------------------------"
cat /etc/hosts | while read line
do
    echo $line
done
echo "-------------------------------------------------------------------------------"
echo ""
echo ""

echo -n "Did you Set /etc/hosts?  <y/n > "
read -i Y  input
#echo "You said <${input}>"
if [[ "$input" == "y" || "$input" == "Y" ]]; then
        echo "-------------------------"
        echo "-- OK! Let's Go!"
        echo "-------------------------"
else
        echo "-------------------------"
        echo "-- Set /etc/hosts first!"
        echo "-------------------------"
        exit
fi

echo -n "Did you set /etc/hosts first?  <y/n > "
read -i Y  input
if [[ "$input" == "y" || "$input" == "Y" ]]; then
        echo "-------------------------"
        echo "-- OK! Let's Go!"
        echo "-------------------------"
else
        echo "-------------------------"
        echo "-- Set /etc/hosts first!"
        echo "-------------------------"
        exit
fi

echo "Continue Script !!"

	
read input "Did you set /etc/hosts? <y/n>"  
echo "You said <${input}>"
if [${input} == "y"]; then
	echo "-------------------------"
	echo "-- OK! Let's Go!"
	echo "-------------------------"
else 
	echo "-------------------------"
	echo "-- Set /etc/hosts first!"
	echo "-------------------------"
	exit
fi	


# disable THP(Transparent Huge Pages)
echo ""
echo ""
echo ""
echo "--------------------------------------------------------"
echo "-- Idisable THP(Transparent Huge Pages) : Memory "
echo "--------------------------------------------------------"
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.d/rc.local
echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >> /etc/rc.d/rc.local

# add tuned optimization https://www.cloudera.com/documentation/enterprise/6/6.2/topics/cdh_admin_performance.html
echo  "vm.swappiness = 1" >> /etc/sysctl.conf
sysctl vm.swappiness=1
timedatectl set-timezone UTC

# CDSW requires Centos 7.5, so we trick it to believe it is...
echo "CentOS Linux release 7.6.0 (Core)" > /etc/redhat-release
echo ""
echo ""
echo ""
echo "--------------------------------------------------------"
echo "-- Install Java OpenJDK8 and other tools"
echo "--------------------------------------------------------"

yum install -y java-1.8.0-openjdk-devel vim wget curl git bind-utils

echo ""
echo ""
echo ""
echo "--------------------------------------------------------"
echo "-- Installing requirements for Stream Messaging Manager"
echo "--------------------------------------------------------"
yum install -y gcc-c++ make 
curl -sL https://rpm.nodesource.com/setup_10.x | sudo -E bash - 
yum install nodejs -y
npm install forever -g 


# Check input parameters
echo "server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4" >> /etc/chrony.conf
systemctl restart chronyd



echo ""
echo ""
echo ""
echo "--------------------------------------------------------"
echo "-- Configure networking"
echo "--------------------------------------------------------"
#hostnamectl set-hostname `hostname -f`
#echo "`hostname -I` `hostname`" >> /etc/hosts
#sed -i "s/HOSTNAME=.*/HOSTNAME=`hostname`/" /etc/sysconfig/network
systemctl disable firewalld
systemctl stop firewalld
setenforce 0
sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# Keygen Create
echo ""
echo ""
echo ""
echo "--------------------------------------------------------"
echo "-- Enable passwordless root login via rsa key"
echo "--------------------------------------------------------"
ssh-keygen -f ~/myRSAkey -t rsa -N ""
mkdir ~/.ssh
cat ~/myRSAkey.pub >> ~/.ssh/authorized_keys
chmod 400 ~/.ssh/authorized_keys
ssh-keyscan -H `hostname` >> ~/.ssh/known_hosts
#sed -i 's/.*PermitRootLogin.*/PermitRootLogin without-password/' /etc/ssh/sshd_config
systemctl restart sshd



# Maria DB
## MariaDB 10.1
echo ""
echo ""
echo ""
echo "--------------------------------------------------------"
echo "-- DB Setting MariaDB"
echo "--------------------------------------------------------"
cat - >/etc/yum.repos.d/MariaDB.repo <<EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
yum install -y MariaDB-client

echo ""
echo ""
echo ""
echo "--------------------------------------------------------"
echo "-- Install JDBC connector"
echo "--------------------------------------------------------"
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.46.tar.gz -P ~
tar zxf ~/mysql-connector-java-5.1.46.tar.gz -C ~
mkdir -p /usr/share/java/
cp ~/mysql-connector-java-5.1.46/mysql-connector-java-5.1.46-bin.jar /usr/share/java/mysql-connector-java.jar
rm -rf ~/mysql-connector-java-5.1.46*



# Timedate setting
echo ""
echo ""
echo ""
echo "--------------------------------------------------------"
echo "-- Timedate setting"
echo "--------------------------------------------------------"
timedatectl set-timezone Asia/Seoul


# Completion of Installation
echo "888888888888888___88888888888888"
echo "88888888888888_____8888888888888"
echo "88888888888888_____8888888888888"
echo "8888888888888______8888888888888"
echo "888888888888_______8888888888888"
echo "88888888888_______88888888888888"
echo "888888888________888888888888888"
echo "8888888__________888888888888888"
echo "8888_________________________888"
echo "888__________88888888_________88"
echo "888_________8_________________88"
echo "____________8_________________88"
echo "_____________8888888888888888888"
echo "___________88__________________8"
echo "___________8___________________8"
echo "____________88888888888888888888"
echo "_____________8________________88"
echo "_____________8________________88"
echo "______________888888888888888888"
echo "________________8___________8888"
echo "888_____________8___________8888"
echo "88888888888888888888888888888888"
echo ""
echo "----------------------------------"
echo "-- Setup_1.sh install Success !!!"
echo "----------------------------------"


#echo "Do not Reboot rightnow"
# System Reboot
# sudo reboot


