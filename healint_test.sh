#!/usr/bin/env sh
# -*- coding: utf-8 -*-

######################################
#Created on Sun May  3 01:12:56 2020
#setup environment for healint test
#@author: gene
######################################

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt update
apt install -y postgresql-12
sudo -u postgres createdb test

apt install -y python3-pip
pip3 install pandas
pip3 install sqlalchemy
pip3 install psycopg2-binary

wget --user-agent="Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0" http://software77.net/geo-ip/history/IpToCountry.1588394470.csv.gz
gzip -d  IpToCountry.1588394470.csv.gz
grep -v '^#' IpToCountry.1588394470.csv > IpToCountry.csv
cat IpToCountry.csv |sed 's/"//g' |awk -F, '{ print $1","$2","$3","$4","$5","$6","$7 }' > IpToCountryNum.csv


sudo cat /etc/postgresql/12/main/pg_hba.conf |sed 's/local   all             postgres                                peer/local   all             postgres                                trust/g' |tee pg_hba.conf 
sudo cp pg_hba.conf /etc/postgresql/12/main/pg_hba.conf
sudo systemctl restart postgresql
psql -U postgres  -f roles.sql 
sudo -u postgres createdb test
psql -U postgres  -f test_db_schema.sql 


psql -U gene -d test -c "copy user_ip(userid,ip_address) from '`pwd`/user_ip_table.csv' delimiter ',' CSV HEADER;"
psql -U gene -d test -c "copy ip_country from '`pwd`/IpToCountryNum.csv' delimiter ',' CSV;"


