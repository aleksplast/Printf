
extern "C" void MyPrintf(const char* template_string, ...);
#include <stdio.h>

int main()
{
    MyPrintf("-Hi %d %x %o %s %b %s %s %d %d\n"
             "%d %s %x %d%%%c%b\n", 127, 23, 17, "Kekich", 65, "ESHKERE", "ABOBA", 256, -1,
             -1, "Love", 3802, 100, 33, 127);
    return 0;
}
