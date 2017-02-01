#include "WMS.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

void wmsRequest(const char *filepath, const char *tmpFilePath, dbounds bounds, unsigned short width, unsigned short height)
{
    FILE *tmpFile, *imgFile;
    struct addrinfo hints, *res;
    int sockfd = 0, byteCount = 0, totalBytes = 0;
    char buffer[10240], ch;
    char *request = (char *)calloc(320, sizeof(char));
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    getaddrinfo("geoint.lmic.state.mn.us", "80", &hints, &res);
    sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    printf("Connecting...\n");
    connect(sockfd, res->ai_addr, res->ai_addrlen);
    printf("Connected!\n");
    
    sprintf(request,
            "GET /cgi-bin/mncomp?"
            "LAYERS=mncomp"
            "&FORMAT=image%%2Fjpeg"
            "&TRANSPARENT=TRUE&SERVICE=WMS"
            "&VERSION=1.1.1"
            "&REQUEST=GetMap"
            "&STYLES="
            "&SRS=EPSG%%3A4326"
            "&BBOX=%.4f,%.4f,%.4f,%.4f"
            "&WIDTH=%hu"
            "&HEIGHT=%hu "
            "HTTP/1.1\nHost: geoint.lmic.state.mn.us\n\n",
            bounds.xmn, bounds.ymn, bounds.xmx, bounds.ymx, width, height);
    
    send(sockfd, request, strlen(request), 0);
    printf("HTTP Request Sent...\n\n");
    
    tmpFile = fopen(tmpFilePath, "w");
    
    if (!tmpFile)
    {
        printf("Error reading/writing file\n");
        return;
    }
    
    do
    {
        memset(&buffer, 0, sizeof(buffer));
        byteCount = recv(sockfd, buffer, sizeof(buffer), 0);
        totalBytes += byteCount;
        fwrite(buffer, sizeof(char), byteCount, tmpFile);
        
    } while (byteCount > 0);
    
    fclose(tmpFile);
    tmpFile = fopen(tmpFilePath, "r");
    imgFile = fopen(filepath, "w");
    
    if (!imgFile || !tmpFile)
    {
        printf("Error reading/writing file\n");
        return;
    }
    
    for (int i = 0; i < totalBytes; i++)
    {
        ch = fgetc(tmpFile);
        
        if (i < 194)
            printf("%c", ch);
        
        else if (i < (totalBytes - 8))
            fputc(ch, imgFile);
    }
    
    fclose(tmpFile);
    fclose(imgFile);
}
