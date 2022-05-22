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
#include <SPI.h>
#include <MFRC522.h>
#include <ESP8266WiFi.h>
#include <iostream>

#define RST_PIN   4     // Configurable, see typical pin layout above
#define SS_PIN    5    // Configurable, see typical pin layout above

MFRC522 rfid(SS_PIN, RST_PIN);   // Create MFRC522 instance
MFRC522::MIFARE_Key key;

const char* ssid     = "Main";
const char* password = "Ferreira93";

WiFiServer server(80);

String tag; 

void setup() {
  
  // --Setup WiFi--
  
  Serial.begin(115200);
  delay(10);

  // Connect to WiFi network
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");

  // Start the server
  server.begin();
  Serial.println("Server started");

  // Print the IP address
  Serial.println(WiFi.localIP());

  // --Initialize Communications Between ESP8266 and MFRC522--
  
  pinMode(0, OUTPUT);
  while (!Serial);     // Do nothing if no serial port is opened (added for Arduinos based on ATMEGA32U4)
  SPI.begin();         // Init SPI bus
  rfid.PCD_Init();  // Init MFRC522
  
 }

void loop() {

  // --Search for RFID cards--
  
  if (! rfid.PICC_IsNewCardPresent())
    return;
  if (rfid.PICC_ReadCardSerial()){
    for (byte i = 0; i < rfid.uid.size; i++){
      tag += rfid.uid.uidByte[i];
    }
 
  Serial.println(tag);
  delay(500);
  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();
  tag="";
}
}

 
