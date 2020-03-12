#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <stdio.h>

int main()
{
	int sockfd;
	int sendb,recvb;
	char buff[50];
	int res[20];
	struct sockaddr_in server;

	sockfd = socket(AF_INET,SOCK_STREAM,0);
	if(sockfd == -1){
		printf("Socket not bound\n");
		exit(0);
	}
	printf("Socket bound\n" );
	server.sin_family = AF_INET;
	server.sin_port = htons(3388);
	server.sin_addr.s_addr = inet_addr("127.0.0.1");

	if(connect(sockfd,(struct sockaddr*)&server,sizeof(server)) == -1){
		printf("Connected to server failed\n");
		exit(0);
	}
	printf("Connected\n");

	close(sockfd);
}