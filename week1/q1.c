#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "mpi.h"

int main(int argc, char* argv[]) {
	MPI_Init(&argc, &argv);

	int x = 5, rank;
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	
	int p = pow(x, rank);
	printf("Power: %d\n", p);
	MPI_Finalize();
	return 0;
}
