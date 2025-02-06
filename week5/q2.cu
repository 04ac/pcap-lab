#include <stdio.h>
#include <stdlib.h>

__global__ void addVecs(int* c, int* a, int* b, int n) {
	int i = blockIdx.x * blockDim.x + threadIdx.x;

	if (i < n) {
		c[i] = a[i] + b[i];
	}
}

__global__ void init_d(int* d, int n, int factor) {
	int i = blockIdx.x * blockDim.x + threadIdx.x;

	if (i < n) {
		d[i] = factor * i;
	}
}

int main() {
	int *c;
	int* d_a, *d_b, *d_c;

	int THREADS_PER_BLOCK = 256;
	int n = 257;

	c = (int*) malloc(n * sizeof(int));

	cudaMalloc(&d_a, n * sizeof(int));
	cudaMalloc(&d_b, n * sizeof(int));
	cudaMalloc(&d_c, n * sizeof(int));

	int NUM_BLOCKS = (n + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK; // for ceil function

	// Initialize device memory
	init_d<<<NUM_BLOCKS, THREADS_PER_BLOCK>>>(d_a, n, 1);
	init_d<<<NUM_BLOCKS, THREADS_PER_BLOCK>>>(d_b, n, 2);

	addVecs<<<NUM_BLOCKS, THREADS_PER_BLOCK>>>(d_c, d_a, d_b, n);

	cudaMemcpy(c, d_c, n * sizeof(int), cudaMemcpyDeviceToHost);

	for (int i = 0; i < n; i++) {
		printf("%d\t", c[i]);
	}
	printf("\nAddition Completed\n");

	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);
	free(c);

	return 0;
}