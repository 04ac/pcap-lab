#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    int rank, size, matrix[3][3];
    int search_element, local_count = 0, global_count = 0;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    if (rank == 0) {
        printf("Enter the 3x3 matrix:\n");
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                scanf("%d", &matrix[i][j]);
            }
        }
        printf("Enter the element to search: ");
        scanf("%d", &search_element);
    }
    
    MPI_Bcast(&search_element, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Bcast(matrix, 3 * 3, MPI_INT, 0, MPI_COMM_WORLD);
    
    for (int j = 0; j < 3; j++) {
        if (matrix[rank][j] == search_element) {
            local_count++;
        }
    }
    
    MPI_Reduce(&local_count, &global_count, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    
    if (rank == 0) {
        printf("The element %d appears %d times in the matrix.\n", search_element, global_count);
    }
    
    MPI_Finalize();
    return 0;
}
