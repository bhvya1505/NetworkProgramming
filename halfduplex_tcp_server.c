#include<string.h>
#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>
#include<unistd.h>
#include<stdio.h>
#include<stdlib.h>

int main()
{
	int sockfd, afd;
	int sendb, recvb;
	socklen_t len;
	struct sockaddr_in server,client;
	char buff[50];

	sockfd = socket(AF_INET,SOCK_STREAM,0);
	if(sockfd==-1)
	{
		printf("Socket creation error\n");
		exit(0);
	}
	server.sin_family = AF_INET;
	server.sin_port = htons(0);
	server.sin_addr.s_addr = htonl(INADDR_ANY);
	if(bind(sockfd,(struct sockaddr*)&server,sizeof(server))==-1)
	{
		printf("Socket binding error\n");
		exit(0);
	}
	listen(sockfd,1);
	len = sizeof(client);
	afd = accept(sockfd,(struct sockaddr*)&client,&len);
	if(afd==-1)
	{
		printf("Socket creation error\n");
		exit(0);
	}
	recvb = recv(afd,&buff,sizeof(buff),0);
	while(strcmp(buff,"bye"))
	{
		scanf("%s",buff);
		sendb = send(afd,buff,sizeof(buff),0);
		recvb = recv(afd,&buff,sizeof(buff),0);
	}
	close(afd);
	close(sockfd);

}