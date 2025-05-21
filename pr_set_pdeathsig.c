#include <stdio.h>
#include <stdlib.h>
#include <sys/prctl.h>
#include <unistd.h>

/**
 * Executes a command such that if the parent
 * receives some signal, this child thread dies
 * Useful for dying when a parent is SIGKILLed
 */
int main(int argc, char *argv[]) {
    if (argc <= 2) {
        fprintf(stderr, "Usage: %s <signal> <command> <args>*\n", argv[0]);
        return 1;
    }

    int signal = atoi(argv[1]);
    if (prctl(PR_SET_PDEATHSIG, signal) == -1) {
        perror("prctl");
        return 1;
    }

  return execvp(argv[2], &argv[2]);
}
