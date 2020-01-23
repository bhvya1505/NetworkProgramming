#include <stdio.h>
int main()
{
	int pid;
	printf("Original process with PID %d and PPID %d \n", getpid(),getppid());
	pid = fork();
	if(pid!=0)
	{
		printf("Parent process with PID %d and PPID %d \n", getpid(),getppid());
		printf("Child PID %d \n", pid);
	}
	else
	{
		printf("Child process with PID %d and PPID %d \n", getpid(),getppid());
	}
	printf("PID %d terminates \n", pid);
}