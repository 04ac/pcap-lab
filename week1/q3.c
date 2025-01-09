#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char *argv[]) {
	MPI_Init(&argc, &argv);

	int rank;
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	int a = 3, b = 4;

	switch (rank) {
		case 0:
			printf("%d + %d = %d\n", a, b, a + b);
			break;
		case 1:
			printf("%d - %d = %d\n", a, b, a - b);
			break;
		case 2:
			printf("%d * %d = %d\n", a, b, a * b);
			break;
		default:
			printf("%d / %d = %.2f\n", a, b, (float) a / b);
			break;
	}

	MPI_Finalize();
	return 0;
}