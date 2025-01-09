#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
	MPI_Init(&argc, &argv);

	int rank;
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	if (rank % 2) {
		printf("World\n");
	} else {
		printf("Hello\n");
	}

	MPI_Finalize();
	return 0;
}