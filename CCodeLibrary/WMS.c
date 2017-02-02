#include "WMS.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define BUFFER_SIZE 24576
#define QUERY_SIZE 320
#define CHUNK_SIZE 16

void wmsRequest(const char *filepath, dbounds bounds, unsigned short width, unsigned short height)
{
    FILE *imgFile;
    struct addrinfo hints, *res;
    int sockfd = 0;
    long byteCount = 0, chunkLength = 0;
    unsigned char state = 1;
    char buffer[BUFFER_SIZE], ch;
    char *chunkHeader = (char *)calloc(CHUNK_SIZE, sizeof(char));
    char *request = (char *)calloc(QUERY_SIZE, sizeof(char));
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
        
        for (int i = 0; i < byteCount; i++)
        {
            ch = buffer[i];
            
            switch (state)
            {
                case 1:
                    if (ch == '\r' && buffer[i+1] == '\n' && buffer[i+2] == '\r' && buffer[i+3] == '\n')
                    {
                        i += 3;
                        state++;
                        printf("\n");
                    }
                    
                    else
                        printf("%c", ch);
                    break;
                case 2:
                    if (ch == '\r' && buffer[i+1] == '\n')
                    {
                        i++;
                        state++;
                        chunkLength = strtol(chunkHeader, NULL, 16);
                        printf("New chunk (length %li)\n", chunkLength);
                    }
                    
                    else
                        sprintf(chunkHeader, "%s%c", chunkHeader, ch);
                    break;
                case 3:
                    if (chunkLength == 0)
                    {
                        i++;
                        state--;
                        memset(chunkHeader,0,strlen(chunkHeader));
                    }
                    
                    else
                    {
                        fputc(ch, imgFile);
                        chunkLength--;
                    }
                    
                    break;
                default:
                    break;
            }
        }
        
    } while (byteCount > 0);
    
    free(chunkHeader);
    fclose(imgFile);
}
