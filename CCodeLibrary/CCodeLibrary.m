//  CCodeLibrary.m
//  CCodeLibrary

#import "CCodeLibrary.h"
#include "graphint.h"

@implementation CCodeLibrary

int testVars(int in)
{
    char str[256] = "[VAR]=1;";
    // TODO: Place code here.
    
    CreateVarSpace(VARSPACE_GLOBAL);
    
    ExpandText(str);
    strcpy(str, "IF([VAR]>2){[VALUE]=5;}ELSE{[VALUE]=$FLT([VAR]+10);};");
    ExpandText(str);
    strcpy(str, "[VALUE]");
    ExpandText(str);
    DestroyVarSpace((HANDLE)-1);
    //_CrtDumpMemoryLeaks();
    return 0;
    
}


@end
