FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

COPY requirements.txt /

WORKDIR /

#COPY healint_test.py /app 
#COPY roles.sql /app
#COPY user_ip_table.csv /app
#COPY test_db_schema.sql /app

#WORKDIR /app

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

RUN cat /etc/postgresql/12/main/pg_hba.conf |sed 's/local   all             postgres                                peer/local   all             postgres                                trust/g' |tee pg_hba.conf 
RUN cp pg_hba.conf /etc/postgresql/12/main/pg_hba.conf
RUN systemctl restart postgresql
RUN psql -U postgres  -f roles.sql 
RUN sudo -u postgres createdb test
RUN psql -U postgres -d test -f test_db_schema.sql 


RUN psql -U postgres -d test -c "copy user_ip(userid,ip_address) from '`pwd`/user_ip_table.csv' delimiter ',' CSV HEADER;"
RUN psql -U postgres -d test -c "copy ip_country from '`pwd`/IpToCountryNum.csv' delimiter ',' CSV;"

EXPOSE 5432

VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

CMD ["/usr/lib/postgresql/12/bin/postgres", "-D", "/var/lib/postgresql/12/main", "-c", "config_file=/etc/postgresql/12/main/postgresql.conf"]

CMD ["/usr/bin/python3", "/app/healint_test.py"]