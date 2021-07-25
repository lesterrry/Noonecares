/***************************
  COPYRIGHT FETCH DEVELOPMENT,
  2021

  Noonecares –
  A 72x6 LED MATRIX NO ONE CARES ABOUT

  MAIN HARDWARE SCRIPT

  VERSION 0.1.0
***************************/

// External modules
#include <Adafruit_GFX.h>                     // Graphics
#include <Adafruit_NeoMatrix.h>               // Matrix controls
#include <Adafruit_NeoPixel.h>                // LED strip controls
#include <Fonts/Org_01.h>                     // Main font
#include <Time.h>
#include <TimeLib.h>

// Compile-time parameters
#define LED_COUNT 432
#define LED_PIN 6
#define LED_MIN_BRT 4
#define CMD_ARGS_COUNT 5

// Reserved keywords
#define EXISTS_KEYWORD "%IS%"
#define RANDOM_KEYWORD "%RND%"
#define CHAR_RANDOM_KEYWORD "%CHRND%"
#define TAILLIGHT_KEYWORD "%TLL%"
#define BLINK_KEYWORD "%BLI%"
#define SCROLL_KEYWORD "%SCR%"

#define STR_EMPTY ""

// Variables
int routineTask = 0;                          // Long-lasting task to do as a routine
int cachedMatrixBrightness = 30;              // Brightness of matrix to revert to
int counter = 0;                              // Int which controls longer (than 0.05sec) routines
int routineDelay = 3;                         // Int which controls routine delay
int scrollLimit = -36;                        // Int which controls scrolling limit
uint32_t timer;                               // Main routine timer
String cachedCommandName = STR_EMPTY;         // Name of a command to execute in a routine
String cachedCommandArgs[CMD_ARGS_COUNT][2];  // Arguments of a command to execute in a routine
String currentCharSequence = STR_EMPTY;       // Current sequence of displayed characters
bool inoutInDone = false;                     // True if inout animation bounces back

Adafruit_NeoMatrix matrix = Adafruit_NeoMatrix(
                              72,
                              LED_PIN,
                              LED_PIN,
                              NEO_MATRIX_TOP + NEO_MATRIX_RIGHT + NEO_MATRIX_ROWS + NEO_MATRIX_ZIGZAG,
                              NEO_GRB + NEO_KHZ400
                            );
int scrollPos = matrix.width();

