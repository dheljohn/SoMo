
#define GREEN_LED_PIN 26  // Change to GPIO 26
#define RED_LED_PIN 27    // Change to GPIO 27

#define DHTPIN 4     // new added - GPIO4 (can be any digital pin)
#define DHTTYPE DHT22   //new added - DHT 22 (AM2302)
#include <ArduinoJson.h>


#include <Arduino.h>
#include <WiFi.h>
#include "SD.h"   // ESP32's SD library
#include <TimeLib.h>  // Time library to get timestamps

#include <time.h>  // Built-in ESP32 time library
#include <Firebase_ESP_Client.h>

//Provide the token generation process info.
#include "addons/TokenHelper.h"
//Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

#include <DHT.h> //new added

// Insert network credentials
//#define WIFI_SSID "REPLACE_WITH_YOUR_SSID"
//#define WIFI_PASSWORD "REPLACE_WITH_YOUR_PASSWORD"
// #define WIFI_SSID "Hotspot"
// #define WIFI_PASSWORD "12468642369485"

// #define WIFI_SSID "Kaida"
// #define WIFI_PASSWORD "Kaida123"

const char* wifiList[][3] = {
  {"HUAWEI-D8kG", "ana@36546"},
  {"Carlo", "carlfrancis0205"},
  {"Kaida", "Kaida123"},
  {"Hotspot", "12468642369485"},
  {"VILLA", "arielvillajr."},
  {"TECNNO CAMON 20 Pro", "vidallo12345"},
  {"CCT2-512", "ccthospes2019"},
  {"HG8145V5_D400A", "jcww2myE"},

};
const int numNetworks = sizeof(wifiList) / sizeof(wifiList[0]);


// const char* fcmServerKey = "YOUR_SERVER_KEY";  // Replace with your FCM Server Key
// const char* fcmEndpoint = "https://fcm.googleapis.com/fcm/send";

// #define WIFI_SSID "TECNNO CAMON 20 Pro"
// #define WIFI_PASSWORD "vidallo12345"
// #define DATABASE_URL "https://test-monitor-reui-default-rtdb.asia-southeast1.firebasedatabase.app/"

// Insert Firebase project API Key
//#define API_KEY "REPLACE_WITH_YOUR_FIREBASE_PROJECT_API_KEY"
#define API_KEY "AIzaSyA_lQLKsXD_SGL4QyEVO3HEFUgJUcQW0sQ"

// Insert RTDB URLefine the RTDB URL */
//#define DATABASE_URL "REPLACE_WITH_YOUR_FIREBASE_DATABASE_URL" 
#define DATABASE_URL "https://test-monitor-reui-default-rtdb.asia-southeast1.firebasedatabase.app/"

//Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
FirebaseJson doc; // Declare doc globally or inside fetchPlotFromFirestore()


FB_Firestore firestore;


unsigned long sendDataPrevMillis = 0;
int count = 0;
bool signupOK = false;

int sensorPin1 = 34;  // Soil moisture sensor connected to GPIO 34
int sensorPin2 = 35;
int sensorPin3 = 33;
int sensorPin4 = 32;
String plotID;  // Declare globally


// Initialize the DHT sensor
DHT dht(DHTPIN, DHTTYPE);

void connectToWiFi() {
  //to connect to any wifi by trying 1by1
  
  WiFi.mode(WIFI_STA);

  for (int i = 0; i < numNetworks; i++) {
    Serial.print("Trying to connect to: ");
    Serial.println(wifiList[i][0]);

    WiFi.begin(wifiList[i][0], wifiList[i][1]);

    int attempts = 20;  // Timeout after ~10 seconds
    while (WiFi.status() != WL_CONNECTED && attempts > 0) {
      delay(500);
      Serial.print(".");
      attempts--;
    }

    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("\nConnected to WiFi!");
      Serial.print("IP Address: ");
      Serial.println(WiFi.localIP());
      digitalWrite(RED_LED_PIN, LOW);   // Turn off red LED (Not an error)
      digitalWrite(GREEN_LED_PIN, HIGH); // Turn on green LED (System ready)
      return;
    }

    Serial.println("\nFailed, trying next...");
  }

  Serial.println("Could not connect to any WiFi."); // Print the IP address
  digitalWrite(GREEN_LED_PIN, LOW);
  digitalWrite(RED_LED_PIN, HIGH);  // Keep red LED on (Error)

}

