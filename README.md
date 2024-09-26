# c5: A full-featured Forth for Windows and Linux in 4 files

c5 is comprised of 4 files:
- c5.c      - (The VM)
- c5.h      - (Definitions)
- system.c  - (System-specific support)
- boot.c5   - (The Forth source code)

**Note:** The default boot.c5 is just what I use for interactive use.<br/>
You are 100% free to modify it in any way you desire for your own purposes.<br/>

## Building c5
Building c5 is simple and fast since there are only 2 small source files.

For Windows, there is a `c5.sln` file for Visual Studio.

For Linux, OpenBSD, and FreeBSD, there is a makefile, which uses the system C compiler (specified by the CC variable). Example:

```
# default, 64 bit:
make

or

# for 32 bit:
ARCH=32 make
```

Or you can easily build it from the command line:

```
gcc -m64 -O3 -o c5 *.c

or

clang -m64 -O3 -o c5 *.c
```

## c5 startup activities

When c5 starts, it looks for a filename as the 1st and only argument.<br/>
If a filename is found, and it can open that file, then that becomes the source file.<br/>
If no filename is given, c5 tries to open and use `boot.c5` as the source file.<br/>

## CELLs in c5
A `CELL` is either 32-bits or 64-bits, depending on the target system.
- Linux 64-bit (-m64): a CELL is 64-bits.
- Linux 32-bit (-m32): a CELL is 32-bits.
- Windows 64-bit (x64): a CELL is 64-bits.
- Windows 32-bit (x86): a CELL is 32-bits.

## c5 memory areas
c5 provides 3 memory areas:
- code (default size: 64k - see `MAX_CODE`)
- variables (default size: 2 million - see `MAX_VARS`)
- dictionary entries (default size: 2500 entries - see `MAX_DICT`)

Built-in words for the memory areas

| WORD       | STACK   | DESCRIPTION |
|:--         |:--      |:--          |
| code       | (--A)   | Start of the code area. |
| vars       | (--A)   | Start of the vars area. |
| dict       | (--A)   | Start of the dict area. |
| (ha)       | (--A)   | Address of the HERE variable |
| (la)       | (--A)   | Address of the LAST variable |
| (vha)      | (--A)   | Address of the VHERE variable |

## c5 Strings
Strings in c5 are NULL terminated, not counted.<br/>
Of course, counted strings can be implemented if desired.<br/>

## The A and T Stacks
c5 includes 2 additional stacks, A and T.<br/>
Note that the return stack also has some additional operations.<br/>
The size of these stacks is configurable (default 64 - see `TSTK_SZ`).<br/>
They can be used for any purpose.<br/>

## c5 primitives
NOTE: To add custom primitives, add X() entries to the `PRIMS` macro in file `c5.c`.

Stack effect notation conventions:

| TERM      | DESCRIPTION |
|:--        |:-- |
| S/D/NM/MD | String, uncounted, NULL terminated |
| A         | Address |
| B,C       | Byte/Char, 8-bits |
| W         | Number, 16-bits |
| N/X/Y     | Number, CELL sized |
| F         | Flag: 0 means false, <>0 means true |
| FH        | File handle: 0 means no file |
| I         | For loop index counter |

The opcodes/primitives:

