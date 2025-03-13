#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void matrixAddRowWise(int* A, int* B, int* C, int rows, int cols) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (row < rows) {
        int rowOffset = row * cols;
        for (int j = 0; j < cols; j++) {
            C[rowOffset + j] = A[rowOffset + j] + B[rowOffset + j];
        }
    }
}

__global__ void matrixAddColumnWise(int* A, int* B, int* C, int rows, int cols) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (col < cols) {
        for (int i = 0; i < rows; i++) {
            int index = i * cols + col;
            C[index] = A[index] + B[index];
        }
    }
}

__global__ void matrixAddElementWise(int* A, int* B, int* C, int rows, int cols) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    
    if (row < rows && col < cols) {
        int index = row * cols + col;
        C[index] = A[index] + B[index];
    }
}

// Function to input matrix elements from user
void inputMatrix(int *mat, int rows, int cols, char *name)
{
    printf("Enter the elements of matrix %s (%d x %d):\n", name, rows, cols);
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            printf("%s[%d][%d]: ", name, i, j);
            scanf("%d", &mat[i * cols + j]);
        }
    }
}

// Function to print a matrix
void printMatrix(int *mat, int rows, int cols)
{
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            printf("%d\t", mat[i * cols + j]);
        }
        printf("\n");
    }
}

int main()
{
    // Matrix dimensions
    int ha, wa, wb;

    printf("Enter rows and cols\n");
    scanf("%d %d", &ha, &wa);

    int hb = ha;
    wb = wa;

    // Check if dimensions are valid for the kernel
    if (ha > 1024)
    {
        printf("Error: Number of rows in matrix A cannot exceed 1024 for this implementation.\n");
        return 1;
    }

    // Host matrices
    int *h_a, *h_b, *h_c;

    // Allocate host memory
    h_a = (int *)malloc(ha * wa * sizeof(int));
    h_b = (int *)malloc(hb * wb * sizeof(int));
    h_c = (int *)malloc(ha * wb * sizeof(int));

    // Get matrix values from user
    inputMatrix(h_a, ha, wa, "A");
    inputMatrix(h_b, hb, wb, "B");

    // Device matrices
    int *d_a, *d_b, *d_c;

    // Allocate device memory
    cudaMalloc((void **)&d_a, ha * wa * sizeof(int));
    cudaMalloc((void **)&d_b, hb * wb * sizeof(int));
    cudaMalloc((void **)&d_c, ha * wb * sizeof(int));

    // Copy host matrices to device
    cudaMemcpy(d_a, h_a, ha * wa * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, hb * wb * sizeof(int), cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(16, 16); // 16×16 = 256 threads per block
    dim3 numBlocks(
        (wa + threadsPerBlock.x - 1) / threadsPerBlock.x,
        (ha + threadsPerBlock.y - 1) / threadsPerBlock.y
    );

    // Launch the kernel
    matrixAddElementWise<<<numBlocks, threadsPerBlock>>>(d_a, d_b, d_c, ha, wa);


    cudaMemcpy(h_c, d_c, ha * wb * sizeof(int), cudaMemcpyDeviceToHost);

    // Print matrices
    printf("\nMatrix A:\n");
    printMatrix(h_a, ha, wa);

    printf("\nMatrix B:\n");
    printMatrix(h_b, hb, wb);

    printf("\nResult Matrix C:\n");
    printMatrix(h_c, ha, wb);

    // Free device memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    // Free host memory
    free(h_a);
    free(h_b);
    free(h_c);

    return 0;
}
