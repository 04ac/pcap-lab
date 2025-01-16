#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char *argv[])
{
	int rank, size, val;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	MPI_Buffer_attach(malloc(1000), 1000);

	if (rank == 0) {
		int* arr = (int*) malloc(size * sizeof(int));
		printf("Enter %d values\n", size);

		for (int i = 0; i < size; i++) {
			scanf("%d", &arr[i]);
		}

		for (int i = 1; i < size; i++) {
			MPI_Bsend(&arr[i], 1, MPI_INT, i, 0, MPI_COMM_WORLD);
		}

		printf("Process %d: %d^2 = %d\n", rank, arr[0], arr[0] * arr[0]);
	} else {
		MPI_Recv(&val, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

		if (rank % 2 == 0) {
			printf("Process %d: %d^2 = %d\n", rank, val, val * val);
		} else {
			printf("Process %d: %d^3 = %d\n", rank, val, val * val * val);
		}
	}
	MPI_Finalize();
	return 0;
}