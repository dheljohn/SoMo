#include <ArduinoJson.h>
#include <Arduino.h>
#include <WiFi.h>
#include "SD.h"   // ESP32's SD library
#include <TimeLib.h>  // Time library to get timestamps
#include <time.h>  // Built-in ESP32 time library
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
#include <DHT.h> //new added


#define GREEN_LED_PIN 26  // Change to GPIO 26
#define RED_LED_PIN 27    // Change to GPIO 27
#define DHTPIN 4     // new added - GPIO4 (can be any digital pin)
#define DHTTYPE DHT22   //new added - DHT 22 (AM2302)
#define API_KEY "AIzaSyA_lQLKsXD_SGL4QyEVO3HEFUgJUcQW0sQ"
#define DATABASE_URL "https://test-monitor-reui-default-rtdb.asia-southeast1.firebasedatabase.app/"


//Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
FirebaseJson doc; 
FB_Firestore firestore;


const char* wifiList[][3] = {
  {"HG8145V5_D400A", "jcww2myE"},
  {"HG8145V5_D400A", "jcww2myE"},
  {"HUAWEI-D8kG", "ana@36546"},
  {"HG8145V5_D400A", "jcww2myE"},
  {"Carlo", "carlfrancis0205"},
  {"Kaida", "Kaida123"},
  {"Hotspot", "12468642369485"},
  {"VILLA", "arielvillajr."},
  {"TECNNO CAMON 20 Pro", "vidallo12345"},
  {"CCT2-512", "ccthospes2019"},
  {"HG8145V5_D400A", "jcww2myE"},

};
const int numNetworks = sizeof(wifiList) / sizeof(wifiList[0]);



unsigned long sendDataPrevMillis = 0;
int count = 0;
bool signupOK = false;

int sensorPin1 = 34;  // Soil moisture sensor connected to GPIO 34
int sensorPin2 = 35;
int sensorPin3 = 33;
int sensorPin4 = 32;



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

  // Calculate average moisture
  int moistureReadings[] = {
    moisturePercent1, 
    moisturePercent2, 
    moisturePercent3, 
    moisturePercent4
    };

  float averageMoistureLevel = averageMoisture(moistureReadings, 4);

  // Display the values on the Serial Monitor
  if (Firebase.RTDB.setInt(&fbdo, "Moisture/MoistureReadings_1", moisturePercent1)){
    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    } 

    if (Firebase.RTDB.setInt(&fbdo, "Moisture/MoistureReadings_2", moisturePercent2)){

      
    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    } 
    if (Firebase.RTDB.setInt(&fbdo, "Moisture/MoistureReadings_3", moisturePercent3)){

      
    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    } 

    if (Firebase.RTDB.setInt(&fbdo, "Moisture/MoistureReadings_4", moisturePercent4)){
      
    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    } 

    if (Firebase.RTDB.setFloat(&fbdo, "Moisture/Average", averageMoistureLevel)){

      
    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    } 


    if (Firebase.RTDB.setFloat(&fbdo, "Temperature/temperature", temperature)){

    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    } 

    if (Firebase.RTDB.setFloat(&fbdo, "Humidity/humidity", humidity)){

      
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
        Serial.println(" ✅ Time synchronized!");
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

String getSelectedPlot() {
    String selectedPlot;
    if (Firebase.RTDB.getString(&fbdo, "SelectedPlot/plotName")) {
        selectedPlot = fbdo.stringData();
        Serial.println("Selected Plot: " + selectedPlot); 
    } else {
        Serial.println("Failed to get selected plot: " + fbdo.errorReason());
        selectedPlot = "Plot1";  // Default to Plot1 if failed
    }
    return selectedPlot;
}


bool shouldLogNow() {
    time_t now = time(nullptr);
    struct tm timeInfo;
    localtime_r(&now, &timeInfo);
    
    int hour = timeInfo.tm_hour;
    int minute = timeInfo.tm_min;

    // Log only at 8 AM, 11 AM, 3 PM, and 5 PM
    return (hour == 8 || hour == 11 || hour == 15 || hour == 17) && minute == 0;
}


 void saveDailyLogToFirestore(float temperature, float humidity, float avgMoisture, 
                             int moisture1, int moisture2, int moisture3, int moisture4) {

    if (!shouldLogNow()) {
        Serial.println("Skipping log - Not the scheduled time.");
        return;
    }
    
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

    // Get selected plot
    String selectedPlot = getSelectedPlot();

    json.set("fields/plot/stringValue", selectedPlot);
    json.set("fields/timestamp/timestampValue", isoTime);  // ✅ Correct
    json.set("fields/temperature/doubleValue", temperature);
    json.set("fields/humidity/doubleValue", humidity);
    json.set("fields/average_moisture/doubleValue", avgMoisture);
    json.set("fields/moisture_1/integerValue", moisture1);
    json.set("fields/moisture_2/integerValue", moisture2);
    json.set("fields/moisture_3/integerValue", moisture3);
    json.set("fields/moisture_4/integerValue", moisture4);

    String jsonString;
    json.toString(jsonString, true);

    // Ensure correct Firestore project ID
    String projectID = "test-monitor-reui";  // Update this if needed

    // Firestore path: "Plots/{selectedPlot}/sensorData/{dateString}/{timeString}"
    String collectionPath = "Plots/" + selectedPlot + "/sensorData";
    String documentPath = dateString + "_" + timeString; // Ensures valid document ID

    // bool success = firestore.createDocument(&fbdo, projectID, collectionPath, documentPath, json);
    Serial.println("Trying to save Firestore document...");
    Serial.println("Collection: " + collectionPath);
    Serial.println("Document: " + documentPath);

    // Check if the collection exists (optional, but useful for debugging)
    if (!firestore.createDocument(&fbdo, projectID, "", collectionPath.c_str(), documentPath.c_str(), jsonString.c_str(), "")) {
        Serial.println("❌ Firestore write failed: " + fbdo.errorReason());
    } else {
        Serial.println("✅ Data saved to Firestore: " + collectionPath + "/" + documentPath);
    }
}

unsigned long lastLogTime = 0;
const unsigned long logInterval = 60000;  // Set interval to 60 seconds (adjust as needed)


void loop() {
  
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


    // **Scheduled logging at specific hours**
    if ((currentHour == 8 || currentHour == 11 || currentHour == 12 || 
    currentHour == 13 ||currentHour == 14 ||currentHour == 15 || currentHour == 17) &&
        lastLoggedHour != currentHour) {
    lastLoggedHour = currentHour;
    logSensorDataToFirestore();
    Serial.println("📌 Firestore log saved (Scheduled Time).");
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
    
    saveDailyLogToFirestore(temperature, humidity, avgMoisture, moisture1, moisture2, moisture3, moisture4);
    
}
