//  ExitApp.c
//  CCodeLibrary

#include "ExitApp.h"
#include "Assert.h"
#include <execinfo.h>

void exitApp(char *callingFunctionSignature)
{
    printf("exitApp was called by %s\n", callingFunctionSignature);
    assert(1 < 0);
}