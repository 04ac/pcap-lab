#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int factorial(int num) {
    int fact = 1;
    for (int i = 1; i <= num; i++) {
        fact *= i;
    }
    return fact;
}

void custom_error_handler(MPI_Comm *comm, int *errcode, ...) {
    char error_string[200];
    int len;

    MPI_Error_string(*errcode, error_string, &len);
    fprintf(stderr, "MPI Error: %s\n", error_string);
    
    MPI_Abort(*comm, *errcode);
}


int main(int argc, char *argv[]) {
    int rank, size, err;
    int local_fact, scan_result;
    MPI_Errhandler errh;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    MPI_Comm_create_errhandler(custom_error_handler, &errh);
    MPI_Comm_set_errhandler(MPI_COMM_WORLD, errh);

    local_fact = factorial(rank + 1);

    err = MPI_Scan(&local_fact, &scan_result, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
    if (err != MPI_SUCCESS) {
        MPI_Error_class(err, &err);
        MPI_Abort(MPI_COMM_WORLD, err);
    }

    if (rank == size - 1) {
        printf("Sum of factorials (1! + 2! + ... + %d!) = %d\n", size, scan_result);
    }

    MPI_Finalize();
    return 0;
}
