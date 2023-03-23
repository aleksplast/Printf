
extern "C" void MyPrintf(const char* template_string, ...);
#include <stdio.h>

int main()
{
    MyPrintf("Bebrochka!\n");

    MyPrintf("Hi %d %x %o %s %b %s %s %d %d\n", 127, 23, 17, "Kekich", 65, "ESHKERE", "ABOBA", 256, -1);
    return 0;
}
