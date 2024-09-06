#include "c5.h"

#ifdef IS_WINDOWS

#include <conio.h>
int qKey() { return _kbhit(); }
int key() { return _getch(); }
void ttyMode(int isRaw) {}

#endif

#ifdef IS_LINUX // Support for Linux

#include <termios.h>
#include <unistd.h>
#include <sys/time.h>

void ttyMode(int isRaw) {
    static struct termios origt, rawt;
    static int curMode = -1;
    if (curMode == -1) {
        curMode = 0;
        tcgetattr( STDIN_FILENO, &origt);
        cfmakeraw(&rawt);
    }
    if (isRaw != curMode) {
        if (isRaw) {
            tcsetattr( STDIN_FILENO, TCSANOW, &rawt);
        } else {
            tcsetattr( STDIN_FILENO, TCSANOW, &origt);
        }
        curMode = isRaw;
    }
}
int qKey() {
    struct timeval tv;
    fd_set rdfs;
    ttyMode(1);
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    FD_ZERO(&rdfs);
    FD_SET(STDIN_FILENO, &rdfs);
    select(STDIN_FILENO+1, &rdfs, NULL, NULL, &tv);
    int x = FD_ISSET(STDIN_FILENO, &rdfs);
    // ttyMode(0);
    return x;
}
int key() {
    ttyMode(1);
    int x = fgetc(stdin);
    // ttyMode(0);
    return x;
}

#endif // IS_LINUX

#ifdef IS_PC
cell timer() { return (cell)clock(); }
void zType(const char* str) { fputs(str, outputFp ? (FILE*)outputFp : stdout); }
void emit(const char ch) { fputc(ch, outputFp ? (FILE*)outputFp : stdout); }

cell fOpen(const char *name, cell mode) { return (cell)fopen(name, (char*)mode); }
void fClose(cell fh) { fclose((FILE*)fh); }
cell fRead(cell buf, cell sz, cell fh) { return (cell)fread((char*)buf, 1, sz, (FILE*)fh); }
cell fWrite(cell buf, cell sz, cell fh) { return (cell)fwrite((char*)buf, 1, sz, (FILE*)fh); }
cell fSeek(cell fh, cell offset) { return (cell)fseek((FILE*)fh, SEEK_SET, offset); }

void repl() {
    zType(" ok\n");
    char tib[256];
    if (fgets(tib, 256, stdin) != tib) { exit(0); }
    outer(tib);
}

int main(int argc, char *argv[]) {
	Init();
    while (1) { repl(); }
	return 0;
}

#endif // is_PC
