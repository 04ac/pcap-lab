#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char** argv) {
    int rank, size, i, countbuf;
    char word[100];
    int* temp;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if(rank == 0) {
        printf("Enter word of length %d: ", size);
        scanf("%s", word);
    }

    temp = (int*)calloc(size, sizeof(int));

    int lim = rank + 1;
    MPI_Gather(&lim, 1, MPI_INT, temp, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if(rank == 0) {
        printf("Output: ");
        for(int i = 0; i < size; i++) {
            while(temp[i] > 0) {
                printf("%c",word[i]);
                temp[i]--;
            }
        }
        printf("\n");
    }

    MPI_Finalize();

    return 0;
}