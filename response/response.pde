#include <string.h>

int a;
String in;
char last = '\0';

void setup() {
  Serial.begin(9600);
}

void loop() {
  a = Serial.available();
  if (a > 0) {
    for (int x=0; x<a; x++) {
      last = Serial.read();
      in += String((char)last);
    }
  }
  
  if (last == 13) {
    Serial.println("Input:"+in);
    if (in == "Hello"+String((char)13)) {
      Serial.println("\nHello to you too.");
    }
    in = "";
    last = '\0';
  }
}
