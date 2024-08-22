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

#define VERSION   20240830

#ifdef IS_PC
    #define MAX_CODE    0x00FFFF
    #define MAX_VARS    0x0FFFFF
    #define MAX_DICT    0x03FFFF
    #define STK_SZ            63
    #define LSTK_SZ           60
    #define TSTK_SZ           63
    #define BLOCK_SZ        1000
    #define MAX_BLOCKNUM     999
    #define btwi(n,l,h)   ((l<=n) && (n<=h))
    #define NO_FILE
    #define SYS_PRIMS \
	    X(SYSTEM,  "system",    0, t=pop(); ttyMode(0); system((char*)t); )
#else
    // Must be a dev board ...
    #include <Arduino.h>
    #define IS_BOARD
    #define CODE_SZ       0xDFFF    // 0xE000 and above are numbers
    #define VARS_SZ      0x10000
    #define DICT_SZ       0x4000
    #define STK_SZ            63
    #define RSTK_SZ           63
    #define LSTK_SZ           60
    #define TSTK_SZ           63
    #define FSTK_SZ           15
    #define REGS_SZ          200
    #define btwi(n,l,h)   ((l<=n) && (n<=h))
    #if defined(ARDUINO_TEENSY40)
        #define TEENSY_FILE
    #elif defined(ARDUINO_ARCH_RP2040)
        #define PICO_FILE
    #else
        #define NO_FILE
    #endif
    #define SYS_PRIMS \
        X(POPENI,  "pin-input",  0, t=pop(); pinMode(t, INPUT); ) \
        X(POPENO,  "pin-output", 0, t=pop(); pinMode(t, OUTPUT); ) \
        X(POPENU,  "pin-pullup", 0, t=pop(); pinMode(t, INPUT_PULLUP); ) \
        X(PDREAD,  "dpin@",      0, TOS = digitalRead(TOS); ) \
        X(PDWRITE, "dpin!",      0, t=pop(); n=pop(); digitalWrite(t, n); ) \
        X(PAREAD,  "apin@",      0, TOS = analogRead(TOS); ) \
        X(PAWRITE, "apin!",      0, t=pop(); n=pop(); analogWrite(t, n); ) \
        X(PDELAY,  "ms",         0, t=pop(); delay(t); )
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
typedef struct { cell xt; byte flags, len; char name[32]; } DE_T;
typedef struct { byte op; const char* name; byte fl; } PRIM_T;

// These are defined by c5.cpp
extern void inner(cell start);
extern int  outer(const char *src);
extern void Init();
/*
extern void push(cell x);
extern cell pop();
extern void strCpy(byte *d, const byte *s);
extern int  strEq(const byte *d, const byte *s);
extern int  strEqI(const byte *d, const byte *s);
extern int  strLen(const byte *s);
extern int  lower(const char c);
extern void defNum(const byte *name, cell val);
*/

// c5.cpp needs these to be defined
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