float averageMoisture(int readings[], int count) {
  float sum = 0;
  for (int i = 0; i < count; i++) {
    sum += readings[i];
  }
  return sum / count;  // Return the average
}

void readAndDisplaySensorValues() {
  //Serial.println(WiFi.localIP()); 
  
  // Read soil moisture sensor values
  int sensorValue1 = analogRead(sensorPin1);
  int moisturePercent1 = (sensorValue1 < 100 || sensorValue1 > 4000) ? 0 : map(sensorValue1, 0, 4095, 100, 0); // Map to reverse 0-100%

  int sensorValue2 = analogRead(sensorPin2);
  int moisturePercent2 = (sensorValue2 < 100 || sensorValue2 > 4000) ? 0 : map(sensorValue2, 0, 4095, 100, 0);  // Map to reverse 0-100%

  int sensorValue3 = analogRead(sensorPin3);
  int moisturePercent3 = (sensorValue3 < 100 || sensorValue3 > 4000) ? 0 : map(sensorValue3, 0, 4095, 100, 0);  // Map to reverse 0-100%

  int sensorValue4 = analogRead(sensorPin4);
  int moisturePercent4 = (sensorValue4 < 100 || sensorValue4 > 4000) ? 0 : map(sensorValue4, 0, 4095, 100, 0); // Map to reverse 0-100%

  float temperature = dht.readTemperature();  // Read temperature
  float humidity = dht.readHumidity();  // Read humidity
  fetchPlotFromFirestore();
  // Calculate average moisture
  int moistureReadings[] = {
    moisturePercent1, 
    moisturePercent2, 
  moisturePercent3, 
  moisturePercent4};
  float averageMoistureLevel = averageMoisture(moistureReadings, 4);

  // Display the values on the Serial Monitor
  if (Firebase.RTDB.setInt(&fbdo, "Moisture/MoistureReadings_1", moisturePercent1)){
      // Serial.println("PASSED");
      // Serial.println("PATH: " + fbdo.dataPath());
      // Serial.println("TYPE: " + fbdo.dataType());
      
    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    } 

    if (Firebase.RTDB.setInt(&fbdo, "Moisture/MoistureReadings_2", moisturePercent2)){
      // Serial.println("PASSED");
      // Serial.println("PATH: " + fbdo.dataPath());
      // Serial.println("TYPE: " + fbdo.dataType());
      
    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    } 
    if (Firebase.RTDB.setInt(&fbdo, "Moisture/MoistureReadings_3", moisturePercent3)){
      // Serial.println("PASSED");
      // Serial.println("PATH: " + fbdo.dataPath());
      // Serial.println("TYPE: " + fbdo.dataType());
      
    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    } 

    if (Firebase.RTDB.setInt(&fbdo, "Moisture/MoistureReadings_4", moisturePercent4)){
      // Serial.println("PASSED");
      // Serial.println("PATH: " + fbdo.dataPath());
      // Serial.println("TYPE: " + fbdo.dataType());
      
    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    } 

    if (Firebase.RTDB.setFloat(&fbdo, "Moisture/Average", averageMoistureLevel)){
      // Serial.println("PASSED");
      // Serial.println("PATH: " + fbdo.dataPath());
      // Serial.println("TYPE: " + fbdo.dataType());
      
    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    } 


    if (Firebase.RTDB.setFloat(&fbdo, "Temperature/temperature", temperature)){
      // Serial.println("PASSED");
      // Serial.println("PATH: " + fbdo.dataPath());
      // Serial.println("TYPE: " + fbdo.dataType());
      
    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    } 

    if (Firebase.RTDB.setFloat(&fbdo, "Humidity/humidity", humidity)){
      // Serial.println("PASSED");
      // Serial.println("PATH: " + fbdo.dataPath());
      // Serial.println("TYPE: " + fbdo.dataType());
      
    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    } 
  Serial.println("Soil Moisture Levels:");
  Serial.print("Sensor 1: "); Serial.print(moisturePercent1); Serial.println("%");
  Serial.print("Sensor 2: "); Serial.print(moisturePercent2); Serial.println("%");
  Serial.print("Sensor 3: "); Serial.print(moisturePercent3); Serial.println("%");
  Serial.print("Sensor 4: "); Serial.print(moisturePercent4); Serial.println("%");
  Serial.print("Average Soil Moisture: "); Serial.print(averageMoistureLevel); Serial.println("%");
  Serial.print("Temperature: "); Serial.print(temperature); Serial.println("°C");
  Serial.print("Humidity: "); Serial.print(humidity); Serial.println("%");
  Serial.println("------------------------------");
} //new added


