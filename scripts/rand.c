#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
	srand(atoi(argv[1]));
	printf("%i", rand());
	return 0;
}
