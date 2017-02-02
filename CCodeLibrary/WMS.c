#include "WMS.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define HEADER_LENGTH 194
#define BUFFER_SIZE 24576

void wmsRequest(const char *filepath, dbounds bounds, unsigned short width, unsigned short height)
{
    FILE *imgFile;
    struct addrinfo hints, *res;
    int sockfd = 0, totalBytes = 0;
    long byteCount = 0;
    char buffer[BUFFER_SIZE], ch;
    char *request = (char *)calloc(320, sizeof(char));
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    getaddrinfo("geoint.lmic.state.mn.us", "80", &hints, &res);
    sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    printf("\nConnecting...\n\n");
    connect(sockfd, res->ai_addr, res->ai_addrlen);
    printf("Connected!\n\n");
    
    sprintf(request,
            "GET /cgi-bin/mncomp?"
            "LAYERS=mncomp"
            "&FORMAT=image/jpeg"
            "&TRANSPARENT=TRUE"
            "&SERVICE=WMS"
            "&VERSION=1.1.1"
            "&REQUEST=GetMap"
            "&STYLES="
            "&SRS=EPSG:4326"
            "&BBOX=%.4f,%.4f,%.4f,%.4f"
            "&WIDTH=%hu"
            "&HEIGHT=%hu"
            " HTTP/1.1\n"
            "Host: geoint.lmic.state.mn.us\n\n",
            bounds.xmn, bounds.ymn, bounds.xmx, bounds.ymx, width, height);
    
    printf("WMS Query: %s", request);
    send(sockfd, request, strlen(request), 0);
    printf("HTTP Request Sent...\n\n");
    free(request);
    imgFile = fopen(filepath, "w");
    
    if (!imgFile)
    {
        printf("Error writing file\n");
        return;
    }
    
    do
    {
        byteCount = recv(sockfd, buffer, sizeof(buffer), 0);
        
        if (totalBytes < 1)
        {
            for (int i = 0; i < byteCount; i++)
            {
                ch = buffer[i];
                
                if (totalBytes < 1)
                {
                    if (i < HEADER_LENGTH)
                        printf("%c", ch);
                    
                    else
                        fputc(ch, imgFile);
                }
            }
        }
        
        else
            fwrite(buffer, sizeof(char), byteCount, imgFile);
        
        totalBytes += byteCount;
        
    } while (byteCount > 0);
    
    fclose(imgFile);
}
