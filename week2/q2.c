#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char *argv[])
{
	int rank, size, value;
	int recvVal;

	MPI_Init(&argc, &argv);

	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	if (rank == 0) {
		printf("Enter int to send to receiver\n");
		scanf("%d", &value);

		for (int i = 1; i < size; i++) {
			MPI_Send(&value, 1, MPI_INT, i, 1, MPI_COMM_WORLD);
		}
	} else {
		MPI_Recv(&recvVal, 1, MPI_INT, 0, 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
		printf("Process %d received %d from master\n", rank, recvVal);
	}
	MPI_Finalize();
	return 0;
}