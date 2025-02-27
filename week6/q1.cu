#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>

__global__ void conv1D(float* n, float* m, float* p, int width, int maskWidth) {
    int i = blockDim.x * blockIdx.x + threadIdx.x;

    if (i < width) {
        float k = 0;

        int nStartVal = i - (maskWidth / 2);

        for (int j = 0; j < maskWidth; j++) {
            int nIdx = j + nStartVal;

            if (nIdx >= 0 && nIdx < width) {
                k += n[nIdx] * m[j];
            }
        }
        p[i] = k;
    }
}

int main() {
    int n1,n2;

    printf("Length of the vector: ");
    scanf("%d", &n1);

    printf("Enter the length of mask: ");
    scanf("%d", &n2);

    float n[n1], m[n2], p[n1];
    float *dn, *dm, *dp;

    cudaMalloc((void **) &dn, n1 * sizeof(float));
    cudaMalloc((void **) &dm, n2 * sizeof(float));
    cudaMalloc((void **) &dp, n1 * sizeof(float));

    printf("Enter vector: ");
    for(int i = 0; i < n1; i++)
        scanf("%f", &n[i]);

    printf("Enter mask: ");
    for(int i = 0; i < n2; i++)
        scanf("%f", &m[i]);

    cudaMemcpy(dn, n, n1 * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(dm, m, n2 * sizeof(float), cudaMemcpyHostToDevice);

    dim3 grid(n1,1,1);
    dim3 blk(1,1,1);

    conv1D<<<grid,blk>>>(dn, dm, dp, n1, n2);
    cudaMemcpy(p, dp, n1 * sizeof(float), cudaMemcpyDeviceToHost);

    for(int i = 0; i < n1; i++)
        printf("%f\t", p[i]);
    printf("\n");

    cudaFree(dm);
    cudaFree(dn);
    cudaFree(dp);
}
