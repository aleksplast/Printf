
extern "C" void MyPrintf(const char* template_string, ...);
#include <stdio.h>

int main()
{
    MyPrintf("Hi %d ", -1);
    return 0;
}
