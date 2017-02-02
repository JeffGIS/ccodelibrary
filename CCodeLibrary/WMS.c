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

bool wmsRequest(const char *filepath, dbounds bounds, unsigned short width, unsigned short height)
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
        return FALSE;
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
    return TRUE;
}

#include "WMS.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define HEADER_LENGTH 185
#define BUFFER_SIZE 24576
#define QUERY_SIZE 320

bool wmsRequest_jeff(const char *filepath, dbounds bounds, unsigned short width, unsigned short height)
{
    FILE *imgFile;
    struct addrinfo hints, *res;
    int sockfd = 0, totalBytes = 0;
    long byteCount = 0;
    bool skip = FALSE;
    char buffer[BUFFER_SIZE], ch;
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
        return FALSE;
    }
    
    char header[HEADER_LENGTH+2] = {0};
    int hlen = 0;
    int ii = 0x11f9e;
    char headerTerminate[4] = {'\r','\n','\r','\n'};
    LPINT pHeaderTerminate = (LPINT)headerTerminate;
    char last4bytes[4];
    
    byteCount = recv(sockfd, buffer, 4, 0);
    if (byteCount <= 0)
        goto ErrOut;
    memmove (last4bytes,buffer,4);
    memmove (header,buffer,4);
    hlen = byteCount;
    // read the WMS header
    while (*(LPINT)last4bytes != *pHeaderTerminate)
    {
        byteCount = recv(sockfd, buffer, 1, 0);
        if (byteCount <= 0)
            goto ErrOut;
        memmove (last4bytes,&last4bytes[1],3);
        last4bytes[3] = buffer[0];
        if (hlen < HEADER_LENGTH)
            header[hlen++] = buffer[0];
    }
    printf (header);
    
#define CHUNK_HEADER_LENGTH 32
    char chunkHeader[CHUNK_HEADER_LENGTH+4];
    int chlen=0;
    char chunkHeaderTerminate[2] = {'\r','\n'};
    LPSHORT pchunkHeaderTerminate = (LPSHORT)chunkHeaderTerminate;
    char last2bytes[2];
    
GetNextChunk:
    //read the next chunk header
    chlen = 0;
    byteCount = recv(sockfd, buffer, 2, 0);
    if (byteCount <= 0)
        goto ErrOut;
    memmove (last2bytes,buffer,2);
    memmove (&chunkHeader[chlen],buffer,2);
    chlen += 2;
    while (*(LPSHORT)last2bytes != *pchunkHeaderTerminate)
    {
        byteCount = recv(sockfd, buffer, 1, 0);
        if (byteCount <= 0)
            goto ErrOut;
        memmove (last2bytes,&last2bytes[1],1);
        last2bytes[1] = buffer[0];
        if (chlen < CHUNK_HEADER_LENGTH)
            chunkHeader[chlen++] = buffer[0];
        else
            goto ErrOut;
    }
    chunkHeader[chlen-2] = 0;
    int chunkLen = strtol (chunkHeader,0,16);
    if (chunkLen <= 0)
    {
        fclose(imgFile);
        return TRUE;
    }
    
    //get the next chunk
    LPSTR chunk = malloc (chunkLen+2);
    int lChunk = 0;
    int lRemain = chunkLen;
    while (lRemain > 0)
    {
        byteCount = recv(sockfd, &chunk[lChunk], lRemain, 0);
        if (byteCount <= 0)
            goto ErrOut;
        lRemain -= byteCount;
        lChunk += byteCount;
    }
    fwrite (chunk,lChunk,1,imgFile);
    free (chunk);
    
    // read the trailing \r\n
    byteCount = recv(sockfd,last2bytes, 2, 0);
    if (byteCount <= 0)
        goto ErrOut;
    if (*(LPSHORT)last2bytes != *pchunkHeaderTerminate)
        goto ErrOut;
    
    goto GetNextChunk;
    
ErrOut:
    return FALSE;
}

