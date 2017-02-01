#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

void wmsRequest(const char *filepath)
{
    FILE *image = fopen(filepath, "w");
    
    if (!image)
    {
        printf("Error writing file\n");
        return;
    }
    
    struct addrinfo hints, *res;
    int sockfd = 0, byteCount = 0, totalBytes = 0;;
    char buf[10000];
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    getaddrinfo("geoint.lmic.state.mn.us", "80", &hints, &res);
    sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    printf("Connecting...\n");
    connect(sockfd, res->ai_addr, res->ai_addrlen);
    printf("Connected!\n");
    
    char *request =
        "GET /cgi-bin/mncomp?"
        "LAYERS=mncomp"
        "&FORMAT=image%2Fjpeg"
        "&TRANSPARENT=TRUE&SERVICE=WMS"
        "&VERSION=1.1.1"
        "&REQUEST=GetMap"
        "&STYLES="
        "&SRS=EPSG%3A4326"
        "&BBOX=-98.5588,43.9512,-95.0676,47.4424"
        "&WIDTH=1024"
        "&HEIGHT=1024 "
        "HTTP/1.1\nHost: geoint.lmic.state.mn.us\n\n";
    
    send(sockfd, request, strlen(request), 0);
    printf("GET Sent...\n");
    
    do {
        byteCount = recv(sockfd, buf, sizeof(buf), 0);
        fwrite(buf, 1, byteCount, image);
        totalBytes += byteCount;
        printf("received %d bytes of data in buf (%d total bytes)\n", byteCount, totalBytes);
        printf("%.*s\n\n", byteCount, buf);
        
    } while(byteCount > 0);
    
    fclose(image);
}
