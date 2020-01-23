#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main()
{
	int sockfd,afd;
	socklen_t len;
	int sendb, recvb, l;
	char buff[50];
	int res[20];
	struct sockaddr_in server,client;

	sockfd = socket(AF_INET,SOCK_STREAM,0);
	if(sockfd == -1){
		printf("Socket creation error\n" );
		exit(0);
	}
	printf("Socket created\n" );
	server.sin_family = AF_INET;
	server.sin_port = htons(3388);
	server.sin_addr.s_addr = htonl(INADDR_ANY);
	if(bind(sockfd,(struct sockaddr*)&server,sizeof(server)) == -1){
		printf("Socket not bound\n");
		exit(0);
	}
	printf("Socket bound\n" );
	listen(sockfd,1);
	len = sizeof(client);
	afd = accept(sockfd,(struct sockaddr*)&client,&len);
	if(afd==-1){
		printf("Client not connected\n" );
		exit(0);
	}
	printf("Client connected\n");
	l = inet_ntop(AF_INET,&client,buff,sizeof(buff));
	printf("%s\n", buff);
	printf("%d\n", ntohs(client.sin_port));

	close(sockfd);
}