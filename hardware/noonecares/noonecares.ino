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
#define LED_MIN_BRT 4
#define CMD_ARGS_COUNT 5

// Reserved keywords
#define EXISTS_KEYWORD "%IS%"
#define RANDOM_KEYWORD "%RND%"
#define CHAR_RANDOM_KEYWORD "%CHRND%"
#define TAILLIGHT_KEYWORD "%TLL%"

int routineTask = 0;  // Long-lasting task to do as a routine
int cachedMatrixBrightness = 30;  // Brightness of matrix to revert to
int counter = 0;  // Int which controls longer (than 0.1sec) routines
uint32_t timer;  // Main routine timer
String cachedCommandName = "";  // Name of a command to execute in a routine
String cachedCommandArgs[CMD_ARGS_COUNT][2];  // Arguments of a command to execute in a routine
String currentCharSequence = "";  // Current sequence of displayed characters
bool inoutInDone = false;  // True if inout animation bounces back
bool timeWasSet = false;  // True if time was set

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
    clearMatrix();
    Serial.begin(115200);
    timer = millis();
}

void loop() {
    if (Serial.available() > 0) {  // Receive data over serial
        handleCommand(Serial.readStringUntil('/'));
    }
    if (millis() - timer > 100) {  // Main timer routine (0.1sec)
        counter += 1;
        switch (routineTask) {
            case 0:  // No task
                break;
            case 2:  // Clock display
                if (counter < 9) { break; }
                counter = 0;
                matrix.clear();
                matrix.setCursor(7, 5);
                matrix.setTextColor(matrix.Color(100, 100, 100));
                matrix.print(hour());
                matrix.print(":");
                matrix.print(minute());
                matrix.print(":");
                matrix.print(second());
                matrix.show();
                break;
            case 1:  // Inout animation MARK: There's something wrong with this switch/case.
                Serial.println("C");
                float b = matrix.getBrightness();
                if (cachedCommandName != "" && b >= 5 && !inoutInDone) {
                    float a = (b / 100) * 50;
                    matrix.setBrightness(b - a);
                    matrix.show();
                } else if (b < cachedMatrixBrightness) {
                    inoutInDone = true;
                    float a = (b / 100) * 50;
                    if (b < LED_MIN_BRT) {
                        b = LED_MIN_BRT;
                    }
                    executeCommand(cachedCommandName, cachedCommandArgs);
                    matrix.setBrightness(b + a);
                    matrix.show();
                } else if (b >= cachedMatrixBrightness) {
                    routineTask = 0;
                    cachedCommandName = "";
                    inoutInDone = false;
                }
                break;
        }
        if (counter > 1000) {
            counter = 0;
        }
        timer = millis();
    }
}

void clearMatrix() {
    currentCharSequence = "";
    matrix.fillScreen(0);
    matrix.show();
}

