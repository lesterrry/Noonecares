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

### Command list
#### *RTX* – display text
**Required arguments**:
- `t`: *String* – text to display
- `c`: *Color* – color of the text
**Optional arguments**:
- `i`: *ExBool* – whether to display inout animation
- `a`: *Animation* – animation to apply

#### *ACH* – append char
**Required arguments**:
- `h`: *Char* – char to append
- `c`: *Color* – color of the matrix

#### *CLK* – display clock
**Required arguments**:
- `t`: *Time* – time to sync

#### *BRT* – set brightness
**Required arguments**:
- `v`: *Int* – value (4-255)

#### *CLR* – clear matrix
