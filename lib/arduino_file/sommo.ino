#define GREEN_LED_PIN 26  // Change to GPIO 26
#define RED_LED_PIN 27    // Change to GPIO 27

#define DHTPIN 4     // new added - GPIO4 (can be any digital pin)
#define DHTTYPE DHT22   //new added - DHT 22 (AM2302)
#include <ArduinoJson.h>


#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <time.h>  // Built-in ESP32 time library
#include <Firebase_ESP_Client.h>

#include "SPIFFS.h"

//Provide the token generation process info.
#include "addons/TokenHelper.h"
//Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

#include <DHT.h> //new added



const char* wifiList[][3] PROGMEM = {
  {"HG8145V5_D400A", "jcww2myE"},
  {"DITO-", "antoi12345678910"},
  {"TECNNO CAMON 20 Pro", "vidallo12345"},
  //{"HG8145V5_D400A", "jcww2myE"},
  // {"Joanna's iPhone", "jm123456789"},
  // {"Kaida", "Kaida123"},
  // {"Sigesige", "SIGELANG"},
  // {"HUAWEI-D8kG", "ana@36546"},
  // {"Sigesige", "SIGELANG"},
  // {"Kaida", "Kaida123"},
  // {"HG8145V5_D400A", "jcww2myE"},-+
  // {"HUAWEI-D8kG", "ana@36546"},

  // {"Carlo", "carlfrancis0205"},
};
const int numNetworks = sizeof(wifiList) / sizeof(wifiList[0]);

#define API_KEY "AIzaSyA_lQLKsXD_SGL4QyEVO3HEFUgJUcQW0sQ"
#define DATABASE_URL "https://test-monitor-reui-default-rtdb.asia-southeast1.firebasedatabase.app/"

//Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
FB_Firestore firestore;


unsigned long sendDataPrevMillis = 0;
int count = 0;
bool signupOK = false;

const int sensorPin1 = 34;  // Soil moisture sensor connected to GPIO 34
const int sensorPin2 = 35;
const int sensorPin3 = 33;
const int sensorPin4 = 32;
String plotID;  // Declare globally



// Calibration values based on your tests
// const int dryValue1 = 2480, wetValue1 = 580;
// const int dryValue2 = 2475, wetValue2 = 600;
// const int dryValue3 = 2480, wetValue3 = 660;
// const int dryValue4 = 2430, wetValue4 = 600;

const int dryValue1 = 2430, wetValue1 = 600;
const int dryValue2 = 2430, wetValue2 = 600;
const int dryValue3 = 2430, wetValue3 = 600;
const int dryValue4 = 2430, wetValue4 = 600;


// Initialize the DHT sensor
DHT dht(DHTPIN, DHTTYPE);


void checkInternetConnection() {
    HTTPClient http;
    http.begin("http://clients3.google.com/generate_204"); // Google test URL
    int httpCode = http.GET();
    if (httpCode > 0) {
        Serial.println("✅ Internet access confirmed!");
        digitalWrite(GREEN_LED_PIN, HIGH);
        digitalWrite(RED_LED_PIN, LOW);
    } else {
        Serial.println("⚠️ WiFi connected but NO INTERNET!");
        digitalWrite(GREEN_LED_PIN, HIGH);
        digitalWrite(RED_LED_PIN, HIGH);  // Both LEDs ON
    }
    http.end();
}

void connectToWiFi() {
    WiFi.mode(WIFI_STA);
    pinMode(GREEN_LED_PIN, OUTPUT);
    pinMode(RED_LED_PIN, OUTPUT);
    digitalWrite(GREEN_LED_PIN, LOW);
    digitalWrite(RED_LED_PIN, HIGH); // Default: Red LED ON (Not Connected)

    for (int i = 0; i < numNetworks; i++) {
        Serial.print("Trying to connect to: ");
        Serial.println(wifiList[i][0]);

        WiFi.begin(wifiList[i][0], wifiList[i][1]);
        int attempts = 20;
        while (WiFi.status() != WL_CONNECTED && attempts > 0) {
            delay(1000);
            Serial.print(".");
            attempts--;
        }

        if (WiFi.status() == WL_CONNECTED) {
            Serial.println("\n✅ Connected to WiFi!");
            Serial.print("IP Address: ");
            Serial.println(WiFi.localIP());
            checkInternetConnection();
            checkStoredLogs();  // Send stored data
            return;
        }
    }

    Serial.println("⚠️ Could not connect to any WiFi. Retrying in 10 seconds...");
    delay(10000);
    ESP.restart();
}



