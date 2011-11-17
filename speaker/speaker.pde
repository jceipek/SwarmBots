#define SPEAKER_PIN 2
#define ANALOG_SPEAKER 

int startTime = 0;
int period = 5;

void setup() {
  pinMode(SPEAKER_PIN, OUTPUT);
  //pinMode()
}

void loop() {
  int diff =  millis()-startTime;
  digitalWrite(SPEAKER_PIN, diff >= period);
  if (diff >= period*2) {
    startTime = millis();
  }
  
}

