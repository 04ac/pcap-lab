#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

float avg(int* arr, int M) {
	float a = 0.0;

	for (int i = 0; i < M; i++) {
		a += arr[i];
	}

	a /= M;
	return a;
}

int main(int argc, char* argv[]) {
	int rank, size, M;
	int* data;
	int* subData;
	float* avgs;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	if (rank == 0) {
		printf("Enter M\n");
		scanf("%d", &M);

		data = (int*) malloc(size * M * sizeof(int));

		printf("Enter %d x %d values\n", size, M);
		for (int _ = 0; _ < size * M; _++) {
			scanf("%d", &data[_]);
		}

		avgs = (float*) malloc(size * sizeof(float));
	}

    MPI_Bcast(&M, 1, MPI_INT, 0, MPI_COMM_WORLD);
	subData = (int*) malloc(M * sizeof(int));

	MPI_Scatter(data, M, MPI_INT, subData, M, MPI_INT, 0, MPI_COMM_WORLD);
	float a = avg(subData, M);
	printf("Process %d: Avg is %.2f\n", rank, a);
	MPI_Gather(&a, 1, MPI_FLOAT, avgs, 1, MPI_FLOAT, 0, MPI_COMM_WORLD);

	if (rank == 0) {
		float a = 0.0;

		for (int i = 0; i < size; i++) {
			a += avgs[i];
		}

		a /= size;
		printf("Avg calculated by root: %.2f\n", a);
	}
	MPI_Finalize();
}
