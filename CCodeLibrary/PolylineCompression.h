//  PolylineCompression.h
//  CCodeLibrary

#ifndef PolylineCompression_h
#define PolylineCompression_h

#include <stdio.h>
#include "MathUtil.h"

char *EncodeString(LPDPOINT llpoints, int numPoints);
LPDPOINT DecodeString(char *encodedString, int *numPoints);

#endif