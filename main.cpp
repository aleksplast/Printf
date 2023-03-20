
extern "C" void MyPrintf(const char* template_string, ...);
#include <stdio.h>

int main()
{
    MyPrintf("Bebrochka!\n");

    MyPrintf("Hi %% %d %x %s %b %s %s %d %d\n", 127, 23, "Kekich", 65, "ESHKERE", "ABOBA", 256, -1);
    return 0;
}
