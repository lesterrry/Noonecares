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
#include <Fonts/Org_01.h>

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
    int rainbow[7][3] = { { 255, 153, 0 }, { 255, 0, 0 }, { 0, 255, 0 }, { 0, 0, 255 }, { 66, 170, 255 }, { 139, 0, 255 }, { 255, 255, 0 } };
    String greeting = "NO ONE CARES";
    matrix.begin();
    matrix.setBrightness(30);
    matrix.setFont(&Org_01);
    matrix.setTextWrap(false);
    matrix.setCursor(0, 5);
    for (int i = 0; i < 16; i++) {
        int rnd = random(0, 6);
        int color[3] = { rainbow[rnd][0], rainbow[rnd][1], rainbow[rnd][2] };
        matrix.setTextColor(matrix.Color(color[0], color[1], color[2]));
        matrix.print(greeting[i]);
    }
    matrix.show();
    delay(2000);
    matrix.fillScreen(0);
    matrix.show();
    Serial.begin(115200);
    
}

void loop() {
    if (Serial.available() > 0) {
        String data = Serial.readStringUntil('/');
        executeCommand(data);
    }
}

void executeCommand(String command) {
    String name = command.substring(0,3);
    String argstring = command.substring(3);
    String args[5][2];
    int selector = 0;
    int currentIndex = 0;
    String currentArg = "";
    for (int i = 0; i < argstring.length(); i++) {
        char c = argstring[i];
        if (c == '<') {
            if (selector == 1) {
                reportError("parsel", "wrong selector while parsing, expected !1");
                return;
            }
            
            if (currentArg != "") {
                args[currentIndex][1] = currentArg;
                currentArg = "";
                currentIndex += 1;
            }
            selector = 1;
        } else {
            switch (selector) {
                case 0:
                    reportError("parsel", "wrong selector while parsing, expected !0");
                    return;
                case 1:
                    args[currentIndex][0] = String(c);
                    selector = 2;
                    break;
                case 2:
                    currentArg += c;
                    break;
            }
        }
    }
    if (currentArg != "") {
        args[currentIndex][1] = currentArg;
    }
    
    if (name == "RTX") {
        String text = getArgument(args, "t");
        String scolor = getArgument(args, "c");
        if (text == "" || scolor == "") {
            reportError("argnot", "required argument not served");
            return;
        }
        uint16_t colors = getColors(scolor);
        generalPrint(text, colors);
        
    } else if (name == "CLR") {
        matrix.fillScreen(0);
        matrix.show();
    } else {
        reportError("cmdnot", "unknown command");
    }
}

void drawCCPS(String sequence) {
    
}

void generalPrint(String text, uint16_t colors) {
    matrix.setTextColor(colors);
    matrix.fillScreen(0);
    matrix.setCursor(0, 5);
    safePrint(text);
    matrix.show();
}

uint16_t getColors(String from) {
    int colors[3];
    int currentIndex = 0;
    String currentColor = "";
    for (int i = 0; i < from.length(); i++) {
        char c = from[i];
        if (c == ',') {
            if (currentColor != "") {
                colors[currentIndex] = currentColor.toInt();
                currentColor = "";
            }
            currentIndex += 1;
        } else {
            currentColor += String(c);
        }
    }
    if (currentColor != "") {
        colors[currentIndex] = currentColor.toInt();
    }
    return matrix.Color(colors[0], colors[1], colors[2]);
}

String getArgument(String args[5][2], String forkey) {
    for (int i = 0; i < 5; i++) {
        if (args[i][0] == forkey) {
            return args[i][1];
        }
    }
    return "";
}

void reportError(String short_message, String long_message) {
    matrix.setTextColor(matrix.Color(255, 0, 0));
    Serial.println("Error: " + long_message);
    matrix.fillScreen(0);
    matrix.setCursor(0, 5);
    matrix.print("ER ");
    safePrint(short_message);
    matrix.show();
    delay(2000);
    matrix.fillScreen(0);
    matrix.show();
}

void safePrint(String text) {
    text.toUpperCase();
    matrix.print(text);
}