// Firestore starts here!!!!!!!
// This for setting the time no need na sa RTC component instead we using network time protocol
void setupTime() {
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("WiFi not connected! Cannot sync time.");
        return;
    }
    const long gmtOffset_sec = 8 * 3600; // GMT+8 (Philippines, Singapore, etc.)
    const int daylightOffset_sec = 0;    // No DST in many countries

    configTime(gmtOffset_sec, daylightOffset_sec, "pool.ntp.org");

    configTime(8 * 3600, 0, "pool.ntp.org", "time.google.com", "asia.pool.ntp.org");


    Serial.println("Syncing time...");

    delay(5000);  // Wait for NTP sync

    time_t now = time(nullptr);
    int attempts = 10;
    while (now < 1000000000 && attempts > 0) { // Check if time is reasonable
        Serial.println("Waiting for NTP sync...");
        delay(1000);
        now = time(nullptr);
        attempts--;
    }
    
    if (now < 1000000000) {
        Serial.println("❌ Failed to get time from NTP!");
    } else {
        Serial.println("✅ Time synchronized!");
    }
}

  //Getting the Date and Time here 
  String getDateString() {
    time_t now = time(nullptr);
    struct tm timeInfo;
    localtime_r(&now, &timeInfo);
    char buffer[11];  // YYYY-MM-DD format
    strftime(buffer, sizeof(buffer), "%Y-%m-%d", &timeInfo);
    return String(buffer);
}

  String getTimeString() {
    time_t now = time(nullptr);
    struct tm timeInfo;
    localtime_r(&now, &timeInfo);
    char buffer[9];  // HH-MM-SS format
    strftime(buffer, sizeof(buffer), "%H-%M-%S", &timeInfo);
    return String(buffer);
}


  // Connecting and creating logs storing to Firestore
  void saveDailyLogToFirestore(float temperature, float humidity, float avgMoisture, 
                             int moisture1, int moisture2, 
                             int moisture3, 
                             int moisture4, String plotID) {
    FirebaseJson json;
    
    // Get current date and time
    String dateString = getDateString();
    String timeString = getTimeString();  

    // Get time in ISO 8601 format
    time_t now = time(nullptr);
    struct tm timeInfo;
    gmtime_r(&now, &timeInfo);  // Convert to UTC time

    char isoTime[25];  // "YYYY-MM-DDTHH:MM:SSZ"
    strftime(isoTime, sizeof(isoTime), "%Y-%m-%dT%H:%M:%SZ", &timeInfo);
    //print debugg statemnt
    Serial.print("Current timestamp: ");
    Serial.println(isoTime);


    json.set("fields/timestamp/timestampValue", isoTime);
    json.set("fields/temperature/doubleValue", temperature);
    json.set("fields/humidity/doubleValue", humidity);
    json.set("fields/average_moisture/doubleValue", avgMoisture);
    json.set("fields/moisture_1/integerValue", moisture1);
    json.set("fields/moisture_2/integerValue", moisture2);
    json.set("fields/moisture_3/integerValue", moisture3);
    json.set("fields/moisture_4/integerValue", moisture4);
    json.set("fields/plot/stringValue", plotID);


    String jsonString;
    json.toString(jsonString, true);

    // Firestore path: "DailyLogs/{dateString}/logs/{timeString}"
    String collectionPath = "DailyLogs/" + dateString + "/logs";
    String documentPath = timeString;

    // Creating document and collection logs to the firestore
    if (firestore.createDocument(&fbdo, "test-monitor-reui", "", collectionPath.c_str(), documentPath.c_str(), jsonString.c_str(), "")) {
        Serial.println("Daily log saved: " + collectionPath + "/" + documentPath);
    } else {
        Serial.println("Failed to save log: " + fbdo.errorReason());
    }
}

void listenForPlotChanges() {
  Firebase.RTDB.getString(&fbdo, "SelectedPlot");
  String selectedPlot = fbdo.stringData();

  Serial.print("Selected Plot: ");
  Serial.println(selectedPlot);

  if (selectedPlot == "Plot 1") {
    // Read sensors for Plot 1
    readAndDisplaySensorValues();

  } else if (selectedPlot == "Plot 2") {
    // Read sensors for Plot 2
    readAndDisplaySensorValues();
  }
}

