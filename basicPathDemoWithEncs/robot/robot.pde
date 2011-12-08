/*
  This program listens to the wheel encoders and 
  broadcasts them to the computer as tuples of the form (lEnc,rEnc)
*/

#include <SPI.h>
#include <Mirf.h>
#include <nRF24L01.h>
#include <MirfHardwareSpiDriver.h>

#define MANUAL_MOVE

// Begin Motor Macros
  #define LMOT_0 5
  #define LMOT_1 6
  #define RMOT_0 9
  #define RMOT_1 10
// End Motor Macros

// Begin Encoder Macros
  #define LENC 4
  #define RENC 3
// End Encoder Macros

  #define LED 2

void setupMots() {
  pinMode(LMOT_0, OUTPUT);
  pinMode(LMOT_1, OUTPUT);
  pinMode(RMOT_0, OUTPUT);
  pinMode(RMOT_1, OUTPUT);
  
  digitalWrite(LMOT_0, LOW);
  digitalWrite(LMOT_1, LOW);
  digitalWrite(RMOT_0, LOW);
  digitalWrite(RMOT_1, LOW);
}

void setupEncs() {
  pinMode(LENC, INPUT);
  pinMode(RENC, INPUT);
}

void setupMirf() {
  Serial.begin(9600);
  
  Mirf.spi = &MirfHardwareSpi;
  Mirf.init();
  Mirf.setRADDR((byte *)"lbot0");
  Mirf.payload = 14;
  
  Mirf.config();
}

void leftWheel(boolean dir) {
  digitalWrite(LMOT_0, dir);
  digitalWrite(LMOT_1, !dir);
}

void rightWheel(boolean dir) {
  digitalWrite(RMOT_0, dir);
  digitalWrite(RMOT_1, !dir);
}

void leftWheelOff() {
  digitalWrite(LMOT_0, LOW);
  digitalWrite(LMOT_1, LOW);
}

void rightWheelOff() {
  digitalWrite(RMOT_0, LOW);
  digitalWrite(RMOT_1, LOW);
}

// Global Vars
  int lEncoder = 0;
  int rEncoder = 0;
  boolean lEncPrev;
  boolean rEncPrev;

  int pathCounter = 0;
  int pathLen = 16;
  
  #define RROTATE 0
  #define LROTATE 1
  #define MOVE 2
  #define LIGHT 3

  #define TURN_CIRC PI*12.0
  #define WHEEL_SEP 12.0
  #define ENC_COUNT 12.0
  #define WHEEL_CIRC 17.9

  #define UNIT_DIST 400.0
  #define QUART PI/2.0

  byte pathBehavior[] = {MOVE,LROTATE,MOVE,LROTATE,MOVE,RROTATE,MOVE,RROTATE,MOVE,LROTATE,MOVE,RROTATE,MOVE,RROTATE,MOVE,LIGHT}; //List of behaviors (ROTATE or MOVE)
  float pathAmount[] = {UNIT_DIST,QUART,UNIT_DIST*0.75,QUART,  UNIT_DIST,QUART*1.5,UNIT_DIST/2.0,QUART,UNIT_DIST/2.0,QUART,UNIT_DIST/2.0,QUART,UNIT_DIST/2.0,QUART*1.5,UNIT_DIST/2.0,0.0}; // List of angles (in radians) or distances to travel (in cm)

  unsigned long lastTime = 0.0;
// End Global Var Defs

boolean hasCoveredDist(float dist) {
  return (abs(lEncoder)+abs(rEncoder)/2.0)*WHEEL_CIRC >= dist;
}

boolean hasTurnedAngle(float radAngle) {
  return (abs(lEncoder)+abs(rEncoder))/2.0 >= (radAngle/(2.0*PI)*TURN_CIRC)/(WHEEL_CIRC/ENC_COUNT);
}

void resetEncs() {
  lEncoder = 0;
  rEncoder = 0;
}

void setup() {
  setupMirf();
  setupMots();
  setupEncs();

  Mirf.setTADDR((byte *)"mastr");


  pinMode(LED,OUTPUT);
  digitalWrite(LED,HIGH);
  Serial.println("Beginning ... "); 
}

void updateEncoders() {
  boolean temp = digitalRead(LENC);
  if (lEncPrev != temp) {
    lEncPrev = temp;
    if (temp) {
    #ifndef MANUAL_MOVE
      if (digitalRead(LMOT_0) && !digitalRead(LMOT_1))
        lEncoder ++;
      else if (!digitalRead(LMOT_0) && digitalRead(LMOT_1))
        lEncoder --;
    #else
      lEncoder ++;
    #endif
    sendEncoderVals();
    }
  }
  temp = digitalRead(RENC);
  if (rEncPrev != temp) {
    rEncPrev = temp;
    if (temp) {
      #ifndef MANUAL_MOVE
        if (digitalRead(RMOT_0) && !digitalRead(RMOT_1))
          rEncoder ++;
        else if (!digitalRead(RMOT_0) && digitalRead(RMOT_1))
          rEncoder --;
      #else
        rEncoder ++;
      #endif
      sendEncoderVals();
    }
  }  
}

void sendEncoderVals() {
   if (!Mirf.isSending()) {
    String encoderData = String("(" + String(lEncoder) + "," + String(rEncoder) + ")");
    char data[14];
    encoderData.toCharArray(data, 14);
    Mirf.send((byte*)data);  
  }
}

void loop() {

  if (pathCounter < pathLen) {
    if (pathBehavior[pathCounter] == LROTATE) {
      leftWheel(false);
      rightWheel(true);
      if(hasTurnedAngle(pathAmount[pathCounter])) {
        resetEncs();
        leftWheelOff();
        rightWheelOff();
        pathCounter++;
      } 
    } else if (pathBehavior[pathCounter] == RROTATE) {
      leftWheel(true);
      rightWheel(false);
      if(hasTurnedAngle(pathAmount[pathCounter])) {
        resetEncs();
        leftWheelOff();
        rightWheelOff();
        pathCounter++;
      } 
    } else if (pathBehavior[pathCounter] == MOVE) {
      leftWheel(false);
      rightWheel(false);
      if(hasCoveredDist(pathAmount[pathCounter])) {
        resetEncs();
        leftWheelOff();
        rightWheelOff();
        pathCounter++;
      }
    } else if (pathBehavior[pathCounter] == LIGHT) {
      digitalWrite(LED,int(pathAmount[pathCounter]));
    }
  }

  updateEncoders();
  //byte cmd[12];
  
  //while(!Mirf.dataReady()){}
  //Mirf.getData((byte *) &cmd);
    
  Serial.println("(" + String(lEncoder) + "," + String(rEncoder) + ")");

} 
  
  
  
