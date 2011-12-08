/*
  This program listens to the wheel encoders and 
  broadcasts them to the computer as tuples of the form (lEnc,rEnc)
*/

#include <SPI.h>
#include <Mirf.h>
#include <nRF24L01.h>
#include <MirfHardwareSpiDriver.h>

#define MANUAL_MOVE

#define RW 17.9
#define D 12.0
#define TR 12.0

#define PACKET_SIZE 25

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

#define LEDPIN 2

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
  Mirf.payload = PACKET_SIZE;
  
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
  float posX = 0.0f;
  float posY = 0.0f;
  double angle = 0.0f;
  int T1,T2;
  

  int pathCounter = 0;
  int pathLen = 2;
  boolean pathL[] = {true,true,true,true,true,true,true};
  boolean pathR[] = {true,false,true,false,true,false,true};
  int timePath[] = {2000.0,500.0,2000.0,500.0,2000.0,500.0,2000.0};

  int dataRefreshes = 0; //Used to make integration be more averaged

  unsigned long updateTX = 0.0;
  unsigned long updateTY = 0.0;

  unsigned long lastTime = 0.0;
  unsigned long timer = 0.0;
// End Global Var Defs

void setup() {
  setupMirf();
  setupMots();
  setupEncs();

  pinMode(LEDPIN,OUTPUT);
  digitalWrite(LEDPIN,HIGH);

  Mirf.setTADDR((byte *)"mastr");

  Serial.println("Beginning ... "); 
}

boolean digitalModeRead(int pinNum) {
  int acc = 0;
  int count = 5;
  for (int i=0; i<count; i++) {
    acc += digitalRead(pinNum);  
  } 
  return boolean(float(acc)/float(count)+0.5);
  //return digitalRead(pinNum);
}

void updateEncoders() {
  boolean shouldSend = false;
  boolean temp = digitalModeRead(LENC);
  if (lEncPrev != temp) {
    lEncPrev = temp;
    if (temp) {
    #ifndef MANUAL_MOVE
      if (digitalRead(LMOT_0) && !digitalRead(LMOT_1))
        lEncoder ++;
        T1 ++;
      else if (!digitalRead(LMOT_0) && digitalRead(LMOT_1))
        lEncoder --;
        T1 --;
    #else
      lEncoder ++;
      T1 ++;
    #endif
      Serial.print("leftWheel: ");
      Serial.println(millis() - updateTX);
      updateTX = millis();
      shouldSend = true;
    }
  }
  temp = digitalModeRead(RENC);
  if (rEncPrev != temp) {
    rEncPrev = temp;
    if (temp) {
      #ifndef MANUAL_MOVE
        if (digitalRead(RMOT_0) && !digitalRead(RMOT_1))
          rEncoder ++;
          T2 ++;
        else if (!digitalRead(RMOT_0) && digitalRead(RMOT_1))
          rEncoder --;
          T2 --;
      #else
        rEncoder ++;
        T2 ++;
      #endif
        Serial.print("rightWheel: ");
        Serial.println(millis() - updateTY);
        updateTY = millis();
        shouldSend = true;
    }
  }
  if (shouldSend) {
    dataRefreshes ++;
    dataRefreshes %= 1;
    if (!dataRefreshes) {
      updateGlobalPos();
      sendGlobalPosVals();
    }
    //sendEncoderVals();
  }
}

void updateGlobalPos() {  
  posX += RW*cos(angle)*float(T1+T2)*(PI/TR);
  posY += RW*sin(angle)*float(T1+T2)*(PI/TR);
  angle += 2.0*PI*RW/D*float(T1-T2)/TR;
  T1 = 0;
  T2 = 0;
}

void sendGlobalPosVals() {
   if (!Mirf.isSending()) {
    String posData = String("(" + String((int)posX) + "," + String((int)posY) + "," + String((int)(angle*180.0/PI)) + ")");
    Serial.println(posData);

    /*
    Serial.print("(");
    Serial.print(posX);
    Serial.print(",");
    Serial.print(posY);
    Serial.print(",");
    Serial.print(angle);
    Serial.println(")");
    */

    char data[PACKET_SIZE];
    posData.toCharArray(data, PACKET_SIZE);
    Mirf.send((byte*)data);  
  }
}

void sendEncoderVals() {
   if (!Mirf.isSending()) {
    String encoderData = String("(" + String(lEncoder) + "," + String(rEncoder) + ")");
    char data[PACKET_SIZE];
    encoderData.toCharArray(data, PACKET_SIZE);
    Mirf.send((byte*)data); 
    Serial.println(encoderData); 
  }
}

void loop() {
  if ((millis()-lastTime) > timePath[pathCounter]) {
    lastTime = millis();
    pathCounter++;
    pathCounter%=pathLen;
    leftWheel(pathL[pathCounter]);
    rightWheel(pathR[pathCounter]);
  }

  updateEncoders();
  //byte cmd[12];
  
  //while(!Mirf.dataReady()){}
  //Mirf.getData((byte *) &cmd);
    

} 
  
  
  
