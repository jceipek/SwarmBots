#include <SPI.h>
#include <Mirf.h>
#include <nRF24L01.h>
#include <MirfHardwareSpiDriver.h>

#define LMOT_0 5
#define LMOT_1 6
#define RMOT_0 9
#define RMOT_1 10

#define LENC 4
#define RENC 3

int lEncoder = 0;
int rEncoder = 0;
  
boolean lEncPrev;
boolean rEncPrev;

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

void updateEncoders() {
  boolean temp = digitalRead(LENC);
  if (lEncPrev != temp) {
    lEncPrev = temp;
    if (temp)
    lEncoder ++;
  }
  temp = digitalRead(RENC);
  if (rEncPrev != temp) {
    rEncPrev = temp;
    if (temp)
    rEncoder ++;
  }  
}

void setup(){
  
  pinMode(LMOT_0, OUTPUT);
  pinMode(LMOT_1, OUTPUT);
  pinMode(RMOT_0, OUTPUT);
  pinMode(RMOT_1, OUTPUT);
    
  Serial.begin(9600);

  Mirf.spi = &MirfHardwareSpi;
  Mirf.init();
  Mirf.setRADDR((byte *)"clie1");
  Mirf.payload = sizeof(int);
  
  Mirf.config();
  
  Serial.println("Beginning ... "); 
  
  rightWheelOff();
  leftWheelOff();
  //leftWheel(true);
}

void loop(){
  
  updateEncoders();
  Mirf.setTADDR((byte *)"serv1");
  
  Serial.println(lEncoder);
  Mirf.send((byte*)&lEncoder);
  while(Mirf.isSending()){
    updateEncoders();
  //  Serial.println("Sending");
  }
  //Serial.println("Finished sending");

} 
  
  
  
