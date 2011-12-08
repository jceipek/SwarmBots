#define LMOT_0 5
#define LMOT_1 6
#define RMOT_0 9
#define RMOT_1 10

#define LENC 4

void setup() {
  //5 and 6 for right side
  //9 and 10 for left side
  //1 pin high, other low
  //DON'T TURN BOTH 5 and 6 OR 9 and 10 ON AT ONCE
  
  pinMode(LMOT_0, OUTPUT);
  pinMode(LMOT_1, OUTPUT);
  pinMode(RMOT_0, OUTPUT);
  pinMode(RMOT_1, OUTPUT);
  
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

void loop() {
  leftWheel(false);
  rightWheel(false);
  /*delay(1000);
  leftWheel(false);
  rightWheel(false);  
  delay(1000);
  leftWheelOff();
  rightWheelOff();
  delay(1000);*/
/*
  digitalWrite(LMOT_0, HIGH);
  digitalWrite(LMOT_1, LOW);

  digitalWrite(RMOT_0, HIGH);
  digitalWrite(RMOT_1, LOW);
  */
}
