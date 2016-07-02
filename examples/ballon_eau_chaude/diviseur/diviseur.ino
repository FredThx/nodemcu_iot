
/*
Diviseur de fréquence par 2*N

Entrée : un signal de fréquence pas trop grande
Sortie : un signal de demie fréquence N

created 29 juin 2016
by FredThx
*/ 

int N = 330;
int pinIn = 8;
int pinOut = 2;


double sum = 0;
int pinVal0 = LOW;

void setup() {
  pinMode(pinIn,INPUT);
  pinMode(pinOut,OUTPUT);
}

void loop() {
  int pinVal = digitalRead(pinIn);
  if (pinVal0>pinVal) {
      sum += 1;
      if (sum > N) {
        if (digitalRead(pinOut)==HIGH){
          digitalWrite(pinOut,LOW);
        } else {
          digitalWrite(pinOut,HIGH);
        }
        sum = 0;
      }
    }
  pinVal0 = pinVal;
}
