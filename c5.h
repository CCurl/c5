#ifndef __C5_H__

#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#define IS_WINDOWS 1
#define IS_PC      1
#endif

#ifdef __linux__
#define IS_LINUX   1
#define IS_PC      1
#endif

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

#define VERSION         20240905

#ifdef IS_PC
    #define MAX_CODE    0x00FFFF
    #define MAX_VARS    0x0FFFFF
    #define MAX_DICT    2500*sizeof(DE_T)
    #define STK_SZ            63
    #define LSTK_SZ           60
    #define TSTK_SZ           63
    #define MAX_DISK    0x0FFFFF
    #define btwi(n,l,h)   ((l<=n) && (n<=h))
    #define NO_FILE
#endif // IS_PC

#if INTPTR_MAX > INT32_MAX
    #define CELL_T    int64_t
    #define UCELL_T   uint64_t
    #define CELL_SZ   8
    #define FLT_T     double
    #define addrFmt ": %s $%llx ;"
#else
    #define CELL_T    int32_t
    #define UCELL_T   uint32_t
    #define CELL_SZ   4
    #define FLT_T     float
    #define addrFmt ": %s $%lx ;"
#endif

typedef CELL_T cell;
typedef UCELL_T ucell;
typedef unsigned short ushort;
typedef unsigned char byte;
typedef struct { cell xt; byte flags, len; char name[32-(CELL_SZ+3)]; } DE_T;
typedef struct { byte op; const char* name; byte fl; } PRIM_T;

// These are defined by c5.cpp
extern void inner(cell start);
extern int  outer(const char *src);
extern void Init();

// c5.c needs these to be defined
extern cell inputFp, outputFp;
extern void zType(const char *str);
extern void emit(const char ch);
extern void ttyMode(int isRaw);
extern int  key();
extern int  qKey();
extern cell timer();
extern void saveBlocks();
extern cell fOpen(const char *name, cell mode);
extern void fClose(cell fh);
extern cell fRead(cell buf, cell sz, cell fh);
extern cell fWrite(cell buf, cell sz, cell fh);

#endif //  __C5_H__