void setup(){
  Serial.begin(115200);
  pinMode(GREEN_LED_PIN, OUTPUT);
  pinMode(RED_LED_PIN, OUTPUT);
    
  digitalWrite(RED_LED_PIN, HIGH);  // Assume system is not ready
  digitalWrite(GREEN_LED_PIN, LOW); // Turn off green LED initially
  
  connectToWiFi();
  setupTime();  // Initialize time

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;
  dht.begin(); //begin dht sens 

  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")){
    Serial.println("ok");
    signupOK = true;
  }
  else{
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}


void loop() {
  fetchPlotFromFirestore();  // Get the selected plot
  listenForPlotChanges();  // Check Firebase for the selected plot
  delay(5000);  // Check every 5 seconds
  
  
  // Storing For Realtime
    if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 2000 || sendDataPrevMillis == 0)) {
        sendDataPrevMillis = millis();
        readAndDisplaySensorValues();
    }

    // Get current time for 
    time_t now = time(nullptr);
    Serial.println(ctime(&now));
    delay(5000); // Print the current time to verify
    struct tm timeInfo;
    localtime_r(&now, &timeInfo);

    int currentHour = timeInfo.tm_hour;
    int currentMinute = timeInfo.tm_min;
    static int lastLoggedMinute = -1;
    static int lastLoggedHour = -1;

    int moisture1 = map(analogRead(sensorPin1), 0, 4095, 100, 0);
    int moisture2 = map(analogRead(sensorPin2), 0, 4095, 100, 0);
    int moisture3 = map(analogRead(sensorPin3), 0, 4095, 100, 0);
    int moisture4 = map(analogRead(sensorPin4), 0, 4095, 100, 0);

    float avgMoisture = (moisture1 + moisture2 + moisture3 + moisture4) / 4.0;
    
    // if (avgMoisture < 40 || moisture1 <40 ||moisture2 <40 ||moisture3 <40 ||moisture4 <40 ) {  // If soil is almost dry
    //     Serial.println("⚠ Warning: Soil is almost dry! Logging to Firestore...");
    //     saveDailyLogToFirestore(dht.readTemperature(), dht.readHumidity(), avgMoisture, moisture1, moisture2, moisture3, moisture4);
    //     delay(5000);  // Avoid excessive logging
    //     logSensorDataToFirestore();
    // }
    // if (moisture1 <40 ||moisture2 <40 ||moisture3 <40 ||moisture4 <40 || ){
    //     Serial.println("One of the sensors are dry! Less than 40% Moisture")
        
    // }

    // **Scheduled logging at specific hours**
    if ((currentHour == 8 || currentHour == 11 || currentHour == 12 ||currentHour == 13 ||currentHour == 14 ||currentHour == 15 || currentHour == 17) &&
        lastLoggedHour != currentHour) {
    lastLoggedHour = currentHour;
    logSensorDataToFirestore();
    Serial.println("📌 Firestore log saved (Scheduled Time).");
}




}

void fetchPlotFromFirestore() {

    if (firestore.getDocument(&fbdo, "test-monitor-reui", "", "selected_plots", "currentPlot", "")) {
        Serial.println("Document fetched successfully");

        FirebaseJson jsonResponse;
        jsonResponse.setJsonData(fbdo.payload().c_str());  // Convert payload to JSON

        FirebaseJsonData jsonData;
        if (jsonResponse.get(jsonData, "fields/plot/stringValue")) {  
            plotID = jsonData.stringValue;  
            Serial.print("Fetched plot ID: ");
            Serial.println(plotID);
        } else {
            Serial.println("Error: Plot ID not found in Firestore response.");
        }
    } else {
        Serial.println("Failed to fetch Firestore document: " + fbdo.errorReason());
    }
}

// Function to log sensor data to Firestore
// Just calling this function inside the loop function
void logSensorDataToFirestore() {
    float temperature = dht.readTemperature();
    float humidity = dht.readHumidity();
    int moisture1 = map(analogRead(sensorPin1), 0, 4095, 100, 0);
    int moisture2 = map(analogRead(sensorPin2), 0, 4095, 100, 0);
    int moisture3 = map(analogRead(sensorPin3), 0, 4095, 100, 0);
    int moisture4 = map(analogRead(sensorPin4), 0, 4095, 100, 0);
    float avgMoisture = (moisture1 + moisture2 + moisture3 + moisture4) / 4.0;
    
    saveDailyLogToFirestore(temperature, humidity, avgMoisture, moisture1, moisture2, moisture3, moisture4, plotID);
    
}
