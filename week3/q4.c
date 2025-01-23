#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>

int main(int argc, char* argv[]) {
    int rank, size;
    char *S1 = NULL, *S2 = NULL, *subS1 = NULL, *subS2 = NULL, *resultant = NULL;
    int total_len = 0, subStr_len;
    char *local_result;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        printf("Enter the first string: ");
        S1 = (char*) malloc(100 * sizeof(char));
        fgets(S1, 100, stdin);
        total_len += strlen(S1) - 1;

        printf("Enter the second string: ");
        S2 = (char*) malloc(100 * sizeof(char));
        fgets(S2, 100, stdin);
        total_len += strlen(S2) - 1;

        if (total_len % size != 0) {
            printf("String length is not divisible by the number of processes.\n");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }

        resultant = (char*) malloc(total_len + 1);
    }

    MPI_Bcast(&total_len, 1, MPI_INT, 0, MPI_COMM_WORLD);

    subStr_len = total_len / size;

    subS1 = (char*) malloc(subStr_len * sizeof(char));
    subS2 = (char*) malloc(subStr_len * sizeof(char));
    local_result = (char*) malloc(subStr_len * 2 * sizeof(char));

    MPI_Scatter(S1, subStr_len, MPI_CHAR, subS1, subStr_len, MPI_CHAR, 0, MPI_COMM_WORLD);
    MPI_Scatter(S2, subStr_len, MPI_CHAR, subS2, subStr_len, MPI_CHAR, 0, MPI_COMM_WORLD);

    for (int i = 0; i < subStr_len; i++) {
        local_result[2*i] = subS1[i];
        local_result[2*i + 1] = subS2[i];
    }

    MPI_Gather(local_result, subStr_len * 2, MPI_CHAR, resultant, subStr_len * 2, MPI_CHAR, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        resultant[total_len] = '\0';
        printf("The resultant string is: %s\n", resultant);
    }

    MPI_Finalize();
    return 0;
}
