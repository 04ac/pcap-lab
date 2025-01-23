#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int fact(int n) {
	int ans = 1;
	for (int i = 1; i <= n; i++) {
		ans *= i;
	}
	return ans;
}

int main(int argc, char* argv[]) {
	int rank, size, A[10], B[10], rec;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	if (rank == 0) {
		printf("Enter %d values\n", size);
		for (int _ = 0; _ < size; _++) {
			scanf("%d", &A[_]);
		}
	}

	MPI_Scatter(A, 1, MPI_INT, &rec, 1, MPI_INT, 0, MPI_COMM_WORLD);
	int f = fact(rec);
	printf("Process %d: fact of %d is %d\n", rank, rec, f);
	MPI_Gather(&f, 1, MPI_INT, B, 1, MPI_INT, 0, MPI_COMM_WORLD);

	if (rank == 0) {
		int s = 0;
		for (int i = 0; i < size; i++) {
			s += B[i];
		}
		printf("Sum calculated by root: %d\n", s);
	}
	MPI_Finalize();
}
