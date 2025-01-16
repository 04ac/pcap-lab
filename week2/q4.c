#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char *argv[])
{
	int rank, size, val;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	if (rank == 0) {
		printf("Enter int value\n");
		scanf("%d", &val);

		val++;
		MPI_Ssend(&val, 1, MPI_INT, (rank + 1) % size, 0, MPI_COMM_WORLD);
		MPI_Recv(&val, 1, MPI_INT, size - 1, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
		printf("Process %d received %d from process %d\n", rank, val, size - 1);
	} else {
		MPI_Recv(&val, 1, MPI_INT, rank - 1, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
		printf("Process %d received %d from process %d\n", rank, val, rank - 1);
		val++;
		MPI_Ssend(&val, 1, MPI_INT, (rank + 1) % size, 0, MPI_COMM_WORLD);
	}
	MPI_Finalize();
	return 0;
}