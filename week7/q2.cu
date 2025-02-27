#include <cuda.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

__device__ int sumUpto(int n) {
    return (n * (n + 1)) / 2;
}

__global__ void makeString(char* d_rs, char* d_s, int len, int rs_len) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i >= len) return;

    int offset = sumUpto(len) - sumUpto(len - i);

    for (int k = offset; k < offset + len - i; k++) {
        d_rs[k] = d_s[k - offset];
    }
}

int main() {
    char h_s[50];

    printf("Enter string S: ");
    scanf("%s", h_s);

    int len = strlen(h_s);

    int rs_len = len * (len + 1) / 2; // 4 + 3 + 2 + 1 for PCAP
    char h_rs[rs_len + 1];

    char* d_s, *d_rs;
    cudaMalloc((void**) &d_s, len + 1);
    cudaMalloc((void**) &d_rs, rs_len + 1);

    cudaMemcpy(d_s, h_s, len + 1, cudaMemcpyHostToDevice);

    int numThreads = 256;
    int numBlocks = ceil((1.0 * len) / numThreads);

    makeString<<<numBlocks, numThreads>>>(d_rs, d_s, len, rs_len);

    cudaMemcpy(h_rs, d_rs, rs_len + 1, cudaMemcpyDeviceToHost);
    h_rs[rs_len] = '\0';

    printf("String RS: %s\n", h_rs);

    cudaFree(d_s);
    cudaFree(d_rs);
}