float averageMoisture(int readings[], int count) {
  float sum = 0;
  for (int i = 0; i < count; i++) {
    sum += readings[i];
  }
  return sum / count;  // Return the average
}

unsigned long lastLogTime = 0;  // Track last log time
const unsigned long logInterval = 30 * 60 * 1000;  // Log every 30 minutes (adjust as needed)

bool lowMoistureLogged = false;  // Flag to prevent duplicate logs

void readAndDisplaySensorValues() {
    int moisture1 = analogRead(sensorPin1);
    int moisture2 = analogRead(sensorPin2);
    int moisture3 = analogRead(sensorPin3);
    int moisture4 = analogRead(sensorPin4);

    int moisturePercent1 = map(moisture1, dryValue1, wetValue1, 0, 100);
    int moisturePercent2 = map(moisture2, dryValue2, wetValue2, 0, 100);
    int moisturePercent3 = map(moisture3, dryValue3, wetValue3, 0, 100);
    int moisturePercent4 = map(moisture4, dryValue4, wetValue4, 0, 100);

    moisturePercent1 = constrain(moisturePercent1, 0, 100);
    moisturePercent2 = constrain(moisturePercent2, 0, 100);
    moisturePercent3 = constrain(moisturePercent3, 0, 100);
    moisturePercent4 = constrain(moisturePercent4, 0, 100);

    float temperature = dht.readTemperature();  
    float humidity = dht.readHumidity();  

    int moistureReadings[] = { moisturePercent1, moisturePercent2, moisturePercent3, moisturePercent4 };
    float averageMoistureLevel = averageMoisture(moistureReadings, 4);

    // Store real-time data in Firebase RTDB
    Firebase.RTDB.setInt(&fbdo, "Moisture/MoistureReadings_1", moisturePercent1);
    Firebase.RTDB.setInt(&fbdo, "Moisture/MoistureReadings_2", moisturePercent2);
    Firebase.RTDB.setInt(&fbdo, "Moisture/MoistureReadings_3", moisturePercent3);
    Firebase.RTDB.setInt(&fbdo, "Moisture/MoistureReadings_4", moisturePercent4);
    Firebase.RTDB.setFloat(&fbdo, "Moisture/Average", averageMoistureLevel);
    Firebase.RTDB.setFloat(&fbdo, "Temperature/temperature", temperature);
    Firebase.RTDB.setFloat(&fbdo, "Humidity/humidity", humidity);

    Serial.printf("Moisture: %d%%, %d%%, %d%%, %d%% | Avg: %.2f%%\n", moisturePercent1, moisturePercent2, moisturePercent3, moisturePercent4, averageMoistureLevel);
    Serial.printf("Temp: %.2f°C | Humidity: %.2f%%\n", temperature, humidity);

    // **Prevent Excessive Logging in Firestore**
    unsigned long currentMillis = millis();

    bool isDry = (moisturePercent1 >=10 && moisturePercent1 < 35 || moisturePercent2 >=10 && moisturePercent2 < 35 ||moisturePercent3 >=10 && moisturePercent3 < 35 ||moisturePercent4 >=10 && moisturePercent4 < 35);
    static bool wasDry = false;

if (isDry && (currentMillis - lastLogTime > logInterval || !lowMoistureLogged || !wasDry)) {
    Serial.println("⚠️ Logging dry soil condition to Firestore...");
    String selectedPlot = getSelectedPlot();
    saveDailyLogToFirestore(temperature, humidity, averageMoistureLevel, moisturePercent1, moisturePercent2, moisturePercent3, moisturePercent4, selectedPlot);

    lastLogTime = currentMillis;
    lowMoistureLogged = true;
    wasDry = true;  // Mark as previously dry
}

// Reset when soil becomes moist again
if (!isDry) {
    lowMoistureLogged = false;
    wasDry = false;
}

}

 //new added

 

