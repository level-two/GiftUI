#include <stdio.h>
#include <unistd.h>
#include <errno.h>
static int remaining = 4096;
static int partial_write(void *context, const char *bytes, int size) {
    (void)context;
    if (remaining == 0) { errno = ENOSPC; return -1; }
    int accepted = size < remaining ? size : remaining;
    int result = (int)write(STDOUT_FILENO, bytes, (size_t)accepted);
    if (result > 0) remaining -= result;
    return result;
}
void p08_test_partial_stream(void) {
    FILE *replacement = funopen(NULL, NULL, partial_write, NULL, NULL);
    if (replacement == NULL) _exit(97);
    setbuf(replacement, NULL);
    stdout = replacement;
}
