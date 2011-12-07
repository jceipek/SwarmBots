/*
  This program listens to the encoder values from the robot and 
  outputs them to serial as tuples of the form (lEnc,rEnc)
*/

#include <SPI.h>
#include <Mirf.h>
#include <nRF24L01.h>
#include <MirfHardwareSpiDriver.h>

#define PACKET_SIZE 25

void setupMirf() {
  Serial.begin(9600);
  
  Mirf.spi = &MirfHardwareSpi;
  Mirf.init();
  Mirf.setRADDR((byte *)"mastr");
  Mirf.payload = PACKET_SIZE;
  
  Mirf.config();
}

void setup(){
  Serial.begin(9600);
  
  setupMirf();

  Mirf.setTADDR((byte *)"lbot0");
  
  Serial.println("Listening...");
}

void recv() {
  byte data[14];
  if(Mirf.dataReady()){
    Mirf.getData((byte *)&data);
    Serial.println((char*)data); 
  }
}

void loop(){  
  
  recv();

}
