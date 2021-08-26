#!/usr/bin/env python
# coding: utf-8
# import libraries

from bs4 import BeautifulSoup
import pandas as pd
import requests
import time
import datetime
import smtplib
import csv


##STEP 1. Setup URL, Agent Headers and retrieve webpage html
# connect to website
# find your agent headers at https://httpbin.org/get


URL = 'https://www.amazon.co.uk/Ninja-Fryer-AF160UK-Litres-Black/dp/B07Y3KDL7R/ref=sr_1_3?crid=39UGX263VQLQ2&dchild=1&keywords=ninja+air+fryer&qid=1629984471&sprefix=ninja+air%2Caps%2C172&sr=8-3'

headers = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9", 
    "Accept-Encoding": "gzip, deflate, br", 
    "Accept-Language": "en-GB,en;q=0.9,en-US;q=0.8,lt;q=0.7,ro;q=0.6", 
    "Dnt": "1", 
    "Upgrade-Insecure-Requests": "1", 
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.78"
  }

page = requests.get(URL, headers = headers)

soup1 = BeautifulSoup(page.content, "html.parser")

soup2 = BeautifulSoup(soup1.prettify(), "html.parser")

title = soup2.find(id = 'productTitle').get_text()

price = soup2.find(id = 'priceblock_ourprice').get_text()

print(title)
print(price)


##STEP 2. Clean up data
title = title.strip()
price = price.strip()
rating = rating.strip()[0:3]

#Add date stamp to track when data been has been scrapped
today = datetime.date.today()

##STEP 3. Create data-structure to store inforamtion

#with csv library imported, create data structure for web scrapping results
header = ['Product', 'Price', 'Date']
data = [title, price, today]

#create csv file with header and scrapped data. This code block can and should be commented out after running for the first time.
with open('AmazonProductsScrape.csv', 'w', newline='', encoding='UTF8') as file:
    writer = csv.writer(file)
    writer.writerow(header)
    writer.writerow(data)

    
##STEP 4. Automate scraping task. Put function on timer by using "time" library
def check_price():
    #Define URL and Agent Headers
    URL = 'https://www.amazon.co.uk/Ninja-Fryer-AF160UK-Litres-Black/dp/B07Y3KDL7R/ref=sr_1_3?crid=39UGX263VQLQ2&dchild=1&keywords=ninja+air+fryer&qid=1629984471&sprefix=ninja+air%2Caps%2C172&sr=8-3'


    headers = {
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9", 
        "Accept-Encoding": "gzip, deflate, br", 
        "Accept-Language": "en-GB,en;q=0.9,en-US;q=0.8,lt;q=0.7,ro;q=0.6", 
        "Dnt": "1", 
        "Upgrade-Insecure-Requests": "1", 
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.78"
      }

    page = requests.get(URL, headers = headers)
    #wait for page to fully load
    time.sleep(10)

    soup1 = BeautifulSoup(page.content, "html.parser")

    soup2 = BeautifulSoup(soup1.prettify(), "html.parser")

    title = soup2.find(id = 'productTitle').get_text()

    price = soup2.find(id = 'priceblock_ourprice').get_text()

    rating = soup2.find(class_ = 'a-icon-alt').get_text()
    
    
    
    #Clean retrieved data
    title = title.strip()
    price = price.strip()
    rating = rating.strip()[0:3]
    
    #Create data strcuture
    header = ['Product', 'Price', 'Date']
    data = [title, price, today]
    
    #Now append existing csv file instead of creating new each time script is run. Replace "w" with "a+"
    with open('AmazonProductsScrape.csv', 'a+', newline='', encoding='UTF8') as file:
        writer = csv.writer(file)
        writer.writerow(data)
  #Run send_mail() function when price drops below £124
    if(price < 124):
        send_mail()
    

while(True):
    check_price()
    #Check price 24 hours
    time.sleep(86400)


#Use pandas library to create dataframe to store webscrapper results instead of opening csv file everytime
df = pd.read_csv(r'C:\Users\amark\AmazonProductsScrape.csv')
print(df)


#Optional. Setup emailing service to notify user when price dropped to set value.     
def send_mail():
    server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
    server.ehlo()
    #server.stattls()
    server.ehlo()
    server.login('amarkusenka@outlook.com','xxxxxxxxxxxxx')
    
    subject = "The Air Fryer I want is below £124! Now is your change to buy!"
    body = "Andrius, this is it. The moment you where waiting. Don't mess it up, cheap-o"
    
    msg = f"Subject: {subject}\n\n{body}"
    
    server.sendmail(
        'andriz.marko@gmail.com',
        msg
    )