// MARK: Setup
void setup() {
    int rainbow[7][3] = { { 255, 153, 0 }, { 255, 0, 0 }, { 0, 255, 0 }, { 0, 0, 255 }, { 66, 170, 255 }, { 139, 0, 255 }, { 255, 255, 0 } };
    String greeting = F("NO ONE CARES");
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

// MARK: Loop
void loop() {
    if (Serial.available() > 0) {             // Receive data over serial
        String command = Serial.readStringUntil('/');
        handleCommand(command);
    }
    if (millis() - timer > 5) {               // Main timer routine (0.05sec)
        counter++;
        switch (routineTask) {
            case 0:                           // No task
                break;
            case 2: {                         // Clock display
                if (counter < 8) break;
                counter = 0;
                matrix.clear();
                matrix.setTextColor(matrix.Color(100, 100, 100));
                int h = hour(), m = minute(), s = second();
                matrix.setCursor(10, 5);
                matrix.print(h > 9 ? h : "0" + String(h));
                matrix.setCursor(30, 5);
                matrix.print(m > 9 ? m : "0" + String(m));
                matrix.setCursor(50, 5);
                matrix.print(s > 9 ? s : "0" + String(s));
                matrix.show();
                break;
            }
            case 3: {                        // Blink
                if (counter == routineDelay) {
                    executeCommand(cachedCommandName, cachedCommandArgs);
                }
                if (counter > routineDelay * 2) {
                    counter = 0;
                    clearMatrix();
                }
                break;
            }
            case 4: {                        // Scroll
                if (counter < routineDelay) break;
                counter = 0;
                matrix.fillScreen(0);
                matrix.setCursor(scrollPos, 5);
                if(--scrollPos < scrollLimit) {
                    scrollPos = matrix.width();
                }
                executeCommand(cachedCommandName, cachedCommandArgs);
                break;
            }
            case 1: {                       // Inout animation
                float b = matrix.getBrightness();
                if (cachedCommandName != STR_EMPTY && b >= 5 && !inoutInDone) {
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
                    cachedCommandName = STR_EMPTY;
                    inoutInDone = false;
                }
                break;
            }
            default: {
                reportError(F("rounot"), F("032"));
                routineTask = 0;
            }
        }
        if (counter > 1000) {
            counter = 0;
        }
        timer = millis();
    }
}

// MARK: Functions

/// Turn every pixel off
void clearMatrix() {
    currentCharSequence = STR_EMPTY;
    matrix.fillScreen(0);
    matrix.show();
}

/// Parse and execute command
/// @param command Command string
void handleCommand(String &command) {
    routineTask = 0;
    String name = command.substring(0, 3);
    String args[CMD_ARGS_COUNT][2];
    {
        String argstring = command.substring(3);
        command = STR_EMPTY;
        int selector = 0;
        int currentIndex = 0;
        String currentArg = STR_EMPTY;
        for (int i = 0; i < argstring.length(); i++) {
            char c = argstring[i];
            if (c == '<') {
                if (selector == 1) {
                    reportError(F("parsel"), F("011"));
                    return;
                }
                if (currentArg != STR_EMPTY) {
                    args[currentIndex][1] = currentArg;
                    currentArg = STR_EMPTY;
                }
                currentIndex++;
                selector = 1;
            } else {
                switch (selector) {
                    case 0:
                        reportError(F("parsel"), F("012"));
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
        if (currentArg != STR_EMPTY) {
            args[currentIndex][1] = currentArg;
        }
    }
    String s = getArgumentValue(args, "i");
    if (s == EXISTS_KEYWORD) {
        setTaskCommand(1, name, args);
        return;
    }
    s = getArgumentValue(args, "a");
    if (s != STR_EMPTY) {
        String d = getArgumentValue(args, "e");
        if (d != STR_EMPTY) {
            routineDelay = d.toInt();
            d = STR_EMPTY;
        }
        if (s == BLINK_KEYWORD) {
            setTaskCommand(3, name, args);
            return;
        }
        if (s == SCROLL_KEYWORD) {
            String n = getArgumentValue(args, "t");
            scrollLimit = -7 * n.length();
            n = STR_EMPTY;
            setTaskCommand(4, name, args);
            return;
        }
    }
    s = "";
    executeCommand(name, args);
}

/// Add command to routine loop
/// @param task Task key as listed in loop() routine switch
/// @param name Command name
/// @param args Command arguments
void setTaskCommand(int task, String &name, String args[CMD_ARGS_COUNT][2]) {
    for (int i = 0; i < CMD_ARGS_COUNT; i++) {  // Changing 'inout' parameter to 'derived'
        if (args[i][0] == "i") {
            args[i][0] = "d";
        }
    }
    cachedCommandName = name;
    refillArgsArray(args);
    routineTask = task;
    cachedMatrixBrightness = matrix.getBrightness();
}

/// Fill cached command arguments var with specific args
/// @param args Arguments to fill the var with
void refillArgsArray(String args[CMD_ARGS_COUNT][2]) {
    for (int i = 0; i < CMD_ARGS_COUNT; i++) {
        for (int j = 0; j < 2; j++) {
            cachedCommandArgs[i][j] = args[i][j];
        }
    }
}

/// Execute command with a specific name and arguments
/// @param name Command name
/// @param args Command arguments
void executeCommand(String &name, String args[CMD_ARGS_COUNT][2]) {
    if (name == "RTX") {                      // Just print text
        String text = getArgumentValue(args, "t");
        String sColor = getArgumentValue(args, "c");
        String sAnim = getArgumentValue(args, "a");
        if (text == STR_EMPTY || sColor == STR_EMPTY) {
            reportError(F("argnot"), F("021"));
            return;
        }
        uint16_t colors = getColors(sColor);
        safePrint(text, colors, sAnim != SCROLL_KEYWORD);
    } else if (name == "ACH") {               // Append char (!!!) to currently displayed text
        String character = getArgumentValue(args, "h");
        String sColor = getArgumentValue(args, "c");
        if (character == STR_EMPTY || sColor == STR_EMPTY) {
            reportError(F("argnot"), F("021"));
            return;
        }
        if (character.length() > 1) {
            reportError(F("notchar"), F("041"));
            return;
        }
        uint16_t colors = getColors(sColor);
        if (currentCharSequence.length() > 11) {
            currentCharSequence = currentCharSequence.substring(1);
        }
        currentCharSequence += character;
        safePrint(currentCharSequence, colors, true);
    } else if (name == "CLR") {               // Clear the matrix
        clearMatrix();
    } else if (name == "CPS") {               // Draw CCPS
        String ccps = getArgumentValue(args, "s");
        if (ccps == STR_EMPTY) {
            reportError(F("argnot"), F("021"));
            return;
        }
        drawCCPS(ccps);
    } else if (name == "PNG") {               // ACK the sender
        Serial.println(F("pong"));
    } else if (name == "CLK") {               // Enter clock mode
        String time = getArgumentValue(args, "t");
        if (time == STR_EMPTY) {
            reportError(F("argnot"), F("021"));
            return;
        }
        int values[6];
        int currentIndex = 0;
        String currentValue = STR_EMPTY;
        for (int i = 0; i < time.length(); i++) {
            char c = time[i];
            if (c == ',') {
                if (currentValue != STR_EMPTY) {
                    values[currentIndex] = currentValue.toInt();
                    currentValue = STR_EMPTY;
                }
                currentIndex++;
            } else {
                currentValue += String(c);
            }
        }
        if (currentValue != STR_EMPTY) {
            values[currentIndex] = currentValue.toInt();
            currentValue = STR_EMPTY;
        }
        time = STR_EMPTY;
        setTime(values[0], values[1], values[2], values[3], values[4], values[5]);
        routineTask = 2;
    } else if (name == "BRT") {               // Adjust brightness
        int v = getArgumentValue(args, "v").toInt();
        matrix.setBrightness(v);
        matrix.show();
    } else {
        reportError(F("cmdnot"), F("031"));
    }
}

/// Parse and display Covey's Compressed Pixel Sequence
/// @param sequence CCPS string
void drawCCPS(String &sequence) {
    int currentLEDIndex = 0;
    int lastColor[] = { 256, 256, 256 };
    String customColor[] = { STR_EMPTY, STR_EMPTY, STR_EMPTY };
    int customColorIndex = 0;
    bool collectingSetCount = false;
    String setCount = STR_EMPTY;
    for (int i = 0; i < sequence.length(); i++) {
        char c = sequence[i];
        int cint = c;
        if (cint >= 48 && cint <= 57) {  // If number
            cint = cint - 48;
            if (collectingSetCount) {
                setCount += String(cint);
            } else {
                customColor[customColorIndex] += String(cint);
            }
        } else {
            if (customColor[2] != STR_EMPTY) {  // Drawing custom color
                matrix.setPixelColor(currentLEDIndex, customColor[0].toInt(), customColor[1].toInt(), customColor[2].toInt());
                customColorIndex = 0;
                for (int j = 0; j < 3; j++) {
                    lastColor[j] = customColor[j].toInt();
                    customColor[j] = STR_EMPTY;
                }
                currentLEDIndex++;
            } else if (collectingSetCount && c != 'i') {  // Drawing non-infinite set
                int count = setCount.toInt() - 1;
                for (int j = 0; j < count; j++) {
                    if (lastColor[0] != 256) {
                        matrix.setPixelColor(currentLEDIndex, lastColor[0], lastColor[1], lastColor[2]);
                    }
                    currentLEDIndex++;
                }
                collectingSetCount = false;
                setCount = STR_EMPTY;
            }
            if (c == 'i') {  // Drawing infinite set
                if (collectingSetCount) {
                    while (currentLEDIndex < LED_COUNT) {
                        if (lastColor[0] != 256) {
                            matrix.setPixelColor(currentLEDIndex, lastColor[0], lastColor[1], lastColor[2]);
                        }
                        currentLEDIndex++;
                    }
                    collectingSetCount = false;
                    setCount = STR_EMPTY;
                } else {
                    reportError(F("cpscor"), F("051"));
                }
            } else if (c == 'W') {
                matrix.setPixelColor(currentLEDIndex, 255, 255, 255);
                lastColor[0] = 255;
                lastColor[1] = 255;
                lastColor[2] = 255;
                currentLEDIndex++;
            } else if (c == 'N') {
                matrix.setPixelColor(currentLEDIndex, 0, 0, 0);
                lastColor[0] = 0;
                lastColor[1] = 0;
                lastColor[2] = 0;
                currentLEDIndex++;
            } else if (c == 'A') {
                lastColor[0] = 256;
                lastColor[1] = 256;
                lastColor[2] = 256;
                currentLEDIndex++;
            } else if (c == 'R') {
                matrix.setPixelColor(currentLEDIndex, 255, 0, 0);
                lastColor[0] = 255;
                lastColor[1] = 0;
                lastColor[2] = 0;
                currentLEDIndex++;
            } else if (c == 'G') {
                matrix.setPixelColor(currentLEDIndex, 0, 255, 0);
                lastColor[0] = 0;
                lastColor[1] = 255;
                lastColor[2] = 0;
                currentLEDIndex++;
            } else if (c == 'B') {
                matrix.setPixelColor(currentLEDIndex, 0, 0, 255);
                lastColor[0] = 0;
                lastColor[1] = 0;
                lastColor[2] = 255;
                currentLEDIndex++;
            } else if (c == 'C') {
                matrix.setPixelColor(currentLEDIndex, 0, 255, 255);
                lastColor[0] = 0;
                lastColor[1] = 255;
                lastColor[2] = 255;
                currentLEDIndex++;
            } else if (c == 'M') {
                matrix.setPixelColor(currentLEDIndex, 255, 0, 255);
                lastColor[0] = 255;
                lastColor[1] = 0;
                lastColor[2] = 255;
                currentLEDIndex++;
            } else if (c == 'Y') {
                matrix.setPixelColor(currentLEDIndex, 255, 255, 0);
                lastColor[0] = 255;
                lastColor[1] = 255;
                lastColor[2] = 0;
                currentLEDIndex++;
            } else if (c == 'f') {
                if (customColor[customColorIndex] != STR_EMPTY) customColorIndex++;
                customColor[customColorIndex] = "255";
                customColorIndex++;
            } else if (c == 'e') {
                if (customColor[customColorIndex] != STR_EMPTY) customColorIndex++;
                customColor[customColorIndex] = "0";
                customColorIndex++;
            } else if (c == ',') {
                if (customColor[0] != STR_EMPTY) customColorIndex++;
            } else if (c == '>') {
                if (!collectingSetCount) {
                    collectingSetCount = true;
                } else {
                    reportError(F("cpscor"), F("052"));
                }
            } else {
                reportError(F("insnot"), F("033"));
                return;
            }
        }
    }
    if (customColor[2] != STR_EMPTY) {  // Drawing custom color
        matrix.setPixelColor(currentLEDIndex, customColor[0].toInt(), customColor[1].toInt(), customColor[2].toInt());
    } else if (collectingSetCount) {
        int count = setCount.toInt() - 1;
        for (int j = 0; j < count; j++) {  // Drawing non-infinite set
            if (lastColor[0] != 256) {
                matrix.setPixelColor(currentLEDIndex, lastColor[0], lastColor[1], lastColor[2]);
            }
            currentLEDIndex++;
        }
        collectingSetCount = false;
        setCount = STR_EMPTY;
    }
    matrix.show();
}

/// Display colored explicitly uppercased text, optionally resetting cursor and clearing the matrix
/// @param text Text string
/// @param colors Either 1 for Char Random coloring, 2 for Taillight coloring or a specific color value
/// @param reset Whether to explicitly clear matrix and reset the cursor
void safePrint(String &text, uint16_t colors, bool reset) {
    text.toUpperCase();
    if (reset) {
        matrix.setCursor(0, 5);
        matrix.fillScreen(0);
    }
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

/// Display explicitly uppercased text, resetting cursor and clearing the matrix
/// @param text Text string
void safePrint(String &text) {
    matrix.fillScreen(0);
    text.toUpperCase();
    matrix.print(text);
}

/// Get color value from comma-separated string or keyword
/// @param from Color string
uint16_t getColors(String &from) {
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
    String currentColor = STR_EMPTY;
    for (int i = 0; i < from.length(); i++) {
        char c = from[i];
        if (c == ',') {
            if (currentColor != STR_EMPTY) {
                colors[currentIndex] = currentColor.toInt();
                currentColor = STR_EMPTY;
            }
            currentIndex++;
        } else {
            currentColor += String(c);
        }
    }
    if (currentColor != STR_EMPTY) {
        colors[currentIndex] = currentColor.toInt();
    }
    return matrix.Color(colors[0], colors[1], colors[2]);
}

/// Parse arguments array and retrieve a specific value by key
/// @param forkey Key to get argument value by
/// @return Either an argument value or a STR_EMPTY keyword, in case none found
String getArgumentValue(String args[CMD_ARGS_COUNT][2], String forkey) {
    for (int i = 0; i < CMD_ARGS_COUNT; i++) {
        if (args[i][0] == forkey) {
            if (args[i][1] == NULL) { return EXISTS_KEYWORD; }
            return args[i][1];
        }
    }
    return STR_EMPTY;
}

/// Print error to matrix display and serial port
/// @param short_message Error message to send to the matrix
/// @param error_code Error code to print to the serial port
void reportError(String short_message, String error_code) {
    Serial.println("ER" + error_code);
    matrix.fillScreen(0);
    safePrint("ER " + short_message, matrix.Color(255, 0, 0), true);
    matrix.show();
    delay(2000);
    matrix.fillScreen(0);
    matrix.show();
}
