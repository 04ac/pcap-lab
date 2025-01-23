#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>

int isVowel(char c) {
    char vowels[] = "aeiouAEIOU";
    for (int i = 0; i < 10; i++) {
        if (c == vowels[i]) {
            return 1;
        }
    }
    return 0;
}

int countNonVowels(char* str, int len) {
    int count = 0;
    for (int i = 0; i < len; i++) {
        if (!isVowel(str[i])) {
            count++;
        }
    }
    return count;
}

int main(int argc, char* argv[]) {
    int rank, size;
    char *str = NULL, *subStr = NULL;
    int total_len, subStr_len;
    int *counts = NULL;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        printf("Enter the string: ");
        str = (char*) malloc(100 * sizeof(char));
        fgets(str, 100, stdin);
        total_len = strlen(str) - 1;

        if (total_len % size != 0) {
            printf("String length is not divisible by the number of processes.\n");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }

        counts = (int*) malloc(size * sizeof(int));
    }

    MPI_Bcast(&total_len, 1, MPI_INT, 0, MPI_COMM_WORLD);

    subStr_len = total_len / size;
    subStr = (char*) malloc((subStr_len + 1) * sizeof(char));

    MPI_Scatter(str, subStr_len, MPI_CHAR, subStr, subStr_len, MPI_CHAR, 0, MPI_COMM_WORLD);

    int cnt = countNonVowels(subStr, subStr_len);
    MPI_Gather(&cnt, 1, MPI_INT, counts, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        int nv_total = 0;
        printf("Non-vowel counts from each process:\n");
        for (int i = 0; i < size; i++) {
            printf("Process %d: %d non-vowels\n", i, counts[i]);
            nv_total += counts[i];
        }
        printf("Total number of non-vowels: %d\n", nv_total);
    }
    MPI_Finalize();
}