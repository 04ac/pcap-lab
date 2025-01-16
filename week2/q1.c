#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <string.h>

void toggleString(char*);

int main(int argc, char *argv[])
{
	int rank;
	char word[50];
	MPI_Status status;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	if (rank == 0) {
		printf("Enter word to send to receiver\n");
		scanf("%[^\n]s", word);

		MPI_Ssend(word, 50, MPI_CHAR, 1, 1, MPI_COMM_WORLD);
		printf("I have sent %s to receiver\n", word);
		MPI_Recv(word, 50, MPI_CHAR, 1, 2, MPI_COMM_WORLD, &status);
		printf("I have received %s from receiver\n", word);
	} else {
		MPI_Recv(word, 50, MPI_CHAR, 0, 1, MPI_COMM_WORLD, &status);
		toggleString(word);
		MPI_Ssend(word, 50, MPI_CHAR, 0, 2, MPI_COMM_WORLD);
	}
	MPI_Finalize();
	return 0;
}

void toggleString(char *word) {
	for (int i = 0; word[i] != '\0'; i++) {
		int conv = 'a' - 'A';
		if (word[i] >= 'a' && word[i] <= 'z') {
			word[i] -= conv;
		} else if (word[i] >= 'A' && word[i] <= 'Z') {
			word[i] += conv;
		}
	}
}
