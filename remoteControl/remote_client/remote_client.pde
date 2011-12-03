#include <SPI.h>
#include <Mirf.h>
#include <nRF24L01.h>
#include <MirfHardwareSpiDriver.h>

#define LMOT_0 5
#define LMOT_1 6
#define RMOT_0 9
#define RMOT_1 10

#define LENC 4

void setup(){
  
  pinMode(LMOT_0, OUTPUT);
  pinMode(LMOT_1, OUTPUT);
  pinMode(RMOT_0, OUTPUT);
  pinMode(RMOT_1, OUTPUT);
    
  Serial.begin(9600);

  Mirf.spi = &MirfHardwareSpi;
  Mirf.init();
  Mirf.setRADDR((byte *)"LB0");
  Mirf.payload = 2;
  
  Mirf.config();
  
  Serial.println("Beginning ... "); 
  
  digitalWrite(LMOT_0, LOW);
  digitalWrite(LMOT_1, LOW);
  digitalWrite(RMOT_0, LOW);
  digitalWrite(RMOT_1, LOW);
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

void loop(){
  
  byte cmd[2];
  Mirf.setTADDR((byte *)"comp");
  
  //while(Mirf.isSending()){
  //  Serial.println("Sending");
  //}
  //Serial.println("Finished sending");
  
  //while(!Mirf.dataReady()){
  //  Serial.println("Data Not Ready");
  //}
  Mirf.getData((byte *) &cmd);
  
  Serial.println((int)cmd[0]);
  Serial.println((int)cmd[1]);
  
  if (cmd[0] == 'A') {
    leftWheel(true);
  } else {
    leftWheelOff();
  }
  
  if (cmd[1] == 'B') {
    rightWheel(true);
  } else {
    rightWheelOff();
  }


} 
  
  
  
