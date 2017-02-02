//  WMS.h
//  CCodeLibrary

#ifndef WMS_h
#define WMS_h
#include "CCodeTypes.h"

bool wmsRequest(const char *filepath, dbounds bounds, unsigned short width, unsigned short height);

bool wmsRequest_jeff(const char *filepath, dbounds bounds, unsigned short width, unsigned short height);

#endif /* WMS_h */
