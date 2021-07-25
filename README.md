#  *No One Cares*
Kinda cool 72x6 LED matrix no one cares about

## Serial commands
### Syntax
Command syntax is made as compact as possible

Example: `CMD<ahello<b123/`
- `CMD` – command name. Command names always consist of three uppercase characters
- `<a` – first argument key. All argument keys begin with `<` and consist of only one lowercase character
- `hello` – first argument value
- `<b` – second argument key
- `123` – second argument value
- `/` – slash is required at the end of the command

**Reserved symbols:** 
- `<`
- `/`

**Reserved argument keys:** 
- `d` (argument derived from another piece of hardware code)

**Reserved keywords:**
- `%IS%` (value exists)
- `%NONE%` (value doesn't exist)
- `%SCR%` (scrolling animation)
- `%BLI%` (blinking animation)
- `%RND%` (random color)
- `%CHRND%` (random color of every character)
- `%TLL%` (tailight coloring)

### Data model
Command arguments values represent different data types. This is the reference

- **Int** – number: `123`
- **String** – case insensitive piece of text excluding reserved keywords and keys: `hello world`
- **Char** – case insensitive character: 'F'
- **ExBool** – gets intepreted as `true` if argument is present in the command.
- **Color** – rgb representation of the color: `Int,Int,Int` / random color: `%RND%` / char random coloring: `%CHRND%` / tailight coloring: `%TLL%`
- **Animation** – scrolling: `%SCR%` / blinking: `%BLI%`
- **Time** – time in H,M,S,D,M,Y format: `Int,Int,Int,Int,Int,Int`
- **CCPS** – [covey's compressed pixel sequence](#ccps) string: `C>3,RRGBWA>6,`
- **Error** – [error code](#error-codes-list) string

### Command list
#### *RTX* – display text
**Required arguments**:
- `t`: *String* – text to display
- `c`: *Color* – color of the text

**Optional arguments**:
- `i`: *ExBool* – whether to display inout animation
- `a`: *Animation* – animation to apply
- `e`: *Int* – animation counter delay (1-10)

**Optional return**:
- *Error* `ER011`/`ER012`/`ER021`

#### *ACH* – append char
**Required arguments**:
- `h`: *Char* – char to append
- `c`: *Color* – color of the matrix

**Optional return**:
- *Error* `ER011`/`ER012`/`ER021`/`ER041`

#### *CPS* – draw [CCPS](#ccps)
**Required arguments**:
- `s`: *CCPS* – sequence to draw

**Optional return**:
- *Error* `ER011`/`ER012`/`ER021`

#### *CLK* – display clock
**Required arguments**:
- `t`: *Time* – time to sync

**Optional return**:
- *Error* `ER011`/`ER012`/`ER021`

#### *BRT* – set brightness
**Required arguments**:
- `v`: *Int* – value (4-255)

**Optional return**:
- *Error* `ER011`/`ER012`/`ER021`

#### *PNG* – ACK the sender
**Guaranteed return**:
- *String* – constant `pong` message

#### *CLR* – clear matrix

## CCPS
Covey's Compressed Pixel Sequence – the most compact way of filling the matrix I could work out
### Syntax
PSs get drawn on a pixel-by-pixel basis. So, to draw something, an ordered list of instructions must be set to the device.

Each instruction is either a `Custom Color`, `Default Color` or `Set`.

Every `Int` must have a trailing comma if followed by another `Int`

#### Custom Color
Custom Color is a set of R, G and B values.
Each value is either an `Int`, an `f` key, which represents full value (255), or an `e` key, which represents empty value (0).

**Examples**:
- `139ef` – violet-colored pixel (gets interpreted as 139, 0, 255)
- `f165e` – orange-colored pixel (gets interpreted as 255, 165, 0)

#### Default Color
Default Color is one of the default presets, presented as a `Key`.

**Keys**:
- `W` *(white)* – `255, 255, 255` pixel
- `N` *(none)* – `0, 0, 0` pixel
- `A` *(alpha)* – skip this pixel. If anything was previously displayed on the matrix, it won't be overlapped
- `R` *(red)* – `255, 0, 0` pixel
- `G` *(green)* – `0, 255, 0` pixel
- `B` *(blue)* – `0, 0, 255` pixel
- `C` *(cyan)* – `0, 255, 255` pixel
- `M` *(magenta)* – `255, 0, 255` pixel
- `Y` *(yellow)* – `255, 255, 0` pixel

#### Set
Set is a repeated instruction.
Each set consists of either a `Custom Color` or `Default Color` instruction followed by `<` key, and either an `Int`, representing the number of repeats, or an `i` key, which leads to drawing an instruction until the end of matrix.
Any instruction after `>i` gets ignored.

**Examples**:
- `139ef>120` – violet-colored pixel, drawn 120 times
- `f165e>i` – orange-colored pixel, drawn until the end of matrix
- `R>9` – red-colored pixel, drawn 9 times

>**NB:** Sets don't make sence when a `Default Color` instruction should be drawn less than 4 times, as their definition in this case takes 3 characters.

### Sequence examples
- `WWRBB` – draw two white, one red and two blue pixels
- `NNf165,e` – draw two black pixels, followed by an orange one
- `R>100AAG>50` – draw 100 red pixels, skip two and draw 50 green pixels
- `f192,203>100N>i` – draw 100 pink pixels, draw the remaining in black

## Error codes list
Error codes are returned by some functions if they fail to properly execute. Here's the reference
- `ER011` – unexpected '1' selector while parsing command arguments
- `ER012` – unexpected '2' selector while parsing command arguments
- `ER021` – required argument not served
- `ER031` – unknown command
- `ER032` – unknown routine
- `ER033` – unknown CCPS instruction
- `ER041` – type error: expected *Char*
- `ER051` – corrupted CCPS: unexpected `i`
- `ER05` – corrupted CCPS: unexpected `<`
