#include<string.h>
#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>
#include<unistd.h>
#include<stdio.h>
#include<stdlib.h>

int main()
{
	int sockfd;
	int sendb, recvb;
	socklen_t len;
	struct sockaddr_in server,client;
	char buff[50];

	sockfd = socket(AF_INET,SOCK_STREAM,0);
	

}