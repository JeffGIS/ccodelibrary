//  PolylineCompression.c
//  CCodeLibrary

#include "PolylineCompression.h"
#include <string.h>
#include "MathUtil.h"

void DecodeString(const char *encodedString, LPDPOINT *llpoints, int *numPoints)
{
    unsigned long len = strlen(encodedString);
    int maxSize = ceil(len / 4);
    
    llpoints = realloc(llpoints, (sizeof(DPOINT) * maxSize) + 4);
    
    int index = 0;
    float lat = 0, lng = 0;
    
    *numPoints = 0;
    
    while (index < len)
    {
        char b = 0;
        int shift = 0, result = 0;
        
        do
        {
            b = encodedString[index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        }
        
        while (b >= 0x20);
        
        float dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        
        shift = 0, result = 0;
        
        do
        {
            b = encodedString[index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        }
        
        while (b >= 0x20);
        
        float dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        
        float finalLat = (lat * 1e-5);
        float finalLong = (lng * 1e-5);
        
        DPOINT point = {finalLat, finalLong};
        *llpoints[*numPoints++] = point;
    }
    
    llpoints = realloc(llpoints, (sizeof(DPOINT) * *numPoints) + 4);
}