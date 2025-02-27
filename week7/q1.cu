#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda.h>
#include <math.h>

#define MAX_W 1024
#define MAX_LEN 50

__device__ int gpu_strcmp(char *s1, char *s2) {
    while (*s1 && *s2 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return (*s1 - *s2);  // Return difference of mismatched characters
}

__global__ void countWords(char* d_words, char* d_target, int* d_cnt, int numWords) {
	int i = blockIdx.x * blockDim.x + threadIdx.x;

	if (i >= numWords) return;

	char* curr = &d_words[i * MAX_LEN];

	if (gpu_strcmp(curr, d_target) == 0) {
		atomicAdd(d_cnt, 1);
	}
}

int main() {
	char h_sentence[] = "hello how is life, life is good!";
	char h_target[] = "life";
	int h_cnt = 0;

	char h_words[MAX_W][MAX_LEN];
	int numWords = 0;

	char* token = strtok(h_sentence, " ,!?."); // split on spaces and punctuation

	while (token != NULL && numWords < MAX_W) {
		strcpy(h_words[numWords++], token);
		token = strtok(NULL, " ,!?.");
	}

	char* d_words, *d_target;
	int* d_cnt;

	cudaMalloc((void**) &d_words, numWords * MAX_LEN);
	cudaMalloc((void**) &d_target, strlen(h_target) + 1);
	cudaMalloc((void**) &d_cnt, sizeof(int));

	cudaMemcpy(d_words, h_words, numWords * MAX_LEN, cudaMemcpyHostToDevice);
	cudaMemcpy(d_target, h_target, strlen(h_target) + 1, cudaMemcpyHostToDevice);
	cudaMemcpy(d_cnt, &h_cnt, sizeof(int), cudaMemcpyHostToDevice);

	int numThreads = 256;
	int numBlocks = ceil((1.0 * numWords) / numThreads);

	countWords<<<numBlocks, numThreads>>>(d_words, d_target, d_cnt, numWords);

	cudaMemcpy(&h_cnt, d_cnt, sizeof(int), cudaMemcpyDeviceToHost);

	printf("The word \"%s\" appears %d times\n", h_target, h_cnt);

	cudaFree(d_words);
	cudaFree(d_target);
	cudaFree(d_cnt);
}
