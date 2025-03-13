#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void multiplyKernel_rowwise(int *a, int *b, int *c, int wa, int wb)
{
    int ridA = threadIdx.x;
    int sum;
    for (int cidB = 0; cidB < wb; cidB++)
    {
        sum = 0;
        for (int k = 0; k < wa; k++)
        {
            sum += (a[ridA * wa + k] * b[k * wb + cidB]);
        }
        c[ridA * wb + cidB] = sum;
    }
}

__global__ void multiplyKernel_colwise(int *a, int *b, int *c, int ha, int wa)
{
    int cidB = threadIdx.x;
    int wb = blockDim.x;
    int sum, k;
    for (int ridA = 0; ridA < ha; ridA++)
    {
        sum = 0;
        for (k = 0; k < wa; k++)
        {
            sum += (a[ridA * wa + k] * b[k * wb + cidB]);
        }
        c[ridA * wb + cidB] = sum;
    }
}

__global__ void multiplyKernel_elementwise(int *a, int *b, int *c, int wa)
{
    int ridA = threadIdx.y;
    int cidB = threadIdx.x;
    int wb = blockDim.x;
    int sum = 0, k;
    for (k = 0; k < wa; k++)
    {
        sum += (a[ridA * wa + k] * b[k * wb + cidB]);
    }
    c[ridA * wb + cidB] = sum;
}

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

    printf("Enter the dimensions of matrix A (rows columns): ");
    scanf("%d %d", &ha, &wa);

    printf("Enter the number of columns for matrix B: ");
    scanf("%d", &wb);

    // Height of matrix B must equal width of A
    int hb = wa;

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

    // Launch kernel
    multiplyKernel_elementwise<<<(1, 1), (wb,ha)>>>(d_a, d_b, d_c, wa);

    cudaMemcpy(h_c, d_c, ha * wb * sizeof(int), cudaMemcpyDeviceToHost);

    // Print matrices
    printf("\nMatrix A:\n");
    printMatrix(h_a, ha, wa);

    printf("\nMatrix B:\n");
    printMatrix(h_b, hb, wb);

    printf("\nResult Matrix C (A × B):\n");
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
