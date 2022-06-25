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

// Token generation process info.
#include "addons/TokenHelper.h"
// RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

#define RST_PIN   4     // Configurable, see typical pin layout above
#define SS_PIN    5    // Configurable, see typical pin layout above

// Firebase project API Key
#define API_KEY "AIzaSyA4lUrWmolLy7TReQt3XLjsCE_o_kWFpto"

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
String databasePath;
String tagPath;

// Varaible to save tag ID
String tag; 

// Create MFRC522 instance
MFRC522 rfid(SS_PIN, RST_PIN);   
MFRC522::MIFARE_Key key;

// Network credentials
const char* ssid     = "Main";
const char* password = "Ferreira93";

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

// Send item data to Firebase
void sendData(String path, String value, String tagID){
  if (Firebase.RTDB.setString(&fbdo, path.c_str(), value))
  {
    if (value == "OUT") {
      Serial.println("Item " + tag + " left Fitting Room.");
    }
    else {
      Serial.println("Item " + tag + " entered Fitting Room.");
    }
  }
  else{
    Serial.println("ERROR");
    Serial.println(fbdo.errorReason());
  }
  
}

void setup() {
  
  Serial.begin(115200);
  delay(10);

  // Initialize Wifi and MFRC522
  initWifi();
  initComs();

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

  // Update database path
  databasePath = "/UsersData/" + uid;

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
  tagPath = databasePath + "/tags/" + tag; // UsersData/<user_uid>/tags

  // Variables to store item status
  String currentStatus, status = "IN";

  // Retrieves item current status from database
  if (Firebase.ready()){
    if (Firebase.RTDB.getString(&fbdo, tagPath)) {
      if (fbdo.dataType() == "string") {
        currentStatus = fbdo.stringData();
      }
    }
    else {
      String error = fbdo.errorReason();
      if (error == "path not exist") {
        currentStatus = "OUT"; // If tag path was not yet registered, sets item current status to "OUT"
      }
      else {
        return;
      }
    }
  
  if (currentStatus == "IN") {
    status = "OUT";
  }
    // Send data to Firebase
    sendData(tagPath, status, tag);
  }


  delay(500);
  rfid.PICC_HaltA();          // Stop MFRC522 from reading
  rfid.PCD_StopCrypto1();   // Stop encryption on PCD
  tag="";                 // Resets tag string
  
}
}

 