// Firestore starts here!!!!!!!
// This for setting the time no need na sa RTC component instead we using network time protocol
void setupTime() {
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("⚠️ WiFi not connected! Cannot sync time.");
        return;
    }

    Serial.println("⏳ Syncing time...");
    configTime(8 * 3600, 0, "pool.ntp.org", "time.google.com", "asia.pool.ntp.org");

    time_t now = time(nullptr);
    int attempts = 15;  // Increase attempts to allow more time

    while (now < 1000000000 && attempts > 0) { // Check if time is reasonable
        Serial.println("⌛ Waiting for NTP sync...");
        delay(5000);
        now = time(nullptr);
        attempts--;
    }
    
    if (now < 1000000000) {
        Serial.println("❌ Failed to get time from NTP! Retrying in 10s...");
        delay(10000);
        ESP.restart(); // Restart ESP32 if NTP fails
    } else {
        Serial.println("✅ Time synchronized successfully!");
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

String getSelectedPlot() {
    String selectedPlot;
    if (Firebase.RTDB.getString(&fbdo, "SelectedPlot/plotName")) {
        selectedPlot = fbdo.stringData();
      //  Serial.println("Selected Plot: " + selectedPlot); 
    } else {
        Serial.println("Failed to get selected plot: " + fbdo.errorReason());
        selectedPlot = "Plot1";  // Default to Plot1 if failed
    }
    return selectedPlot;
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
if (now < 1000000000) {
    Serial.println("⚠️ Time not synchronized! Skipping log.");
    return; // Prevent logging until time is correct
}

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
    json.set("fields/timestamp/timestampValue", isoTime);
    json.set("fields/temperature/doubleValue", temperature);
    json.set("fields/humidity/doubleValue", humidity);
    json.set("fields/average_moisture/doubleValue", avgMoisture);
    json.set("fields/moisture_1/integerValue", moisture1);
    json.set("fields/moisture_2/integerValue", moisture2);
    json.set("fields/moisture_3/integerValue", moisture3);
    json.set("fields/moisture_4/integerValue", moisture4);


    String jsonString;
    json.toString(jsonString, true);

    // Firestore path: "Plots/{selectedPlot}/sensorData/{dateString}/{timeString}"
    String collectionPath = "Plots/" + selectedPlot + "/sensorData";
    String documentPath = dateString + "_" + timeString; // Ensures valid document ID

    // Creating document and collection logs to the firestore
    if(WiFi.status() == WL_CONNECTED) {
      if (firestore.createDocument(&fbdo, "test-monitor-reui", "", collectionPath.c_str(), documentPath.c_str(), jsonString.c_str(), "")) {
        Serial.println("Daily log saved: " + collectionPath + "/" + documentPath);
      } else {
        Serial.println("Failed to save log: " + fbdo.errorReason());
    }
  } else {
    Serial.println("🚫 No internet! Storing data locally.");
        storeDataLocally(json);
  }
    
}


void storeDataLocally(FirebaseJson json) {
    if (!SPIFFS.begin(true)) {
        Serial.println("⚠️ SPIFFS Initialization Failed!");
        return;
    }

    File file = SPIFFS.open("/offline_logs.txt", FILE_APPEND);
    if (!file) {
        Serial.println("❌ Failed to open file for writing.");
        return;
    }

    String jsonString;
    json.toString(jsonString, true);
    file.println(jsonString);
    file.close();

    Serial.println("📂 Data stored locally for retry.");
}

void checkStoredLogs() {
    if (!SPIFFS.begin(true)) {
        Serial.println("⚠️ SPIFFS Init Failed!");
        return;
    }

    File file = SPIFFS.open("/offline_logs.txt", FILE_READ);
    if (!file) {
        Serial.println("📂 No offline logs found.");
        return;
    }

    Serial.println("📡 Attempting to send stored logs...");
    String jsonString;

    // Get selected plot
    String selectedPlot = getSelectedPlot();
     // Get current date and time
    String dateString = getDateString();
    String timeString = getTimeString();  
    String collectionPath = "Plots/" + selectedPlot + "/sensorData";
    String documentPath = dateString + "_" + timeString; // Ensures valid document ID
    while (file.available()) {
        String line = file.readStringUntil('\n');
        FirebaseJson json;
        json.setJsonData(line);
        
        
        if (firestore.createDocument(&fbdo, "test-monitor-reui", "", collectionPath.c_str(), documentPath.c_str(), jsonString.c_str(), "")) {
        Serial.println("Daily log saved: " + collectionPath + "/" + documentPath);
      } else {
            Serial.println("❌ Failed to send stored log.");
            return;
        }
    }

    file.close();
    SPIFFS.remove("/offline_logs.txt");  // Clear file after successful upload
    Serial.println("📂 Offline logs cleared.");
}


void listenForPlotChanges() {
  Firebase.RTDB.getString(&fbdo, "SelectedPlot");
  String selectedPlot = fbdo.stringData();

  Serial.print("Selected Plot: ");
  Serial.println(selectedPlot);

  if (selectedPlot == "Lettuce") {
    // Read sensors for Plot 1
    readAndDisplaySensorValues();

  } else if (selectedPlot == "Pechay") {
    // Read sensors for Plot 2
    readAndDisplaySensorValues();
  }
}

void setup(){
  Serial.begin(115200);
  Serial.println(ESP.getFreeHeap());

  pinMode(GREEN_LED_PIN, OUTPUT);
  pinMode(RED_LED_PIN, OUTPUT);
    
  digitalWrite(RED_LED_PIN, HIGH);  // Assume system is not ready
  digitalWrite(GREEN_LED_PIN, LOW); // Turn off green LED initially
  Firebase.begin(&config, &auth);
    
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


unsigned long lastUpdate = 0;
const int updateInterval = 2000; // Update every 2 seconds


void loop() {
  
  listenForPlotChanges();  // Check Firebase for the selected plot
  checkInternetConnection();

  if (millis() - lastUpdate >= updateInterval) {
        readAndDisplaySensorValues(); // Send data to Firebase
        lastUpdate = millis();
  }
    
    Serial.print("Firebase Error: ");
    Serial.println(fbdo.errorReason());

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

     int moisture1 = analogRead(sensorPin1);
    int moisture2 = analogRead(sensorPin2);
    int moisture3 = analogRead(sensorPin3);
    int moisture4 = analogRead(sensorPin4);
    int moisturePercent1 = map(moisture1, dryValue1, wetValue1, 0, 100);
    int moisturePercent2 = map(moisture2, dryValue2, wetValue2, 0, 100);
    int moisturePercent3 = map(moisture3, dryValue3, wetValue3, 0, 100);
    int moisturePercent4 = map(moisture4, dryValue4, wetValue4, 0, 100);

   // Ensure values stay between 0% and 100%
    moisturePercent1 = constrain(moisturePercent1, 0, 100);
    moisturePercent2 = constrain(moisturePercent2, 0, 100);
    moisturePercent3 = constrain(moisturePercent3, 0, 100);
    moisturePercent4 = constrain(moisturePercent4, 0, 100);

    // **Scheduled logging at specific hours**
    if ((currentHour == 8 || currentHour == 11 || currentHour == 12 ||currentHour == 13 ||
    currentHour == 14 ||currentHour == 15 || currentHour == 17 || currentHour == 18 || currentHour == 19 || currentHour == 20
    || currentHour == 21 || currentHour == 22 || currentHour == 23 || currentHour == 24 || currentHour == 3 || currentHour == 4 || currentHour == 5 || currentHour == 6 ) &&
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
   int moisture1 = analogRead(sensorPin1);
    int moisture2 = analogRead(sensorPin2);
    int moisture3 = analogRead(sensorPin3);
    int moisture4 = analogRead(sensorPin4);
    int moisturePercent1 = map(moisture1, dryValue1, wetValue1, 0, 100);
    int moisturePercent2 = map(moisture2, dryValue2, wetValue2, 0, 100);
    int moisturePercent3 = map(moisture3, dryValue3, wetValue3, 0, 100);
    int moisturePercent4 = map(moisture4, dryValue4, wetValue4, 0, 100);

   // Ensure values stay between 0% and 100%
    moisturePercent1 = constrain(moisturePercent1, 0, 100);
    moisturePercent2 = constrain(moisturePercent2, 0, 100);
    moisturePercent3 = constrain(moisturePercent3, 0, 100);
    moisturePercent4 = constrain(moisturePercent4, 0, 100);
    float avgMoisture = (moisturePercent1 + moisturePercent2 + moisturePercent3 + moisturePercent4) / 4.0;
    saveDailyLogToFirestore(temperature, humidity, avgMoisture, 
                        moisturePercent1, moisturePercent2, 
                        moisturePercent3, moisturePercent4, getSelectedPlot());

}