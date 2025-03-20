#include <stdio.h>
#include <cuda.h>

__global__ void replace_rows(int *A, int num_rows, int num_cols) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row >= num_rows) return;

    for (int j = 0; j < num_cols; j++) {
        int idx = row * num_cols + j;
        int power = row + 1;
        A[idx] = pow(A[idx], power);
    }
}

int main() {
    int M, N;
    printf("Enter no of rows and columns : ");
    scanf("%d %d", &M, &N);

    int *A = (int*)malloc(sizeof(int) * M * N);
    printf("Enter the matrix :\n");
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) 
            scanf("%d", &A[i * N + j]);
    }

    int *d_A;
    cudaMalloc(&d_A, sizeof(int) * M * N);
    cudaMemcpy(d_A, A, sizeof(int) * M * N, cudaMemcpyHostToDevice);

    replace_rows<<<(M + 255) / 256, 256>>>(d_A, M, N);

    cudaMemcpy(A, d_A, sizeof(int) * M * N, cudaMemcpyDeviceToHost);

    printf("Modified matrix : \n");
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) 
            printf("%d ", A[i * N + j]);
        printf("\n");
    }

    free(A);
    cudaFree(d_A);
    return 0;
}