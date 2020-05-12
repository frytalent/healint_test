"""
Created on Sun May  3 14:26:05 2020

@author: gene
"""

#git clone https://github.com/frytalent/healint_test.git

Use python3 to excute healint_test.py.
And i use 3 packages so maybe needed install those.
pip3 install pandas
pip3 install sqlalchemy
pip3 install psycopg2-binary

Then excute it.
python3 healint_test.py

And please use this command to check result with database password.
passowrd: d430f885-b284+9d9e39
psql -h 45.32.103.71 -U gene -d test -c 'select * from top10;'

This script used remote postgresSQL server (45.32.103.71).
But i also create second shell script for create environment on UbuntuUbuntu 20.04 LTS.
sudo sh helint_test.sh

If you want run healint_test.py on local machine, please change #database_ip = "localhost" in script.
And please use this command to check local database result.
psql -U gene -d test -c 'select * from top10;'