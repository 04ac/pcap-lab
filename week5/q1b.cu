#include <stdio.h>
#include <stdlib.h>

__global__ void add_b(int* c, int* a, int* b, int N) {
	int i = blockIdx.x;

	if (i < N) {
		c[i] = a[i] + b[i];
	}
}

int main() {
	int* a, *b, *c;
	int* d_a, *d_b, *d_c;
	int N = 5;

	// allocate host memory
	a = (int*) malloc(N * sizeof(int));
	b = (int*) malloc(N * sizeof(int));
	c = (int*) malloc(N * sizeof(int));

	// Initialize vectors
	for (int i = 0; i < n; i++) {
		a[i] = i;
		b[i] = 2 * i;
	}

	// allocate device memory
	cudaMalloc(&d_a, N * sizeof(int));
	cudaMalloc(&d_b, N * sizeof(int));
	cudaMalloc(&d_c, N * sizeof(int));

	cudaMemcpy(d_a, a, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, N * sizeof(int), cudaMemcpyHostToDevice);

	add_b<<<N, 1>>>(d_c, d_a, d_b, N);

	cudaMemcpy(c, d_c, N * sizeof(int), cudaMemcpyDeviceToHost);

    for (int i = 0; i < N; i++) {
        printf("%d ", c[i]);
    }
    printf("\naddition completed successfully.\n");

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    free(a);
    free(b);
    free(c);

    return 0;
}