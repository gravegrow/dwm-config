// Modify this file to change what commands output to your statusbar, and
// recompile using the make command.
static const Block blocks[] = {
    /*Icon*/ /*Command*/ /*Update Interval*/ /*Update Signal*/

    {"", "dwm-status-volume icon", 0, 1},
    {"", "dwm-status-volume", 5, 1},
    {"", "dwm-status-separator", 0, 0},
    {"", "dwm-status-clock icon", 0, 2},
    {"", "dwm-status-clock", 5, 2},
    {"", "dwm-status-power", 0, 3},

};

// sets delimeter between status commands. NULL character ('\0') means no
// delimeter.
static char delim[] = " ";
static unsigned int delimLen = 2;
