/*
 -------- Huzzah Pins --------
 * RST  - 4
 * SS   - 5 (SDA)
 * MOSI - 13 
 * MISO - 12 
 * SCK  - 14 
 * 3V to 3V and GND to GND
 ------------------------------
 */

#include <Arduino.h>
#if defined(ESP32)
  #include <WiFi.h>
#elif defined(ESP8266)
  #include <ESP8266WiFi.h>
#endif
#include <Firebase_ESP_Client.h>
#include <SPI.h>
#include <MFRC522.h>
#include <iostream>
#include <time.h>
#include <ESPDateTime.h>

// Token generation process info.
#include "addons/TokenHelper.h"
// RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

#define RST_PIN   4     // Configurable, see typical pin layout above
#define SS_PIN    5    // Configurable, see typical pin layout above

// Firebase project API Key and project ID
#define API_KEY "AIzaSyA4lUrWmolLy7TReQt3XLjsCE_o_kWFpto"
#define FIREBASE_PROJECT_ID "fitting-room-manager"

// Authorized Email and Corresponding Password
#define USER_EMAIL "pedro30.arf@gmail.com"
#define USER_PASSWORD "frmanager2022"

// RTDB URLefine the RTDB URL
#define DATABASE_URL "https://fitting-room-manager-default-rtdb.europe-west1.firebasedatabase.app/"

// Define Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// Variable to save USER UID
String uid;

// Variables to save database paths
String tagPath;

// Varaible to save tag ID
String tag; 

// Create MFRC522 instance
MFRC522 rfid(SS_PIN, RST_PIN);   
MFRC522::MIFARE_Key key;

// Network credentials
const char* ssid     = "Main";
const char* password = "Ferreira93";

// Tag Mock Info
typedef struct tagData
{
    double price;
    String size;
    String description;
    String imageUrl;
    String timeCreated;
}data;

data tagInfo(String tagId) {

    data item;
    DateTime.now();

    // tag 1
    if (tagId == "601001057") {
      item.price = 25.99;
      item.size = "XS";
      item.description = "Oversize Linen Shirt";
      item.imageUrl = "https://i.imgur.com/ohVNFiM.jpg";
      item.timeCreated = DateTime.toString();  
    }

    // tag 2
    if (tagId == "3521021") {
      item.price = 20.00;
      item.size = "S";
      item.description = "ZW The Cut Off";
      item.imageUrl = "https://i.imgur.com/E3z53i4.jpg";
      item.timeCreated = DateTime.toString(); 
    }

    return item;
}

// Initialize Wifi
void initWifi() {

  // Connect to WiFi network
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");

  // Print the IP address
  Serial.println(WiFi.localIP());

}

// Initialize Communications Between ESP8266 and MFRC522
void initComs() {
  
  pinMode(0, OUTPUT);
  while (!Serial);     // Do nothing if no serial port is opened
  SPI.begin();        // Init SPI bus
  rfid.PCD_Init();   // Init MFRC522

}

void setupDateTime() {
  DateTime.setTimeZone("UTC-1");
  DateTime.setServer("pt.pool.ntp.org");
  DateTime.begin();
  if (!DateTime.isTimeValid()) {
    Serial.println("Failed to get time from server.");
  }
}

// Send tag data to Firebase
void sendData(String tag, String value){
  
  FirebaseJson content;

  data item = tagInfo(tag);

  // Prepare tag info
  content.set("fields/Status/stringValue", value.c_str());
  content.set("fields/Description/stringValue", item.description.c_str());
  content.set("fields/Size/stringValue", item.size.c_str());
  content.set("fields/Price/doubleValue", item.price);
  content.set("fields/Image URL/stringValue", item.imageUrl.c_str());
  content.set("fields/Time/stringValue", item.timeCreated.c_str());   

  // Updates status if tag is already in the database
  if(Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", tagPath.c_str(), content.raw(), "")){
    Serial.printf("ok\n%s\n\n", fbdo.payload().c_str());
  }
  else {
    Serial.println(fbdo.errorReason());
  }

  // Adds tag to the database if it doesn´t exist
  if(Firebase.Firestore.createDocument(&fbdo, FIREBASE_PROJECT_ID, "", tagPath.c_str(), content.raw())){
    Serial.printf("ok\n%s\n\n", fbdo.payload().c_str());
  }
  else {
    Serial.println(fbdo.errorReason());
  }  
}

void setup() {
  
  Serial.begin(115200);
  delay(10);

  // Initialize Wifi and MFRC522
  initWifi();
  initComs();

  // Initialize time server
  setupDateTime();
  

  // Assign API key
  config.api_key = API_KEY;

  // User sign in credentials
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  // Assign RTDB URL
  config.database_url = DATABASE_URL;

  Firebase.reconnectWiFi(true);
  fbdo.setResponseSize(4096);

  // Assign callback function for the long running token generation task
  config.token_status_callback = tokenStatusCallback;

  // Assign maximum retry of token generation
  config.max_token_generation_retry = 5;

  // Initialize library
  Firebase.begin(&config, &auth);

  // Get user UID
  Serial.println("Getting User UID");
  while ((auth.token.uid) == "") {
    Serial.print('.');
    delay(1000);
  }
  // Print user UID
  uid = auth.token.uid.c_str();
  Serial.print("User UID: ");
  Serial.println(uid);

 }

void loop() {

  // Search for RFID cards
  if (! rfid.PICC_IsNewCardPresent())
    return;
  if (rfid.PICC_ReadCardSerial()){
    for (byte i = 0; i < rfid.uid.size; i++){
      tag += rfid.uid.uidByte[i]; // Build tag string
    }
 
  Serial.println("Tag: " + tag);

  // Update database path with MFRC522 readings
  tagPath = "tags/" + tag; // tags/<tag_id>

  // Variables to store item status
  String status = "IN";

  if (Firebase.ready() && DateTime.isTimeValid()) {
    // Gets tag status info from Firestore database
    Serial.print("Search for document... ");
    if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", tagPath.c_str(), "")) {
      Serial.printf("ok\n%s\n\n", fbdo.payload().c_str());

      // Create a FirebaseJson object and set content with received payload
      FirebaseJson payload;
      payload.setJsonData(fbdo.payload().c_str());

      // Get the data from FirebaseJson object 
      FirebaseJsonData jsonData;
      payload.get(jsonData, "fields/Status/stringValue", true);
      
      // Deletes tag if it is already in the Fitting Room
      if(jsonData.stringValue == "IN"){
        status = "OUT";
        Firebase.Firestore.deleteDocument(&fbdo, FIREBASE_PROJECT_ID, "", tagPath.c_str(), "");
        delay(1000);
      }
    } else {
      Serial.println(fbdo.errorReason());
    }

    // Send data to Firestore
    if (status == "IN"){
      sendData(tag, status);
    }
  }

  delay(500);
  rfid.PICC_HaltA();          // Stop MFRC522 from reading
  rfid.PCD_StopCrypto1();   // Stop encryption on PCD
  tag="";                 // Resets tag string
  
}
}
