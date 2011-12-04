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

void setup() {
  Serial.begin(9600);
  
  //5 and 6 for right side
  //9 and 10 for left side
  //1 pin high, other low
  //DON'T TURN BOTH 5 and 6 OR 9 and 10 ON AT ONCE
  
  pinMode(LMOT_0, OUTPUT);
  pinMode(LMOT_1, OUTPUT);
  pinMode(RMOT_0, OUTPUT);
  pinMode(RMOT_1, OUTPUT);

  pinMode(LENC, INPUT);
  pinMode(RENC, INPUT);
  
  lEncPrev = digitalRead(LENC);
  rEncPrev = digitalRead(RENC);
  
  Serial.println("Welcome!");
  
  rightWheel(true);
  
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

void loop() {
  updateEncoders();
  Serial.print(rEncoder/12.0);
  Serial.print("    ");
  Serial.println(lEncoder/12.0);
}
