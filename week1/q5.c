#include <stdio.h>
#include "mpi.h"

int fib(int n) {
	if (n == 0) return 0;

	int dp[n + 1];

	dp[0] = 0; // fib(0) == 0
	dp[1] = 1; // fib(1) == 1

	for (int i = 2; i <= n; i++) {
		dp[i] = dp[i - 1] + dp[i - 2];
	}
	return dp[n];
}

int fact(int n) {
	int ans = 1;
	for (int i = 2; i <= n; i++) {
		ans *= i;
	}
	return ans;
}

int main(int argc, char **argv) {
	MPI_Init(&argc, &argv);

	int rank;
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	if (rank % 2 == 0) {
		printf("%d! = %d\n", rank, fact(rank));
	} else {
		printf("fib(%d) = %d\n", rank, fib(rank));
	}
	MPI_Finalize();
	return 0;
}