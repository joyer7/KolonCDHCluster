#! /bin/bash
TEMPLATE=$1
# ugly, but for now the docker device has to be put by the user
DOCKERDEVICE=$2

PUBLIC_IP=`curl https://api.ipify.org/`

echo "-- Install CM and MariaDB repo"
wget https://archive.cloudera.com/cm6/6.3.0/redhat7/yum/cloudera-manager.repo -P /etc/yum.repos.d/

yum clean all
rm -rf /var/cache/yum/
yum repolist


yum install -y cloudera-manager-daemons cloudera-manager-agent cloudera-manager-server
yum install -y MariaDB-server MariaDB-client
cat conf/mariadb.config > /etc/my.cnf


echo "--Enable and start MariaDB"
systemctl enable mariadb
systemctl start mariadb

echo "-- Install JDBC connector"
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.46.tar.gz -P ~
tar zxf ~/mysql-connector-java-5.1.46.tar.gz -C ~
mkdir -p /usr/share/java/
cp ~/mysql-connector-java-5.1.46/mysql-connector-java-5.1.46-bin.jar /usr/share/java/mysql-connector-java.jar
rm -rf ~/mysql-connector-java-5.1.46*

echo "-- Create DBs required by CM"
mysql -u root < ~/KolonCDHCluster/scripts/create_db.sql

echo "-- Secure MariaDB"
mysql -u root < ~/KolonCDHCluster/scripts/secure_mariadb.sql

echo "-- Prepare CM database 'scm'"
/opt/cloudera/cm/schema/scm_prepare_database.sh mysql scm scm cloudera





echo "-- Install CSDs"
# install local CSDs
mv ~/*.jar /opt/cloudera/csd/

wget https://archive.cloudera.com/CFM/csd/1.0.0.0/NIFI-1.9.0.1.0.0.0-90.jar -P /opt/cloudera/csd/
wget https://archive.cloudera.com/CFM/csd/1.0.0.0/NIFICA-1.9.0.1.0.0.0-90.jar -P /opt/cloudera/csd/
wget https://archive.cloudera.com/CFM/csd/1.0.0.0/NIFIREGISTRY-0.3.0.1.0.0.0-90.jar -P /opt/cloudera/csd/
# wget https://archive.cloudera.com/cdsw1/1.6.0/csd/CLOUDERA_DATA_SCIENCE_WORKBENCH-CDH6-1.6.0.jar -P /opt/cloudera/csd/

# CSD for C5
wget https://archive.cloudera.com/cdsw1/1.6.1/csd/CLOUDERA_DATA_SCIENCE_WORKBENCH-CDH5-1.6.1.jar -P /opt/cloudera/csd/
wget https://archive.cloudera.com/spark2/csd/SPARK2_ON_YARN-2.4.0.cloudera1.jar -P /opt/cloudera/csd/

chown cloudera-scm:cloudera-scm /opt/cloudera/csd/*
chmod 644 /opt/cloudera/csd/*

echo "-- Install local parcels"
mv ~/*.parcel ~/*.parcel.sha /opt/cloudera/parcel-repo/
chown cloudera-scm:cloudera-scm /opt/cloudera/parcel-repo/*

echo "-- Install CEM Tarballs"
mkdir -p /opt/cloudera/cem
wget https://archive.cloudera.com/CEM/centos7/1.x/updates/1.0.0.0/CEM-1.0.0.0-centos7-tars-tarball.tar.gz -P /opt/cloudera/cem
tar xzf /opt/cloudera/cem/CEM-1.0.0.0-centos7-tars-tarball.tar.gz -C /opt/cloudera/cem
tar xzf /opt/cloudera/cem/CEM/centos7/1.0.0.0-54/tars/efm/efm-1.0.0.1.0.0.0-54-bin.tar.gz -C /opt/cloudera/cem
tar xzf /opt/cloudera/cem/CEM/centos7/1.0.0.0-54/tars/minifi/minifi-0.6.0.1.0.0.0-54-bin.tar.gz -C /opt/cloudera/cem
tar xzf /opt/cloudera/cem/CEM/centos7/1.0.0.0-54/tars/minifi/minifi-toolkit-0.6.0.1.0.0.0-54-bin.tar.gz -C /opt/cloudera/cem
rm -f /opt/cloudera/cem/CEM-1.0.0.0-centos7-tars-tarball.tar.gz
ln -s /opt/cloudera/cem/efm-1.0.0.1.0.0.0-54 /opt/cloudera/cem/efm
ln -s /opt/cloudera/cem/minifi-0.6.0.1.0.0.0-54 /opt/cloudera/cem/minifi
ln -s /opt/cloudera/cem/efm/bin/efm.sh /etc/init.d/efm
chown -R root:root /opt/cloudera/cem/efm-1.0.0.1.0.0.0-54
chown -R root:root /opt/cloudera/cem/minifi-0.6.0.1.0.0.0-54
chown -R root:root /opt/cloudera/cem/minifi-toolkit-0.6.0.1.0.0.0-54
rm -f /opt/cloudera/cem/efm/conf/efm.properties
cp ~/KolonCDHCluster/conf/efm.properties /opt/cloudera/cem/efm/conf
rm -f /opt/cloudera/cem/minifi/conf/bootstrap.conf
cp ~/KolonCDHCluster/conf/bootstrap.conf /opt/cloudera/cem/minifi/conf
sed -i "s/YourHostname/`hostname -f`/g" /opt/cloudera/cem/efm/conf/efm.properties
sed -i "s/YourHostname/`hostname -f`/g" /opt/cloudera/cem/minifi/conf/bootstrap.conf
/opt/cloudera/cem/minifi/bin/minifi.sh install


echo "-- Start CM, it takes about 2 minutes to be ready"
systemctl start cloudera-scm-server

while [ `curl -s -X GET -u "admin:admin"  http://localhost:7180/api/version` -z ] ;
    do
    echo "waiting 10s for CM to come up..";
    sleep 10;
done

echo "-- Now CM is started and the next step is to automate using the CM API"

