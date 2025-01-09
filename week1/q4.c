#include "mpi.h"
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
	MPI_Init(&argc, &argv);

	char str[50];
	strcpy(str, "HELLO WORLD");

	int rank;
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	int conv = 'a' - 'A';
	if (str[rank] >= 'a' && str[rank] <= 'z') {
		str[rank] -= conv;
	} else if (str[rank] >= 'A' && str[rank] <= 'Z') {
		str[rank] += conv;
	}

	printf("Rank: %d, word: %s\n", rank, str);
	MPI_Finalize();
	return 0;
}
