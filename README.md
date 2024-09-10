# c5: A full-featured Forth for Windows and Linux in 4 files

c5 is comprised of 4 files:
- c5.c
- c5.h
- system.c
- boot.c5

## CELLs in c5
A `CELL` is either 32-bits or 64-bits, depending on the target system.
- Linux 32-bit (-m32): a CELL is 32-bits.
- Linux 64-bit (-m64): a CELL is 64-bits.
- Windows 32-bit (x86): a CELL is 32-bits.
- Windows 64-bit (x64): a CELL is 64-bits.

## c5 memory areas
c5 provides 3 memory areas:
- code
- variables
- dictionary entries

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
Of course, counted strings can be added if desired.<br/>

## The A and T Stacks
c5 includes 2 additionl stacks, A and T.<br/>
Note that the return stack also has some additional operations.<br/>
The size of these stacks is configurable (see `TSTK_SZ`).<br/>
They can be used for any purpose.<br/>

## c5 primitives
NOTE: To add custom primitives, add X() entries to the `PRIMS` macro in file `c5.c`.

Stack effect notation conventions:

| TERM     | DESCRIPTION |
|:--       |:-- |
| SZ/NM/MD | String, uncounted, NULL terminated |
| A        | Address |
| C        | Number, 8-bits |
| W        | Number, 16-bits |
| N/X/Y    | Number, CELL sized |
| F        | Flag: 0 mean0 false, <>0 means true |
| R        | Register number |
| FH       | File handle: 0 means no file |
| I        | For loop index counter |

The primitives:

| WORD      | STACK        | DESCRIPTION |
|:--        |:--           |:-- |
| (lit1)    | (--N)        | N: opcode for LIT1 primitive |
| (lit2)    | (--N)        | N: opcode for LIT2 primitive |
| (lit4)    | (--N)        | N: opcode for LIT4 primitive |
| (jmp)     | (--W)        | W: opcode for JMP primitive |
| (jmpz)    | (--W)        | W: opcode for JMPZ primitive |
| (jmpnz)   | (--W)        | W: opcode for JMPNZ primitive |
| (njmpz)   | (--W)        | W: opcode for NJMPZ primitive |
| (njmpnz)  | (--W)        | W: opcode for NJMPNZ primitive |
| (exit)    | (--W)        | W: opcode for EXIT primitive |
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
| 0=        | (N--F)       | F: 1 if (N=0), else 0 |
| and       | (X Y--N)     | N: X AND Y |
| or        | (X Y--N)     | N: X OR  Y |
| xor       | (X Y--N)     | N: X XOR Y |
| com       | (X--Y)       | Y: X with all bits flipped (complement) |
| for       | (N--)        | Begin FOR loop with bounds 0 and N. |
| i         | (--I)        | I: Current FOR loop index. |
| next      | (--)         | Increment I. If I < N, start loop again, else exit. |
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
| addword   | (--)         | Add the next word to the dictionary |
| find      | (--W A)      | W: Execution Token, A: Dict Entry address (0 0 if not found) |
| timer     | (--N)        | N: Current time |
| ztype     | (SZ--)       | Print string at SZ (uncounted, unformatted) |
| fopen     | (NM MD--FH)  | NM: File Name, MD: Mode, FH: File Handle (0 if error/not found) |
| fclose    | (FH--)       | FH: File Handle to close |
| fread     | (A N FH--X)  | A: Buffer, N: Size, FH: File Handle, X: num chars read |
| fwrite    | (A N FH--X)  | A: Buffer, N: Size, FH: File Handle, X: num chars written |
| fseek     | (N FH--)     | Set current file offset to N for file FH |
| load      | (N--)        | N: Block number to load (file named "block-NNN.c5") |
| system    | (S--)        | PC ONLY: SC: String to send to `system()` |
| s-cpy     | (D S--D)     | Copy string S to D |
| s-eqi     | (D S--F)     | String compare F: 1 if S and are the same (case-insensitive) |
| s-len     | (S--N)       | N: length of string S |
| fill      | (A B N--)    | Fill N bytes with B starting at address A |
| bye       | (--)         | Exit c5 |
