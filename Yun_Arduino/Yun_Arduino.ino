#include <Ultrasonic.h>
#define TRIGGER_PIN  8
#define ECHO_PIN     9
Ultrasonic ultrasonic(TRIGGER_PIN, ECHO_PIN);

int cellPin = A0;
int cellPin1 = A1;
int cellPin2 = A2;
int cellPin3 = A3;
int cellPin4 = A4;
int cellPin5 = A5;
int cellPin6 = A6;
int cellPin7 = A7;
int cellPin8 = A8;
int cellPin9 = A9;
int cellPin10 = A10;
int cellPin11 = A11;
int cellPin12 = A12;
int cellPin13 = A13;
int cellPin14 = A14;
int cellPin15 = A15;

int photocellVal = 0; // photocell variable
int photocellVal1 = 0;
int photocellVal2 = 0;
int photocellVal3 = 0;
int photocellVal4 = 0;
int photocellVal5 = 0;
int photocellVal6 = 0;
int photocellVal7 = 0;
int photocellVal8 = 0;
int photocellVal9 = 0;
int photocellVal10 = 0;
int photocellVal11 = 0;
int photocellVal12 = 0;
int photocellVal13 = 0;
int photocellVal14 = 0;
int photocellVal15 = 0;
const int trig = 5;
const int ech = 6;
const int inter_time = 1000;
int time = 0;



void setup() {
  Serial.begin(9600);
  pinMode(trig, OUTPUT);
  pinMode(ech, INPUT);
}

void loop() {
  float cmMsec, inMsec;
  int cmN;
  long microsec = ultrasonic.timing();
  cmMsec = ultrasonic.convert(microsec, Ultrasonic::CM); // 計算距離，單位: 公分
  cmN = int(cmMsec);
  
  // 讀取光敏電阻並輸出到 Serial Port 
  photocellVal = analogRead(cellPin);
  photocellVal1 = analogRead(cellPin1);
  photocellVal2 = analogRead(cellPin2);
  photocellVal3 = analogRead(cellPin3);
  photocellVal4 = analogRead(cellPin4);
  photocellVal5 = analogRead(cellPin5);  
  photocellVal6 = analogRead(cellPin6);  
  photocellVal7 = analogRead(cellPin7);
  photocellVal8 = analogRead(cellPin8);  
  photocellVal9 = analogRead(cellPin9); 
  photocellVal10 = analogRead(cellPin10);
  photocellVal11 = analogRead(cellPin11);
  photocellVal12 = analogRead(cellPin12);
  photocellVal13 = analogRead(cellPin13);
  photocellVal14 = analogRead(cellPin14);
  photocellVal15 = analogRead(cellPin15);
    
  Serial.print(photocellVal3);
  Serial.print(",");
  Serial.print(photocellVal2);
  Serial.print(",");
  Serial.print(photocellVal1);
  Serial.print(",");  
  Serial.print(photocellVal);
  Serial.print(",");
  Serial.print(photocellVal7);
  Serial.print(",");
  Serial.print(photocellVal6);
  Serial.print(",");
  Serial.print(photocellVal5);
   Serial.print(",");
  Serial.print(photocellVal4);
   Serial.print(",");
  Serial.print(photocellVal11);
   Serial.print(",");
  Serial.print(photocellVal10);
    Serial.print(",");
  Serial.print(photocellVal9);
    Serial.print(",");
  Serial.print(photocellVal8);
    Serial.print(",");
  Serial.print(photocellVal15);
    Serial.print(",");
  Serial.print(photocellVal14);
    Serial.print(",");
  Serial.print(photocellVal13);
    Serial.print(",");
  Serial.print(photocellVal12);
  Serial.print(",");
   Serial.print(cmN);
     Serial.println(",");
}

