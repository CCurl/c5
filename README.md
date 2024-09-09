# c5: A full-featured but very minimal Forth for Windows and Linux in 4 files

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
- Windows 64-bit (x64): not supported.

## c5 memory areas
c5 provides 3 memory areas:
- code
- variables
- dictionary entries

Built-in words for the memory areas

| WORD       | STACK   | DESCRIPTION |
|:--         |:--      |:--          |
| (dsp)      | (--N)   | Offset of the data stack pointer |
| (rsp)      | (--N)   | Offset of the return stack pointer |
| (lsp)      | (--N)   | Offset of the loop stack pointer |
| (tsp)      | (--N)   | Offset of the third stack pointer |
| (here)     | (--N)   | Offset of the HERE variable |
| (last)     | (--N)   | Offset of the LAST variable |
| base       | (--N)   | Offset of the BASE variable |
| state      | (--N)   | Offset of the STATE variable |

## c5 Strings
Strings in c5 are NULL terminated, not counted.<br/>
Of course, counted strings can be added if desired.<br/>


## The Third Stack
c5 includes a third stack, with same ops as the return stack.<br/>
Note that the return stack also has some additional operations.<br/>
The size of the third stack is configurable (see `STK_SZ`).<br/>
This third stack can be used for any purpose. Primitives are:<br/>

| WORD  | STACK  | DESCRIPTION |
|:--    |:--     |:-- |
| `>t`  | (N--)  | Move N to the third stack. |
| `t@`  | (--N)  | Copy TOS from the third stack. |
| `t@+` | (--N)  | Copy TOS from the third stack, then Increment it. |
| `t@-` | (--N)  | Copy TOS from the third stack, then decrement it. |
| `t!`  | (N--)  | Store N to the third stack TOS. |
| `t>`  | (--N)  | Move N from the third stack. |

## c5 primitives
NOTE: To add custom primitives, add X() entries to the `PRIMS` macro in file `c5.c`.

Stack effect notation conventions:

| TERM     | DESCRIPTION |
|:--       |:-- |
| SZ/NM/MD | String, uncounted, NULL terminated |
| SC/D/S   | String, counted, NULL terminated |
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
| @         | (A--N)       | N: the CELL at address A |
| c@        | (A--C)       | C: the CHAR at address A |
| w@        | (A--W)       | W: the WORD at address A |
| !         | (N A--)      | Store CELL N to address A |
| c!        | (C A--)      | Store CHAR C to address A |
| w!        | (W A--)      | Store WORD W to address A |
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
| unloop    | (--)         | Unwind the loop stack. NOTE: this does NOT exit the loop. |
| >r        | (N--R:N)     | Move TOS to the return stack |
| r@        | (--N)        | N: return stack TOS |
| r@+       | (--N)        | N: return stack TOS, then increment it |
| r@-       | (--N)        | N: return stack TOS, then decrement it |
| r!        | (N--)        | Set return stack TOS to N |
| r>        | (R:N--N)     | Move return TOS to the stack |
| rdrop     | (R:N--)      | Drop return stack TOS |
| >t        | (N--T:N)     | Move TOS to the third stack |
| t@        | (--N)        | N: third stack TOS |
| t@+       | (--N)        | N: third stack TOS, then increment it |
| t@-       | (--N)        | N: third stack TOS, then decrement it |
| t!        | (N--)        | Set third stack TOS to N |
| t>        | (T:N--N)     | Move third TOS to the stack |
| a!        | (N--)        | Set 'a' to N |
| a@        | (--N)        | N: current value on 'a' |
| a@+       | (--N)        | N: current value on 'a', then increment 'a' |
| a@-       | (--N)        | N: current value on 'a', then decrement 'a' |
| @a        | (--B)        | B: Byte at address 'a' |
| !a        | (B--)        | B: Store B to address 'a' |
| !a+       | (B--)        | B: Store B to address 'a', increment 'a' |
| emit      | (C--)        | Output char C |
| :         | (--)         | Create a new word, set STATE=1 |
| ;         | (--)         | Compile EXIT, set STATE=0 |
| addword   | (--)         | Add the next word to the dictionary |
| timer     | (--N)        | N: Current time |
| ztype     | (SZ--)       | Print string at SZ (uncounted, unformatted) |
| fopen     | (NM MD--FH)  | NM: File Name, MD: Mode, FH: File Handle (0 if error/not found) |
|           |              |     NOTE: NM and MD are uncounted, use `z"` |
| fclose    | (FH--)       | FH: File Handle to close |
| fdelete   | (NM--)       | NM: File Name to delere |
| fread     | (A N FH--X)  | A: Buffer, N: Size, FH: File Handle, X: num chars read |
| fwrite    | (A N FH--X)  | A: Buffer, N: Size, FH: File Handle, X: num chars written |
| load      | (N--)        | N: Block number to load (file named "block-NNN.c5") |
| loaded?   | (W A--)      | Stops current load if A <> 0 (see `find`) |
| find      | (--W A)      | W: Execution Token, A: Dict Entry address (0 0 if not found) |
| system    | (SC--)       | PC ONLY: SC: String to send to `system()` |
| bye       | (--)         | PC ONLY: Exit c5 |