void handleCommand(String command) {
    String name = command.substring(0, 3);
    String argstring = command.substring(3);
    command = "";
    String args[CMD_ARGS_COUNT][2];
    int selector = 0;
    int currentIndex = 0;
    String currentArg = "";
    for (int i = 0; i < argstring.length(); i++) {
        char c = argstring[i];
        if (c == '<') {
            if (selector == 1) {
                reportError("parsel", "011");
                return;
            }
            if (currentArg != "") {
                args[currentIndex][1] = currentArg;
                currentArg = "";
            }
            currentIndex += 1;
            selector = 1;
        } else {
            switch (selector) {
                case 0:
                    reportError("parsel", "012");
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
    argstring = "";
    if (currentArg != "") {
        args[currentIndex][1] = currentArg;
        currentArg = "";
    }
    String s = getArgumentValue(args, "i");
    if (s == EXISTS_KEYWORD) {
        setTaskCommand(1, name, args);
        return;
    }
    executeCommand(name, args);
}

void setTaskCommand(int task, String name, String args[CMD_ARGS_COUNT][2]) {
    for (int i = 0; i < CMD_ARGS_COUNT; i++) {  // Changing 'inout' parameter to 'derived'
        if (args[i][0] == "i") {
            args[i][0] = "d";
        }
    }
    cachedCommandName = name;
    refillArgsArray(args);
    routineTask = 1;
    cachedMatrixBrightness = matrix.getBrightness();
}

void refillArgsArray(String args[CMD_ARGS_COUNT][2]) {
    for (int i = 0; i < CMD_ARGS_COUNT; i++) {
        for (int j = 0; j < 2; j++) {
            cachedCommandArgs[i][j] = args[i][j];
        }
    }
}

void executeCommand(String name, String args[CMD_ARGS_COUNT][2]) {
    if (name == "RTX") {  // Just print text
        String text = getArgumentValue(args, "t");
        String scolor = getArgumentValue(args, "c");
        if (text == "" || scolor == "") {
            reportError("argnot", "021");
            return;
        }
        uint16_t colors = getColors(scolor);
        safePrint(text, colors);
    } else if (name == "ACH") {  // Append char (!!!) to currently displayed text
        String character = getArgumentValue(args, "h");
        String scolor = getArgumentValue(args, "c");
        if (character == "" || scolor == "") {
            reportError("argnot", "021");
            return;
        }
        if (character.length() > 1) {
            reportError("notchar", "041");
            return;
        }
        uint16_t colors = getColors(scolor);
        if (currentCharSequence.length() > 11) {
            currentCharSequence = currentCharSequence.substring(1);
        }
        currentCharSequence += character;
        safePrint(currentCharSequence, colors);
    } else if (name == "CLR") {  // Clear the matrix
        matrix.fillScreen(0);
        matrix.show();
    } else if (name == "CLK") {  // Clear the matrix
        if (timeWasSet) {
            routineTask = 2;
        } else {
            reportError("timenot", "051");
        }
    } else if (name == "TME") {  // Set the time
        String time = getArgumentValue(args, "t");
        if (time == "") {
            reportError("argnot", "021");
            return;
        }
        int values[6];
        int currentIndex = 0;
        String currentValue = "";
        for (int i = 0; i < time.length(); i++) {
            char c = time[i];
            if (c == ',') {
                if (currentValue != "") {
                    values[currentIndex] = currentValue.toInt();
                    currentValue = "";
                }
                currentIndex += 1;
            } else {
                currentValue += String(c);
            }
        }
        if (currentValue != "") {
            values[currentIndex] = currentValue.toInt();
            currentValue = "";
        }
        time = "";
        setTime(values[0], values[1], values[2], values[3], values[4], values[5]);
        timeWasSet = true;
    } else if (name == "BRT") {  // Adjust brightness
        int v = getArgumentValue(args, "v").toInt();
        matrix.setBrightness(v);
        matrix.show();
    } else {
        reportError("cmdnot", "031");
    }
}

void drawCCPS(String sequence) {
    
}

void safePrint(String text, uint16_t colors) {
    matrix.fillScreen(0);
    text.toUpperCase();
    matrix.setCursor(0, 5);
    if (colors == 1) {
        for (int i = 0; i < text.length(); i++) {
            int r, g, b, sum;
            do {
                r = random(0, 255);
                g = random(0, 255);
                b = random(0, 255);
                sum = r + g + b;
            } while (sum < 100);
            matrix.setTextColor(matrix.Color(r, g, b));
            matrix.print(text[i]);
        }
        matrix.show();
        return;
    } else if (colors == 2) {
        matrix.setTextColor(matrix.Color(100, 100, 100));
        for (int i = 0; i < text.length() - 1; i++) {
            matrix.print(text[i]);
        }
        matrix.setTextColor(matrix.Color(255, 50, 50));
        matrix.print(text[text.length() - 1]);
        matrix.show();
        return;
    }
    matrix.setTextColor(colors);
    matrix.print(text);
    matrix.show();
}

void safePrint(String text) {
    matrix.fillScreen(0);
    text.toUpperCase();
    matrix.print(text);
}

uint16_t getColors(String from) {
    if (from == CHAR_RANDOM_KEYWORD) {
        return 1;
    } else if (from == TAILLIGHT_KEYWORD) {
        return 2;
    } else if (from == RANDOM_KEYWORD) {
        int r, g, b, sum;
        do {
            r = random(0, 255);
            g = random(0, 255);
            b = random(0, 255);
            sum = r + g + b;
        } while (sum < 100);
        return matrix.Color(r, g, b);
    }
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

String getArgumentValue(String args[CMD_ARGS_COUNT][2], String forkey) {
    for (int i = 0; i < CMD_ARGS_COUNT; i++) {
        if (args[i][0] == forkey) {
            if (args[i][1] == NULL) { return EXISTS_KEYWORD; }
            return args[i][1];
        }
    }
    return "";
}

void reportError(String short_message, String error_code) {
    Serial.println("ER" + error_code);
    matrix.fillScreen(0);
    safePrint("ER " + short_message, matrix.Color(255, 0, 0));
    matrix.show();
    delay(2000);
    matrix.fillScreen(0);
    matrix.show();
}