| WORD      | STACK        | DESCRIPTION |
|:--        |:--           |:-- |
| (lit1)    | (--N)        | N: opcode value for the LIT1 primitive |
| (lit2)    | (--N)        | N: opcode value for the LIT2 primitive |
| (lit4)    | (--N)        | N: opcode value for the LIT4 primitive |
| (jmp)     | (--N)        | N: opcode value for the JMP primitive |
| (jmpz)    | (--N)        | N: opcode value for the JMPZ primitive |
| (jmpnz)   | (--N)        | N: opcode value for the JMPNZ primitive |
|           |              | **NOTE: `JMPZ` and `JMPNZ` POP the stack|
| (njmpz)   | (--N)        | N: opcode value for the NJMPZ primitive |
| (njmpnz)  | (--N)        | N: opcode value for the NJMPNZ primitive |
|           |              | **NOTE: `NJMPZ` and `NJMPNZ` do NOT POP the stack|
| (exit)    | (--N)        | N: opcode value for the EXIT primitive |
| exit      | (--)         | EXIT word |
| dup       | (X--X X)     | Duplicate TOS (Top-Of-Stack) |
| swap      | (X Y--Y X)   | Swap TOS and NOS (Next-On-Stack) |
| drop      | (N--)        | Drop TOS |
| over      | (N X--N X N) | Push NOS |
| c@        | (A--C)       | C: the CHAR at address A |
| w@        | (A--W)       | W: the WORD at address A |
| @         | (A--N)       | N: the CELL at address A |
| c!        | (C A--)      | Store CHAR C to address A |
| w!        | (W A--)      | Store WORD W to address A |
| !         | (N A--)      | Store CELL N to address A |
| +         | (X Y--N)     | N: X + Y |
| -         | (X Y--N)     | N: X - Y |
| *         | (X Y--N)     | N: X * Y |
| /         | (X Y--N)     | N: X / Y (integer division) |
| /mod      | (X Y--M Q)   | M: X modulo Y, Q: quotient of X / Y |
| 1+        | (X--Y)       | Increment TOS |
| 1-        | (X--Y)       | Decrement TOS |
| <         | (X Y--F)     | F: 1 if (X < Y), else 0 |
| =         | (X Y--F)     | F: 1 if (X = Y), else 0 |
| >         | (X Y--F)     | F: 1 if (X > Y), else 0 |
| 0=        | (N--F)       | F: 1 if (N = 0), else 0 |
| and       | (X Y--N)     | N: X AND Y |
| or        | (X Y--N)     | N: X OR  Y |
| xor       | (X Y--N)     | N: X XOR Y |
| com       | (X--Y)       | Y: X with all bits flipped (complement) |
| for       | (N--)        | Begin a FOR loop with bounds 0 and N. |
| i         | (--I)        | I: Current FOR loop index. |
| next      | (--)         | Increment I. If (I < N), start loop again, else exit. |
| >r        | (N--)        | Move TOS to the return stack |
| r@        | (--N)        | N: return stack TOS |
| r@+       | (--N)        | N: return stack TOS, then increment it |
| r@-       | (--N)        | N: return stack TOS, then decrement it |
| r!        | (N--)        | Set return stack TOS to N |
| r>        | (--N)        | Move return TOS to the stack |
| rdrop     | (N--)        | Drop return stack TOS |
| >t        | (N--N)       | Move TOS to the T stack |
| t@        | (--N)        | N: T-TOS |
| t@+       | (--N)        | N: T-TOS, then increment T-TOS |
| t@-       | (--N)        | N: T-TOS, then decrement T-TOS |
| t!        | (N--)        | Set T-TOS to N |
| t>        | (N--N)       | Move T-TOS to the stack |
| >a        | (N--N)       | Move TOS to the A stack |
| a!        | (N--)        | Set A-TOS to N |
| a@        | (--N)        | N: A-TOS |
| a@+       | (--N)        | N: A-TOS, then increment A-TOS |
| a@-       | (--N)        | N: A-TOS, then decrement A-TOS |
| a>        | (--N)        | Move A-TOS to the stack |
| emit      | (C--)        | Output char C |
| :         | (--)         | Create a new word, set STATE=1 |
| ;         | (--)         | Compile EXIT, set STATE=0 |
| outer     | (S--)        | Parse S using the outer interpreter |
| addword   | (--)         | Add the next word to the dictionary |
| find      | (--X A)      | X: Execution Token, A: Dict Entry address (0 0 if not found) |
| timer     | (--N)        | N: Current time |
| ztype     | (S--)        | Print string at S (uncounted, unformatted) |
| fopen     | (NM MD--FH)  | NM: File Name, MD: Mode, FH: File Handle (0 if error/not found) |
| fclose    | (FH--)       | FH: File Handle to close |
| fread     | (A N FH--X)  | A: Buffer, N: Size, FH: File Handle, X: num chars read |
| fwrite    | (A N FH--X)  | A: Buffer, N: Size, FH: File Handle, X: num chars written |
| fseek     | (N FH--)     | Set current file offset to N for file FH |
| system    | (S--)        | S: String to send to `system()` |
| s-cpy     | (D S--D)     | Copy string S to D |
| s-eqi     | (D S--F)     | String compare F: 1 if S and D are the same (case-insensitive) |
| s-len     | (S--N)       | N: length of string S |
| fill      | (A B N--)    | Fill N bytes with B starting at address A |
| bye       | (--)         | Exit c5 |

## c5 Built-in words

There are very few default words in addition to the above primitives.<br/>
This is because of a desire to give the programmer as much freedom as possible.<br/>
Any system desired can be built from the primitives and the source file.<br/>
The default source file, `boot.c5` is simply the system I start with.<br/>

| WORD      | STACK        | DESCRIPTION |
|:--        |:--           |:-- |
| (ha)      | ( --A )      | A: The address of the HERE variable |
| (vha)     | ( --A )      | A: The address of the VHERE variable |
| (la)      | ( --A )      | A: The address of the LAST variable |
| base      | ( --A )      | A: The address of the BASE variable |
| state     | ( --A )      | A: The address of the STATE variable |
| >in       | ( --A )      | A: The address of the >in variable |
| (dsp)     | ( --A )      | A: The address of the data stack pointer |
| dstk      | ( --A )      | A: The address of the data stack |
| (rsp)     | ( --A )      | A: The address of the return stack stack pointer |
| rstk      | ( --A )      | A: The address of the return stack |
| (tsp)     | ( --A )      | A: The address of the T stack pointer |
| tstk      | ( --A )      | A: The address of the T stack |
| (asp)     | ( --A )      | A: The address of the A stack pointer |
| astk      | ( --A )      | A: The address of the A stack |
| (lsp)     | ( --A )      | A: The address of the loop stack pointer |
| lstk      | ( --A )      | A: The address of the loop stack |
| code      | ( --A )      | A: The address of the CODE area |
| vars      | ( --A )      | A: The address of the VARS area |
| dict      | ( --A )      | A: The address of the DICT area |
| code-sz   | ( --N )      | N: The size of the CODE area |
| vars-sz   | ( --N )      | N: The size of the VARS area |
| dict-sz   | ( --N )      | N: The size of the DICT area |
| de-sz     | ( --N )      | N: The size of the a dictionary entry |
| stk-sz    | ( --N )      | N: The size of the data and return stacks |
| tstk-sz   | ( --N )      | N: The size of the A and T stacks |
| lstk-sz   | ( --N )      | N: The size of the loop stack |
| cell      | ( --N )      | N: The size of a CELL |
