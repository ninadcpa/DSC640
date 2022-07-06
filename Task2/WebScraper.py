# Scrapes  Information from the  web site for Aviation Crashes
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


URL = "http://www.baaa-acro.com/crash-archives?created=&created_1=&field_crash_region_target_id=All&field_crash_country_target_id&field_crash_registration_target_id&field_crash_aircraft_target_id&field_crash_operator_target_id&field_crash_cause_target_id=All&field_crash_zone_target_id&field_crash_site_type_target_id=All&field_crash_phase_type_target_id=All&field_crash_flight_type_target_id=All&field_crash_survivors_value=All&field_crash_city_target_id&page=1"
r = requests.get(URL)

#soup = BeautifulSoup(r.content, 'html5lib')
soup = BeautifulSoup(r.content, "lxml")

table = soup.find('thead')
tr0 = table.findAll('tr')

# Get the Column Headers
for row in tr0:
    col1 = row.findAll('th')
    header = (
     str(col1[0].get_text())
    ,str(col1[1].get_text())
    ,str(col1[2].get_text())
    ,str(col1[3].get_text())
    ,str(col1[4].get_text())
    ,str(col1[5].get_text())
    ,str(col1[6].get_text())
    ,"URL"
    ,"PageNum"
#    ,str(col1[7].get_text())
    )


tabletop = tuple(header)
table = soup.find('tbody')
tr1 = table.findAll('tr')

detail = []
for row in tr1:
    new_row = {}
    col1 = row.findAll('td')
    col2 = row.findAll('a')
    detail_row = (
        str(col1[0].get_text())
        , str(col1[1].get_text())
        , str(col1[2].get_text())
        , str(col1[3].get_text())
        , str(col1[4].get_text())
        , str(col1[5].get_text())
        , str(col1[6].get_text())
        , str(col2[0].get('href'))
        , "1"
#        , datetime.today().date()
#        , datetime.today().strftime('%H:%M')  # datetime.strptime(todaydt, '%H:%M:%S.%f')   #datetime.today().time()
#        , datetime.today().weekday()
#        , str(col1[9].get_text()).replace("%", "")
        )
    new_row = dict(zip(tabletop, detail_row))
    detail.append(new_row)

df = DataFrame(detail)
# Load to SQL
df.to_sql('AviationFatalities', schema='dbo', con=engine, if_exists='append', chunksize=1000)

# If all looks good proceed to get all other pages.
count = 2
# LOOP THROUGH ALL 8000 PAGES
while (count < 1350): #1349
    detail = []
    URL = "http://www.baaa-acro.com/crash-archives?created=&created_1=&field_crash_region_target_id=All&field_crash_country_target_id&field_crash_registration_target_id&field_crash_aircraft_target_id&field_crash_operator_target_id&field_crash_cause_target_id=All&field_crash_zone_target_id&field_crash_site_type_target_id=All&field_crash_phase_type_target_id=All&field_crash_flight_type_target_id=All&field_crash_survivors_value=All&field_crash_city_target_id&page="+str(count)
    r = requests.get(URL)
    soup = BeautifulSoup(r.content, "lxml")

    table = soup.find('tbody')
    tr1 = table.findAll('tr')

#    detail = []
    for row in tr1:
        new_row = {}
        col1 = row.findAll('td')
        col2 = row.findAll('a')
        detail_row = (
            str(col1[0].get_text())
            , str(col1[1].get_text())
            , str(col1[2].get_text())
            , str(col1[3].get_text())
            , str(col1[4].get_text())
            , str(col1[5].get_text())
            , str(col1[6].get_text())
            , str(col2[0].get('href'))
            , count
        )
        new_row = dict(zip(tabletop, detail_row))
        detail.append(new_row)

    df = DataFrame(detail)
    # Load to SQL
    df.to_sql('AviationFatalities', schema='dbo', con=engine, if_exists='append', chunksize=1000)
    count = count + 1

#Write the dataframe to file
"""
filename = '.\\datasets\\AviationDataSupplement_baaa-acro.csv'
with open(filename, 'w', newline='', encoding="utf-8") as f:
    w = csv.DictWriter(f, ['Image', 'Date', 'Operator', 'A/C Type', 'Location', 'Fatalities', 'Registration', 'URL'])
    w.writeheader()
    for detailrow in detail:
        w.writerow(detailrow)
"""
