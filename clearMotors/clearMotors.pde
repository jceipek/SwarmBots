#define LMOT_0 5
#define LMOT_1 6
#define RMOT_0 9
#define RMOT_1 10


void setup() {
  //5 and 6 for right side
  //9 and 10 for left side
  //1 pin high, other low
  //DON'T TURN BOTH 5 and 6 OR 9 and 10 ON AT ONCE
  
  pinMode(LMOT_0, OUTPUT);
  pinMode(LMOT_1, OUTPUT);
  pinMode(RMOT_0, OUTPUT);
  pinMode(RMOT_1, OUTPUT);
  
  digitalWrite(LMOT_0, LOW);
  digitalWrite(LMOT_1, LOW);
  digitalWrite(RMOT_0, LOW);
  digitalWrite(RMOT_1, LOW);
}

void loop() {
  
}
