# Fitting Room Manager

## Introduction

This project aims to mock how a smart fitting room would work and can be divided in two parts. The first part consists in connecting a Feather HUZZAH (ESP8266 WiFi microcontroller) to an RFID reader (RC522) and send the information stored in the tags that will mock pieces of clothing to a Google Firebase database. 

The tag information will be stored only if it is a new one, meaning that if the information about a particular tag is already stored in the fitting room database and the device reads the same one, this tag will be erased from the database. This happens because we can assume that a particular piece of clothing left the fitting room if the device reads the same id for the second time.

The second part of this project is a Flutter mobile app that lets the users authenticate and get all the information about the items in the fitting room. The app has a timer that lets you know how long the item has been in the fitting room and sends notifications to remind the user to check it. 


## How it Works

### RFID Reader

To achieve the desired outcome, the first step is to connect the Feather HUZZAH to the RFID reader using the right pins and then ensure communication between the devices. For this step I used the Arduino [MFRC522 library](https://github.com/miguelbalboa/rfid) created by Miguel Balboa that makes communication with the ESP8266 much easier and allows us to get the RFID tags IDs that we need.

After ensuring communication between the devices, comes another crucial part for this project to work that is connecting the Feather HUZZAH to a WiFi network. We can achieve this once again by using an Arduino library called ESP8266WiFi.

After connecting the devices and setting up the WiFi on the Feather HUZZAH, a database is needed to store information. As I already mentioned above, I decided to use Google Firebase. This decision was made because there's an Arduino library created for using the ESP8266 with Firebase (Firebase_ESP_Client.h) that allows us to easily manipulate a database and to create, send and erase Firebase documents with data in JSON format, which is very convenient since we can store all types of information within a Firebase document.

Before sending any type of data to Firebase I identified the IDs of the two RFID tags available to me and created a structure to store different information for both.
Ideally, if I had multiple tags, this information would be stored in a database that we could then access and retrieve data based on the ID of the tag, but since that's not the case, I "hardcoded" the values for both tags.

The data fields for each "piece of clothing" are:
- Price
- Size
- Item Description
- Image URL
- Date and time when data is stored in Firebase

The last field of data is gotten by making use of the "time" library available for Arduino boards. The time format is set according to my time zone but can be modified in this function:
```
// Get date and time
void setupDateTime() {
  DateTime.setTimeZone("UTC-1");
  DateTime.setServer("pt.pool.ntp.org");
  DateTime.begin();
  if (!DateTime.isTimeValid()) {
    Serial.println("Failed to get time from server.");
  }
}
```
A control field named "Status" was also created to check whether the "piece of clothing" is in the fitting room or not.

After getting the data ready, it's time to send it to Firebase. As I've mentioned before, the program checks if the tag ID is already in the database and, if it is, deletes the respective document. If the tag is not in the database, then it gets added. This is a way to prevent the database from getting too big, but if needed, we have the option to keep all the tags in the database since the program checks the state of the field "Status" ("IN" or "OUT") to know if the "piece of clothing" is in the fitting room or not.

<img src="https://i.imgur.com/P26BYY1.png" alt="Firebase Database" height="350"/>


### Flutter Mobile App (fr_control)

The app, as I've mentioned before, has authentication to let the user register and get access to the fitting room database. 

<img src="https://i.imgur.com/CmsRISt.jpg" alt="Login" height="400"/> <img src="https://i.imgur.com/cBNfoci.jpg" alt="Register" height="400"/>

After logging in, the main screen is presented to the user. This screen tells you how many items are in the fitting room as well as the name of the product, id, size, price and time that it has spent inside of the fitting room. All of this is done by fetching the data sent by the ESP8266 to the Google Firebase database.

If an item is in the fitting room for 24 hours or more, the timer is replaced by a warning.

<img src="https://imgur.com/7ND3t4Y.jpg" alt="Main Screen 1" height="400"> <img src="https://i.imgur.com/sGqFssy.jpg" alt="Main Screen 2" height="400"/>

Every 30 minutes an item spends in the fitting room, a notification will pop up to remind the user to check it. This way the fitting room will always be clean and ready to use.

<img src="https://imgur.com/FhfnyEn.jpg" alt="Main Screen 3" height="400"/>

