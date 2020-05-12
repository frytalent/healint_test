FROM ubuntu:18.04

COPY healint_test.sh /

WORKDIR /

RUN sh healint_test.sh

COPY healint_test.py roles.sql user_ip_table.csv test_db_schema.sql /app

WORKDIR /app

EXPOSE 5432

VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

CMD ["/usr/lib/postgresql/12/bin/postgres", "-D", "/var/lib/postgresql/12/main", "-c", "config_file=/etc/postgresql/12/main/postgresql.conf"]

CMD ["/usr/bin/python3", "/app/healint_test.py"]