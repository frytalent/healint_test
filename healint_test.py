#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun May  3 01:01:35 2020
Used table user_ip and ip_country to create count of user by contry code.
@author: gene
"""

import pandas as pd
import psycopg2
from sqlalchemy import create_engine


def ip_to_num(x):
    'covert ip to number'
    nums = x.split('.')
    nums = [int(x) for x in nums]
    ip_num = sum([nums[3],nums[2]*256,nums[1]*256*256,nums[0]*256*256*256])
    return ip_num


database_ip = "45.32.103.71"
#database_ip = "localhost"

conn = psycopg2.connect(host=database_ip, database="test",
                        user="gene", password="d430f885-b284+9d9e39")

engine = create_engine(
    "postgresql://gene:d430f885-b284+9d9e39@%s/test"%database_ip,
    isolation_level="READ UNCOMMITTED"
)

user_ip = pd.read_sql("select * from user_ip", conn)
ip_country = pd.read_sql("select * from ip_country", conn)
user_ip['ip_num'] = user_ip['ip_address'].apply(ip_to_num)
ip_country = ip_country.sort_values('ip_from')
index_str = pd.DataFrame([str(x) for x in range(ip_country.shape[0])])
labels = pd.concat([ip_country.ctry, index_str], axis=1)
labels = labels.ctry +'_'+ labels[0]
bins = pd.concat([ip_country.ip_from,ip_country.tail(1).ip_to])
user_ip_ctry = pd.cut(user_ip.ip_num, bins=bins, labels=labels)

user_ip['ctry_num'] = user_ip_ctry
user_ip['ctry'] = user_ip['ctry_num'].apply(lambda x:x.split('_')[0])

ctry_group = user_ip.groupby(by=['ctry'])['userid'].unique()
ctry_df = pd.DataFrame(ctry_group)
ctry_df['user_count'] = ctry_df.userid.apply(lambda x:len(set(x)))
ctry_df = ctry_df.sort_values('user_count', ascending=False)
ctry_df['timestamp'] = pd.Timestamp.now()
ctry_df.head(10)[['user_count','timestamp']].to_sql('top10', con=engine, if_exists='replace')
ctry_df.head(10)[['user_count','timestamp']].to_csv('top10.csv')