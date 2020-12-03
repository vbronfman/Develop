#include <stdio.h>
#include <string.h>
#include <stdio.h>


int main()
{
    char buffer[60];
    int read;
    unsigned int len;
    
    scanf("%[^\n]",buffer);
    printf("Hello, World! %s \n",buffer);
    int i=strlen(buffer);
    for (int i=strlen(buffer);i>1;i-1) 
 {
printf ("DEBUG i=%d %d",strlen(buffer),i);
}
    return 0;
}