# Scrapes  Information from the detail web site pages for Crash Details
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

header = (
 "Date & Time"
, "src_rowid"
, "Type of aircraft"
, "Operator"
, "Registration"
, "Flight Phase"
, "Flight Type"
, "Survivors"
, "Site"
, "Schedule"
, "MSN"
, "YOM"
, "Location"
, "Country"
, "Region"
, "Crew on board"
, "Crew fatalities"
, "Pax on board"
, "Pax fatalities"
, "Other fatalities"
, "Total fatalities"
, "Circumstances"
)

tabletop = tuple(header)

cursor = conn.cursor()
#cursor.execute('select top 1 rowid as ID, url from DSC640_AviationData..AviationFatalities (nolock) where rowid = 1 order by rowid asc')
cursor.execute('select rowid as ID, url from DSC640_AviationData..AviationFatalities (nolock) order by rowid asc')

for row in cursor:
    src_rowid = row[0]
    urlpage = row[1]

    detail = []
    URL = "http://www.baaa-acro.com/"+str(urlpage)
    r = requests.get(URL)
    soup = BeautifulSoup(r.content, "lxml")

    #crashdatecrashdate
    for each_div in soup.findAll('div', {'class': 'crash-date'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashdate = str(each_div.get_text()).rstrip().lstrip()

    #crash-aircraft
    for each_div in soup.findAll('div', {'class': 'crash-aircraft'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashaircraft = str(each_div.get_text()).rstrip().lstrip()

    #crash-operator
    for each_div in soup.findAll('div', {'class': 'crash-operator'}):
        # Remove unneeded tags
        for s in each_div.select('span'):
            s.extract()
        for s in each_div.select('img'):
            s.extract()
        # Replace Text to clean
        crashoperator = each_div.find('a')['href'].replace("/crash-archives?field_crash_operator_target_id=","")
        if crashoperator == "None" or crashoperator == "":
            crashoperator = str(each_div.get_text()).rstrip().lstrip()
        #else:
        #    crashoperator = col2.get('href')
        #print(crashoperator)

    #crash-registration
    for each_div in soup.findAll('div', {'class': 'crash-registration'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashregistration = str(each_div.get_text()).rstrip().lstrip()

    #crash-flight-phase
    for each_div in soup.findAll('div', {'class': 'crash-flight-phase'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashflightphase = str(each_div.get_text()).rstrip().lstrip()

    #crash-flight-type
    for each_div in soup.findAll('div', {'class': 'crash-flight-type'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashflighttype = str(each_div.get_text()).rstrip().lstrip()

    #crash-survivors
    for each_div in soup.findAll('div', {'class': 'crash-survivors'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashsurvivors = str(each_div.get_text()).rstrip().lstrip()

    #crash-site
    for each_div in soup.findAll('div', {'class': 'crash-site'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashsite = str(each_div.get_text()).rstrip().lstrip()

    #crash-schedule
    for each_div in soup.findAll('div', {'class': 'crash-schedule'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashschedule = str(each_div.get_text()).rstrip().lstrip()

    #crash-construction-num
    for each_div in soup.findAll('div', {'class': 'crash-construction-num'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashconstructionnum = str(each_div.get_text()).rstrip().lstrip()

    #crash-yom
    for each_div in soup.findAll('div', {'class': 'crash-yom'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashyom = str(each_div.get_text()).rstrip().lstrip()

    #crash-location
    for each_div in soup.findAll('div', {'class': 'crash-location'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashlocation = str(each_div.get_text()).rstrip().lstrip()

    #crash-country
    for each_div in soup.findAll('div', {'class': 'crash-country'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashcountry = str(each_div.get_text()).rstrip().lstrip()

    #crash-region
    for each_div in soup.findAll('div', {'class': 'crash-region'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashregion = str(each_div.get_text()).rstrip().lstrip()

    #crash-crew-on-board
    for each_div in soup.findAll('div', {'class': 'crash-crew-on-board'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashcrewonboard = str(each_div.get_text()).rstrip().lstrip()

    #crash-crew-fatalities
    for each_div in soup.findAll('div', {'class': 'crash-crew-fatalities'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashcrewfatalities = str(each_div.get_text()).rstrip().lstrip()

    #crash-pax-on-board
    for each_div in soup.findAll('div', {'class': 'crash-pax-on-board'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashpaxonboard = str(each_div.get_text()).rstrip().lstrip()

    #crash-pax-fatalities
    for each_div in soup.findAll('div', {'class': 'crash-pax-fatalities'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashpaxfatalities = str(each_div.get_text()).rstrip().lstrip()

    #crash-other-fatalities
    for each_div in soup.findAll('div', {'class': 'crash-other-fatalities'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashotherfatalities = str(each_div.get_text()).rstrip().lstrip()

    #crash-total-fatalities
    for each_div in soup.findAll('div', {'class': 'crash-total-fatalities'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashtotalfatalities = str(each_div.get_text()).rstrip().lstrip()

    #crash-circumstances
    for each_div in soup.findAll('div', {'class': 'crash-circumstances'}):
        for s in each_div.select('span'):
            s.extract()
        #print(str(each_div.get_text()).rstrip().lstrip())
        crashcircumstances = str(each_div.get_text()).rstrip().lstrip()

    detail_row = (
         crashdate
        ,src_rowid
        ,crashaircraft
        ,crashoperator
        ,crashregistration
        ,crashflightphase
        ,crashflighttype
        ,crashsurvivors
        ,crashsite
        ,crashschedule
        ,crashconstructionnum
        ,crashyom
        ,crashlocation
        ,crashcountry
        ,crashregion
        ,crashcrewonboard
        ,crashcrewfatalities
        ,crashpaxonboard
        ,crashpaxfatalities
        ,crashotherfatalities
        ,crashtotalfatalities
        ,crashcircumstances
        )
    new_row = dict(zip(tabletop, detail_row))
    detail.append(new_row)

    df = DataFrame(detail)
    # Load to SQL
    df.to_sql('AviationFatalitiesDetails', schema='dbo', con=engine, if_exists='append', chunksize=1000)
