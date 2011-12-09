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
  int lightCounter = 0;
  boolean distCovered = false;
  
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

// End Global Var Defs

int pathLen = 6;

byte lightPath[] = {
  6
};

float xPath[] = {
  86.8571376,
  397.714288,
  676.57144,
  6.8571424,
  784.0,
  86.8571376
};

float yPath[] = {
  747.428576,
  27.4285712,
  736.0,
  326.857136,
  326.857152,
  747.428576
};

/*
int pathLen = 5;
byte lightPath[] = {
  2,3
};

float xPath[] = {
  0.0, 800.0, 800.0, 0.0, 0.0 

};

float yPath[] = {
  0.0, 0.0, 800.0, 800.0, 0.0
};*/

boolean hasCoveredDist(float dist) {
  return (abs(lEncoder)+abs(rEncoder)/24.0)*WHEEL_CIRC >= dist;
}

boolean hasTurnedAngle(float radAngle) {
  boolean tmpVr = (((abs(lEncoder)+abs(rEncoder))/2.0) >= (radAngle/(2.0*PI)*TURN_CIRC)/(WHEEL_CIRC/ENC_COUNT));
  return tmpVr;
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


  /*  Serial.print("LENC:");
  Serial.println(lEncoder);
  Serial.print("RENC:");
  Serial.println(rEncoder);*/
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

    if (!distCovered) {

      float dist = sqrt(sq(xPath[pathCounter+1]-xPath[pathCounter])+sq(yPath[pathCounter+1]-yPath[pathCounter]));

      if (hasCoveredDist(dist)) {
        distCovered = true;
        //Serial.println("Completed Movement stage.");
        leftWheelOff();
        rightWheelOff();
        resetEncs();

        if (pathCounter == lightPath[lightCounter]) {
          digitalWrite(LED,LOW);
          lightCounter++;
          //Serial.print("LIGHTCOUNTER:");
          //Serial.println(lightCounter);
        } else {
          digitalWrite(LED,HIGH);
        }

      } else {
        leftWheel(false);
        rightWheel(false);
      }

    }
    
   // Serial.print("DIST COVERED?");
   // Serial.println((int)distCovered);
   // Serial.print("2<?");
   // Serial.println((pathLen - pathCounter > 2));

    if (distCovered && (pathLen - pathCounter > 2)) {
      float Ax,Ay,Bx,By;

      Ax = xPath[pathCounter+1] - xPath[pathCounter];
      Ay = yPath[pathCounter+1] - yPath[pathCounter];
      Bx = xPath[pathCounter+2] - xPath[pathCounter+1];
      By = yPath[pathCounter+2] - yPath[pathCounter+1];

      float Amag = sqrt(sq(Ax)+sq(Ay));
      float Bmag = sqrt(sq(Bx)+sq(By));

      float inside = ((Ax * Bx)+(Ay * By))/(Amag * Bmag);

      float angle = acos(inside);


     /* Serial.print("Ax");
      Serial.println(Ax);
      Serial.print("Ay");
      Serial.println(Ay);
      Serial.print("Bx");
      Serial.println(Bx);
      Serial.print("By");
      Serial.println(By);

      Serial.print("Amag");
      Serial.println(Amag);
      Serial.print("Bmag");
      Serial.println(Bmag);


      Serial.print("             ");
      Serial.println(acos(inside));


      Serial.print("INSIDE:");
      Serial.println(inside);*/

      if (hasTurnedAngle(angle)) {
        leftWheelOff();
        rightWheelOff();
        resetEncs();
        pathCounter++;
          //Serial.print("PATHCOUNTER:");
          //Serial.println(pathCounter);
        distCovered = false;
        //Serial.println("Completed Turning stage.");
      } else {
          //TODO: Turn correct direction (based on sign of desired) 

          
        if ((Ax*By)-(Ay*Bx)<0) {
          //Right turn  
          leftWheel(true);
          rightWheel(false);

        } else {
          //Left turn
          leftWheel(false);
          rightWheel(true);
        }

      } 
    
    } else if (distCovered && (pathLen - pathCounter <= 2)){
      //Serial.println("THIS IS THE END");
        pathCounter ++;
        leftWheelOff();
        rightWheelOff();
        resetEncs();
    }
    
  }

  updateEncoders();
  //byte cmd[12];
  
  //while(!Mirf.dataReady()){}
  //Mirf.getData((byte *) &cmd);
    
  //Serial.println("(" + String(lEncoder) + "," + String(rEncoder) + ")");

} 
  
  
  
