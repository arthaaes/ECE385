// main.c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>		// For seeding the random number generator
#include <unistd.h>		// for usleep (microsecond sleep)

// Application headers
#include "palette_test.h"	// Function to test palette color cycling
#include "text_mode_vga_color.h"	// Function for VGA color text screen saver


int main()
{
    srand((unsigned)time(NULL));	// This ensures the color outputs are different each time the program runs
    paletteTest();			// This function likely cycles through VGA colors to show off the palette features
    textVGAColorScreenSaver();		// After the palette test ends, run an infinite screen saver with colorful text
    return 0;
}
