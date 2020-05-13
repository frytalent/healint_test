FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

COPY requirements.txt /
COPY healint_test.py / 
COPY roles.sql /
COPY user_ip_table.csv /
COPY test_db_schema.sql /

WORKDIR /

#WORKDIR /app

VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql", "/var/run/postgresql/", '/data']

RUN apt-get update 

RUN apt-get install -y wget gnupg2

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget --no-check-certificate --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
#RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update 

RUN apt-get install -y postgresql python3-pip

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
  
RUN pip3 install -r /requirements.txt


RUN wget --user-agent="Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0" http://software77.net/geo-ip/history/IpToCountry.1588394470.csv.gz

RUN gzip -d  IpToCountry.1588394470.csv.gz

RUN grep -v '^#' IpToCountry.1588394470.csv > IpToCountry.csv

RUN cat IpToCountry.csv |sed 's/"//g' |awk -F, '{ print $1","$2","$3","$4","$5","$6","$7 }' > IpToCountryNum.csv

RUN PG_HBA=`find /etc/postgresql |grep pg_hba.conf`
RUN echo "host all  all    0.0.0.0/0  md5" | tee -a $PG_HBA

RUN POSTGRESQL_CONF=`find /etc/postgresql |grep postgresql.conf`
RUN echo "listen_addresses='*'" | tee -a $POSTGRESQL_CONF

#RUN cat /etc/postgresql/12/main/pg_hba.conf |sed 's/local   all             postgres                                peer/local   all             postgres                                trust/g' |tee pg_hba.conf 
#RUN cp pg_hba.conf /etc/postgresql/12/main/pg_hba.conf

#RUN systemctl restart postgresql
#RUN `ls /usr/lib/postgresql/*/bin/postgres` -D /usr/local/pgsql/data
RUN mkdir -p /data
RUN chown postgres.postgres /data -R
RUN su  postgres -c '/usr/lib/postgresql/10/bin/postgres -D /data  -c config_file=/etc/postgresql/10/main/postgresql.conf' &
#RUN mkdir -p /var/run/postgresql/10-main.pg_stat_tmp
RUN mkdir -p /var/run/postgresql/
#RUN chown postgres.postgres /var/run/postgresql/10-main.pg_stat_tmp -R
RUN chown postgres.postgres /var/run/postgresql/ -R
#CMD ["`ls /usr/lib/postgresql/*/bin/postgres`", "-D", "/data", "-c", "config_file=$POSTGRESQL_CONF"]
#RUN psql -U postgres  -f /roles.sql
CMD ["`ls /usr/lib/postgresql/*/bin/psql`", "-U", "postgres", "-f", "/roles.sql"] 
#RUN su postgres createdb test
CMD ["`ls /usr/lib/postgresql/*/bin/psql`", "-d", "postgres", "-c", "'CREATE DATABASE test OWNER gene;'"
#CMD ["`ls /usr/lib/postgresql/*/bin/psql`", "-3", "create database test;"] 
CMD ["`ls /usr/lib/postgresql/*/bin/psql`", "-U", "gene", "-d", "test", "-f", "/test_db_schema.sql"] 
#RUN psql -U postgres -d test -f /test_db_schema.sql 

CMD ["`ls /usr/lib/postgresql/*/bin/psql`", "-U", "gene", "-d", "test", "-c", "copy user_ip(userid,ip_address) from '/user_ip_table.csv' delimiter ',' CSV HEADER;"] 
#RUN psql -U postgres -d test -c "copy user_ip(userid,ip_address) from '/user_ip_table.csv' delimiter ',' CSV HEADER;"
CMD ["`ls /usr/lib/postgresql/*/bin/psql`", "-U", "gene", "-d", "test", "-c",  "copy ip_country from '/IpToCountryNum.csv' delimiter ',' CSV;"] 
#RUN psql -U postgres -d test -c "copy ip_country from '/IpToCountryNum.csv' delimiter ',' CSV;"

CMD ["/usr/bin/python3", "/healint_test.py"]

EXPOSE 5432


#CMD ["/usr/lib/postgresql/12/bin/postgres", "-D", "/var/lib/postgresql/12/main", "-c", "config_file=/etc/postgresql/12/main/postgresql.conf"]

