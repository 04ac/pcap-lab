#include <stdio.h>
#include <stdlib.h>
#include <math.h>

__global__ void sinVec(double* res, double* inp, int n) {
	int i = blockIdx.x * blockDim.x + threadIdx.x;

	if (i < n) {
		res[i] = sin(inp[i]);
	}
}

__global__ void initVec(double* inp, int n) {
	// vector is initialized with multiples of pi / 6

	int i = blockIdx.x * blockDim.x + threadIdx.x;

	if (i < n) {
		inp[i] = i * (M_PI / 6);
	}
}

int main() {
	double* inp, *res, *d_res;

	int THREADS_PER_BLOCK = 4;
	int n = 15;

	cudaMalloc(&inp, n * sizeof(double));
	cudaMalloc(&d_res, n *  sizeof(double));
	res = (double*) malloc(n * sizeof(double));

	int numBlocks = ceil((double) n / THREADS_PER_BLOCK);

	initVec<<<numBlocks, THREADS_PER_BLOCK>>>(inp, n);
	sinVec<<<numBlocks, THREADS_PER_BLOCK>>>(d_res, inp, n);

	cudaMemcpy(res, d_res, n * sizeof(double), cudaMemcpyDeviceToHost);

	for (int i = 0; i < n; i++) {
		printf("%.5f\t", res[i]);
	}
	printf("\n");

	cudaFree(d_res);
	cudaFree(inp);
	free(res);
	return 0;
}