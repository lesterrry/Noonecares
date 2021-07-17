/***************************
  COPYRIGHT FETCH DEVELOPMENT,
  2021

  Noonecares –
  A 72x6 LED MATRIX NO ONE CARES ABOUT

  MAIN SCRIPT

  VERSION 0.1.0
***************************/

#include <Adafruit_GFX.h>
#include <Adafruit_NeoMatrix.h>
#include <Adafruit_NeoPixel.h>
#include <Fonts/Tomthumb.h>

#define NUM_LEDS 432
#define LED_PIN 6

Adafruit_NeoMatrix matrix = Adafruit_NeoMatrix(
                              72,
                              LED_PIN,
                              LED_PIN,
                              NEO_MATRIX_TOP + NEO_MATRIX_RIGHT + NEO_MATRIX_ROWS + NEO_MATRIX_ZIGZAG,
                              NEO_GRB + NEO_KHZ400
                            );

void setup() {
  matrix.begin();
  matrix.setBrightness(30);
  matrix.setFont(&TomThumb);
  matrix.setTextColor(matrix.Color(255, 153, 0));
  matrix.setTextWrap(false);
  matrix.setCursor(0, 5);
  matrix.print(F("NO ONE CARES 400"));
  matrix.show();
  delay(1000);
}

void loop() {
  matrix.setCursor(0, 5);
  matrix.print(F("HELLO WORLD"));
  matrix.show();
  delay(300);
  matrix.fillScreen(0);
  matrix.show();
  delay(300);
}

void drawCCPS(String sequence) {
  
}
