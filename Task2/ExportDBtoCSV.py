# Export WebScraped Data from SQL DB to CSV

from datetime import datetime
import time
from sqlalchemy import create_engine
import urllib
import requests
from bs4 import BeautifulSoup
import csv
from pandas import DataFrame

import pyodbc
conn = pyodbc.connect('Driver={SQL Server};'
                      'Server=192.168.1.28;'
                      'Database=DSC640_AviationData;'
                      ';UID=usrDSC640;PWD=Password1')
                      #'Trusted_Connection=yes;')
quoted = urllib.parse.quote_plus("DRIVER={SQL Server Native Client 11.0};SERVER=192.168.1.28;DATABASE=DSC640_AviationData;UID=usrDSC640;PWD=Password1")
engine = create_engine('mssql+pyodbc:///?odbc_connect={}'.format(quoted))

cursor = conn.cursor()
cursor.execute('''  
SELECT * FROM DSC640_AviationData..AviationFatalitiesDetails
          ''')

# Get the column names
desc = cursor.description
column_names = [col[0] for col in desc]

# Create dictionary from sql table
detail = [dict(zip(column_names, row))
        for row in cursor.fetchall()]

# Write the dictionary to csv
filename = '.\\datasets\\AviationDataSupplement_baaa-acro.csv'
with open(filename, 'w', newline='', encoding="utf-8") as f:
    w = csv.DictWriter(f, column_names)
    w.writeheader()
    for detailrow in detail:
        w.writerow(detailrow)
