int receiver = 0;

void setup() {
  Serial.begin(9600);
  setPwmFrequency(5, 1);
}

void loop() {
  analogWrite(5, 128);
  
  receiver = analogRead(A0);
  Serial.println(receiver, DEC);
}

