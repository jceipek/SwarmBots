#include <SPI.h>
#include <Mirf.h>
#include <nRF24L01.h>
#include <MirfHardwareSpiDriver.h>

void setup(){
  Serial.begin(9600);
  
  Mirf.spi = &MirfHardwareSpi;
  Mirf.init();
  Mirf.setRADDR((byte *)"comp"); 
  Mirf.payload = 3; //Message length in bytes
     
  Mirf.config();
  
  Serial.println("Listening..."); 
}

void recv() {
  byte data[Mirf.payload];
  if(!Mirf.isSending() && Mirf.dataReady()){
    Serial.println("Got packet");
    Mirf.getData(data);
    
    //Serial.println((String)data); 
    
    //Mirf.setTADDR((byte *)"lb0");
    //Mirf.send(data);  
    //Serial.println("Reply sent.");
  }
}

void loop(){
  byte sendData[] = "BB";
  
  Mirf.setTADDR((byte *)"lb0");
  sendData[0] = 'A';
  sendData[1] = 'A';
  Mirf.send((byte *)&sendData);
  Serial.println("First");
  while(Mirf.isSending()){
  }
  
  delay(1000);


  Mirf.setTADDR((byte *)"LB0");
  sendData[0] = 'B';
  sendData[1] = 'B';
  Mirf.send((byte *)&sendData);
  Serial.println("Second");
  while(Mirf.isSending()){
  }
  
  delay(1000);
  
  recv();

}
