#include <SPI.h>
#include <Mirf.h>
#include <nRF24L01.h>
#include <MirfHardwareSpiDriver.h>

void setup(){
  Serial.begin(9600);
  
  Mirf.spi = &MirfHardwareSpi;
  Mirf.init();
  Mirf.setRADDR((byte *)"serv1"); 
  Mirf.payload = sizeof(int); //Message length in bytes
     
  Mirf.config();
  
  Serial.println("Listening..."); 
}

void recv() {
  int data;
  if(Mirf.dataReady()){
    Serial.println("Got packet");
    Mirf.getData((byte *)&data);
    Serial.println(data); 
  }
}

void loop(){  
  Mirf.setTADDR((byte *)"clie1");
  
  recv();

}
