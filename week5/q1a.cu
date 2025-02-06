#include <stdio.h>
#include <stdlib.h>

__global__ void add_a(int *A, int *B, int *C, int N) {
    int i = threadIdx.x;
    if (i < N) {
        C[i] = A[i] + B[i];
    }
}

int main() {
    int N = 5;
    int *h_A, *h_B, *h_C;
    int *d_A, *d_B, *d_C;

    h_A = (int*)malloc(N * sizeof(int));
    h_B = (int*)malloc(N * sizeof(int));
    h_C = (int*)malloc(N * sizeof(int));

    for (int i = 0; i < N; i++) {
        h_A[i] = i;
        h_B[i] = 2 * i;
    }

    cudaMalloc(&d_A, N * sizeof(int));
    cudaMalloc(&d_B, N * sizeof(int));
    cudaMalloc(&d_C, N * sizeof(int));

    cudaMemcpy(d_A, h_A, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, N * sizeof(int), cudaMemcpyHostToDevice);

    // 1 block of N threads
    add_a<<<1, N>>>(d_A, d_B, d_C, N);

    cudaMemcpy(h_C, d_C, N * sizeof(int), cudaMemcpyDeviceToHost);

    for (int i = 0; i < N; i++) {
        printf("%d ", h_C[i]);
    }
    printf("\naddition completed successfully.\n");

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
    free(h_A);
    free(h_B);
    free(h_C);

    return 0;
}
