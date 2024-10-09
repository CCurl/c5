(ha) @ (la) @ (vha) @
: here  (ha)  @ ;
: vhere (vha) @ ;
: last  (la)  @ ;
: c, here dup 1+     (ha) ! c! ;
: w, here dup 2 +    (ha) ! w! ;
: ,  here dup cell + (ha) ! ! ;
: allot vhere + (vha) ! ;
: const addword (lit4) c, , (exit) c, ;
: var   vhere const allot ;

const -vha-
const -la-
const -ha-

: immediate 1 last cell + c! ;
: inline    2 last cell + c! ;

: begin here ; immediate
: while  (jmpnz)  c, , ; immediate
: -while (njmpnz) c, , ; immediate
: until  (jmpz)   c, , ; immediate
: -until (njmpz)  c, , ; immediate
: again  (jmp)    c, , ; immediate

: if (jmpz)   c, here 0 , ; immediate
: -if (njmpz) c, here 0 , ; immediate
: if0 (jmpnz) c, here 0 , ; immediate
: else (jmp)  c, here swap 0 , here swap ! ; immediate
: then here swap ! ; immediate

: #neg dup 0 < dup >a if com 1+ then ;
: <#  #neg last 32 - >t 0 t@ c! ;
: hold t@- 1- c! ;
: #   base @ /mod swap '0' + dup '9' > if 7 + then hold ;
: #s  begin # -while drop ;
: #>  a> if '-' hold then t> ;

: a+  a@+ drop ; inline
: @a  a@  c@ ; inline
: @a+ a@+ c@ ; inline
: @a- a@- c@ ; inline
: !a  a@  c! ; inline
: !a+ a@+ c! ; inline
: !a- a@- c! ; inline
: t-  t@- drop ; inline
: @t  t@  c@ ; inline
: @t+ t@+ c@ ; inline
: @t- t@- c@ ; inline
: !t  t@  c! ; inline
: !t+ t@+ c! ; inline
: !t- t@- c! ; inline
: adrop  a> drop ; inline
: tdrop  t> drop ; inline
: atdrop a> drop t> drop ; inline

: ( >in @ >a 
   begin
      @a+ ')' = if  a@ >in !  adrop  exit  then 
   again ; immediate

( now we can have comments! )

: comp?   ( --n ) state @ ;
: (quote) ( -- )  vhere dup >t  >in @ 1+ >a
   begin
      @a '"' = if
         0 !t+  a> 1+ >in !
         comp? if t> (vha) ! (lit4) c, , exit then
         tdrop exit
      then @a+ !t+
   again ;

: "  (quote) ; immediate
: ." (quote) comp? if (ztype) c, exit then ztype ; immediate

: bl 32 ; inline
: tab 9 emit ; inline
: cr 13 emit 10 emit ; inline
: space bl emit ; inline
: negate com 1+ ; inline
: abs dup 0 < if negate then ;

: (.)  ( n-- ) <# #s #> ztype ;
: .  ( n-- ) (.) space ;
: .2 ( n-- ) <# # #s #> ztype space ;
: .3 ( n-- ) <# # # #s #> ztype space ;
: hex     $10 base ! ;
: decimal #10 base ! ;
: binary  %10 base ! ;
: .hex ( n-- ) base @ >t hex     .2 t> base ! ;
: .dec ( n-- ) base @ >t decimal .3 t> base ! ;
: .bin ( n-- ) base @ >t binary  .  t> base ! ;

: execute ( xt-- ) >r ;
: :noname here 1 state ! ;
: [ 0 state ! ; immediate
: ] 1 state ! ;
: cells cell * ; inline
: cell+ cell + ; inline
: 2+ 1+ 1+ ; inline
: 2* dup + ; inline
: 2/ 2 / ; inline
: 2dup over over ; inline
: 2drop drop drop ; inline
: mod /mod drop ; inline
: ?dup -if dup then ;
: ? @ . ;
: nip  swap drop ; inline
: tuck swap over ; inline
: +! ( n a-- ) tuck @ + swap ! ;
: min ( a b--c ) 2dup > if swap then drop ;
: max ( a b--c ) 2dup < if swap then drop ;
: vc, vhere c! 1 allot ;
: v, vhere ! cell allot ;
: unloop (lsp) @ 0 max (lsp) ! ;
: 0sp  0 (dsp) ! ;
: 0rsp 0 (rsp) ! ;

( .s )
: depth (dsp) @ 1- ;
: lpar '(' emit ; inline
: rpar ')' emit ; inline
: .s lpar space depth ?dup if
      for i 1+ cells dstk + @ . next
   then rpar ;

( words )
dict dict-sz + 1- const dict-end
: de>xt    @ ;
: de>flags cell + c@ ;
: de>len   cell + 1+ c@ ;
: de>name  cell + 2+ ;
: .word ( de-- ) de>name ztype ;
: .de-word ( de-- ) .word t@+ 10 > if 0 t! cr exit then tab ;
: words last >a 1 >t 0 >r begin
     a@ de>len 7 > if t@+ drop then
     a@ .de-word a@ de-sz + a!
     r@ 1+ r!
     a@ dict-end <
  while lpar r> . ." words)" atdrop ;
: words-n ( n-- ) last swap 1 >t for dup .de-word de-sz + next drop tdrop ;

( memory )
: fill ( addr num ch-- ) >t >r >a  r> for t@ !a+ next atdrop ;
: cmove ( src dst num-- ) >r >t >a
    r> ?dup if for @a+ !t+ next then
    atdrop ;
: cmove> ( src dst num-- ) >r  r@ + >t  r@ + >a
    r> ?dup if 1+ for @a- !t- next then
    atdrop ;

( strings )
: s-end  ( str--end )     dup s-len + ; inline
: s-cat  ( dst src--dst ) over s-end swap s-cpy drop ;
: s-catc ( dst ch--dst )  over s-end tuck c! 0 swap 1+ c! ;
: s-catn ( dst num--dst ) <# #s #> over s-end swap s-cpy drop ;
: s-eq   ( s1 s2--f )     >a >t
   begin
      @a @t+ = if0 a> t> = exit then
      a@+ c@ if0 atdrop 1 exit then
   again ;
: p  ( --a ) vhere $100 + ;
: p2 ( --a ) vhere $200 + ;

( screen )
: csi       ( -- )    27 emit '[' emit ;
: ->cr      ( c r-- ) csi (.) ';' emit (.) 'H' emit ;
: ->rc      ( r c-- ) swap ->cr ;
: cls       ( -- )    csi ." 2J" 1 dup ->cr ;
: clr-eol   ( -- )    csi ." 0K" ;
: cur-on    ( -- )    csi ." ?25h" ;
: cur-off   ( -- )    csi ." ?25l" ;
: cur-block ( -- )    csi ." 2 q" ;
: cur-bar   ( -- )    csi ." 5 q" ;

: color   ( bg fg-- ) csi (.) ';' emit (.) 'm' emit ;
: fg      ( fg-- )    40 swap color ;
: white   0 fg ;      : red    31 fg ;
: green  32 fg ;      : yellow 33 fg ;
: blue   34 fg ;      : purple 35 fg ;
: cyan   36 fg ;      : grey   37 fg ;
: colors 31 >a 7 for a@ fg ." color #" a@+ . cr next white adrop ;

( files )
: fopen-r ( nm--fh ) " rb" fopen ;
: fopen-w ( nm--fh ) " wb" fopen ;

( blocks )
cell var blk
: rows 25 ; inline
: cols 80 ; inline
: block-max  499 ; inline
rows cols * const block-sz
block-max 1+ block-sz * const disk-sz
vars vars-sz + disk-sz - const disk

( blocks )
: ->block   ( n--a )  block-max min block-sz * disk + ;
: blk-cp  ( f t-- ) swap ->block swap ->block block-sz cmove ;
: blk-clr ( blk-- ) ->block block-sz 0 fill ;
: blk-mv  ( f t-- ) over swap blk-cp blk-clr ;

: blk-fn ( blk--fn ) >t p " block-" s-cpy t> <# # # #s #> s-cat " .fth" s-cat ;
: blk-read ( blkNum buf bufSize--numRead ) >t >a  a@ t@ 0 fill
    blk-fn fopen-r ?dup if >r a@ t@ r@ fread  r> fclose else 0 then atdrop ;
: blk-write ( blkNum buf bufSize--numWritten ) >t >a
    blk-fn fopen-w ?dup if >r a@ t@ r@ fwrite r> fclose else 0 then atdrop ;
: blk-rm  ( blkNum-- ) exit blk-fn fdelete ;
: blk-cp2 ( from to--sz ) >t p2 25000 blk-read t> swap p2 swap blk-write ;
: blk-mv2 ( from to-- ) over swap blk-cp2 drop blk-rm ;
: blk-ins ( blkNum stop-- ) 1+ >t >a
   begin t@- t@ swap blk-mv2 t@ a@ > while tdrop a> blk-rm ;

: disk-read " disk.c5" fopen-r ?dup
   if >a disk disk-sz a@ fread  a> fclose then ;
: disk-flush " disk.c5" fopen-w ?dup
   if >a disk disk-sz a@ fwrite  a> fclose then ;
disk-read

( vkey )
#256  #75 or const key-left  ( vt100: 27 91 68 )
#256  #77 or const key-right ( vt100: 27 91 67 )
#256  #72 or const key-up    ( vt100: 27 91 65 )
#256  #80 or const key-down  ( vt100: 27 91 66 )
#256  #71 or const key-home  ( vt100: 27 91 72 )
#256  #79 or const key-end   ( vt100: 27 91 70 )
#256  #82 or const key-ins   ( vt100: 27 91 50 126 )
#256  #83 or const key-del   ( vt100: 27 91 51 126 )
#256  #73 or const key-pgup  ( vt100: 27 91 53 126 )
#256  #81 or const key-pgdn  ( vt100: 27 91 54 126 )
#256 #119 or const key-chome ( vt100: 27 91 ?? ??? )
#256 #117 or const key-cend  ( vt100: 27 91 ?? ??? )

: vt-key2 ( --k ) key 126 = if0 27 exit then
    a@ 50 = if key-ins   exit then
    a@ 51 = if key-del   exit then
    a@ 53 = if key-pgup  exit then
    a@ 54 = if key-pgdn  exit then   27 ;
: vt-key1 ( --k ) key a!
    a@ 68 = if key-left  exit then
    a@ 67 = if key-right exit then
    a@ 65 = if key-up    exit then
    a@ 66 = if key-down  exit then
    a@ 72 = if key-home  exit then
    a@ 70 = if key-end   exit then
    a@ 49 > a@ 55 < and if vt-key2 exit then   27 ;
: vt-key ( --k )  key 91 = if vt-key1 exit then 27 ;
: win-key ( --k ) key #256 or ;
: vkey ( --k ) key dup 224 = if drop win-key exit then
   dup 27 = if >a vt-key adrop exit then ;

( accept )
: printable? ( c--f ) dup 31 > swap 127 < and ;
: bs 8 emit ; inline
: accept ( dst-- ) dup >r >t 0 >a
  begin key a!
      a@   3 =  a@ 27 = or if 0 r> c! atdrop exit then
      a@  13 = if 0 !t atdrop rdrop exit then
      a@   8 = if 127 a! then ( Windows: 8=backspace )
      a@ 127 = if r@ t@ < if t- bs space bs then then
      a@ printable? if a@ dup !t+ emit then
  again ;

( a simple block editor )
block-sz var ed-block
: block->ed ( -- ) blk @ ->block ed-block block-sz cmove ;
: ed->block ( -- ) ed-block blk @ ->block block-sz cmove ;
: last-ch ( --a ) ed-block block-sz + 1- ;
cell var (r)  : row! (r) ! ;  : row@ (r) @ ;
cell var (c)  : col! (c) ! ;  : col@ (c) @ ;
: norm-pos ( pos--new ) ed-block max last-ch min ;
: cr->pos ( col row--pos ) cols * + ed-block + ;
: rc->pos ( --pos ) col@ row@ cr->pos ;
: pos->rc ( pos-- ) norm-pos ed-block - cols /mod row! col! ;
: mv ( r c-- )  (c) +! (r) +! rc->pos  pos->rc ;
1 var (mode)             : mode@   (mode)  c@ ;
1 var (show)             : show?   (show)  c@ ;
1 var (dirty)            : dirty?  (dirty) c@ ;
: mode! (mode) c! ;      : clean 0 (dirty) c! ;
: show!  1 (show)  c! ;  : shown 0 (show)  c! ;
: dirty! 1 (dirty) c! show! ;
: ->norm  0 mode! ;
: ->repl  1 mode! ;  : repl? mode@ 1 = ;
: ->ins   2 mode! ;  : ins?  mode@ 2 = ;
: quit?  mode@ 99 = ;
: .b1  green cols 2+ for '-' emit next white cr ;
: .b2  green '|' emit white ;
: aemit ( b-- ) dup $20 < over $7e > or if drop '.' then emit ;
: .scr 1 dup ->rc .b1 ed-block >a rows for 
      .b2  cols for @a+ aemit next  .b2 cr
   next .b1 adrop ;
: ->cur  col@ 2+ row@ 2+ ->cr ;
: ->foot 1 rows 3 + ->cr ;
: ->cmd ->foot cr ;
: .foot ->foot ." Block #" blk @ .
   bl dirty? if drop '*' then emit space
   lpar row@ 1+ (.) ',' emit col@ 1+ (.) rpar
   repl? if yellow ."  -replace-" white then
   ins?  if purple ."  -insert-"  white then
   space rc->pos c@ lpar '#' emit (.) rpar clr-eol ;
: show show? if cur-off .scr cur-on shown then .foot ->cur ;
: mv-left 0 dup 1-      mv ;   : mv-right 0 1 mv ;
: mv-up   0 dup 1- swap mv ;   : mv-down  1 0 mv ;
: ins-bl  dirty!  last-ch >a  rc->pos >t
   begin a@ 1- c@ !a- a@ t@ > while bl a> c! tdrop ;
: replace-char ( -- ) a@ printable? if a@ rc->pos c! mv-right dirty! then ;
: insert-char  ( -- ) a@ printable? if ins-bl replace-char then ;
: repl-one red '?' emit bs white key >a replace-char show! ;
: del-ch  dirty!  last-ch >a  rc->pos >t
   begin t@ 1+ c@ !t+ t@ a@ < while 0 t> c! adrop ;
: clr-line 0 row@ cr->pos >a cols for 32 !a+ next adrop dirty! ;
: ins-line  row@ rows < if 
      last-ch >a  a@ cols - >t  0 row@ cr->pos >r
      begin @t- !a- t@ r@ < until
      atdrop rdrop
   then clr-line ;
cols 1+ var yanked
: yank-line yanked >a 0 row@ cr->pos >t cols for @t+ !a+ next atdrop ;
: put-line  yanked >a 0 row@ cr->pos >t cols for @a+ !t+ next atdrop dirty! ;
: del-line  yank-line row@ rows < if
      0 row@ cr->pos >t  t@ cols + >a  last-ch >r
      begin @a+ !t+  a@ r@ > until
      atdrop rdrop
   then row@  rows 1- row!  clr-line  row! ;
: next-pg ed->block  blk @ 1+       blk ! block->ed show! clean ;
: prev-pg ed->block  blk @ 1- 0 max blk ! block->ed show! clean ;
: ed-cmd ->cmd ':' emit clr-eol p accept ->cmd clr-eol
   p " q"  s-eq if 99 mode! then
   p " q!" s-eq if 99 mode! then
   p " wq" s-eq if 99 mode! then
   p c@ '!' = if p 1+ outer then
   p " w"  s-eq if clean then ;

: case  ( ch-- ) v, find drop v, ;  ( case-table entry - single word )
: case! ( ch-- ) v, here v, 1 state ! ;  ( case-table entry - code )

( VI-like commands )
vhere const ed-ctrl-cases
key-left  case  mv-left
key-right case  mv-right
key-up    case  mv-up
key-down  case  mv-down
key-home  case! 0 col! ;
key-end   case! cols 1- col! ;
key-ins   case  ->ins
key-del   case  del-ch
key-pgup  case  prev-pg
key-pgdn  case  next-pg
key-chome case! 0 dup col! row! ;
key-cend  case! 0 col! rows 1- row! ;
13        case! mv-down 0 col! ;
27        case  ->norm
 3        case! 99 mode! ;
0 v, 0 v, ( end )

vhere const ed-cases
'h'  case  mv-left           'j'  case  mv-down  
'k'  case  mv-up             'l'  case  mv-right
32   case  mv-right          'b'  case  ins-bl
'x'  case  del-ch            'C'  case  clr-line
'R'  case  ->repl            'i'  case  ->ins
'O'  case  ins-line          'o'  case! mv-down ins-line ;
'D'  case  del-line
'+'  case  next-pg           '-'  case  prev-pg
'r'  case  repl-one          'Y'  case  yank-line
'p'  case! mv-down ins-line put-line ;
'P'  case! ins-line put-line ;
'X'  case! mv-left del-ch ;
':'  case  ed-cmd
'_'  case! 0 col! ;
0 v, 0 v, ( end )

( switch: case-table process )
: switch ( tbl-- )
   >t begin
      t@ @ if0 tdrop exit then
      t@ dup cell+ t! @ a@ = if  t> @ >r exit then
      t@ cell+ t!
   again tdrop ;

: process-key ( -- )
   a@ 32 < a@ 126 > or if ed-ctrl-cases switch exit then
   ins?  if insert-char exit then
   repl? if replace-char exit then
   ed-cases switch ;
: ed-loop begin show vkey >a process-key adrop quit? until ;
: ed-init block->ed 0 mode! show! 0 dup row! col! cls ;
: ed  ed-init ed-loop ed->block ->cmd ;
: edit  blk ! ed ;

: reboot
   -vha- (vha) !  -la- (la) !  -ha- (ha) !
   " boot.fth" " rb" fopen ?dup if >a
      vars 10000 + >t 
      t@ 25000 0 fill 
      t@ 25000 a@ fread drop a> fclose
      t> >in !
   then ;

( this dump is from Peter Jakacki )
: .ascii ( -- ) a@ $10 - $10 for dup c@ aemit 1+ next drop ;
: dump ( f n-- ) swap >a 0 >t
   for
      t@ if0 cr a@ .hex ." : " then
      @a+ .hex
      t@+ $0f = if ."    " .ascii 0 t! then
   next atdrop ;

( fg-1: forget-one )
: fg-1 last dup de>xt (ha) ! de-sz + (la) ! ;

( marker / forget )
cell var fg-h
cell var fg-l
cell var fg-v
: marker here fg-h ! last fg-l ! vhere fg-v ! ;
: forget fg-h @ (ha) ! fg-l @ (la) ! fg-v @ (vha) ! ;

: t0 '.' hold ;
: .ver  green ." c5 v" version <# # # t0 # # t0 #s #> ztype white cr ;
.ver ." hello"

marker

( temp for testing )
vhere const wd 32 allot

: skip-ws ( p1--p2 ) 
   begin
      dup c@ ?dup if0 exit then
      32 > if exit then 1+ 
   again ;
: next-wd ( p1 wd--p2 ) >t skip-ws >a
   begin
      @a 33 < if 0 !t a@ atdrop exit then
      @a+ !t+
   again ;

: boot->disk vars 10000 + disk 25000 cmove ;
: mil 1000 dup * * ;
: elapsed timer swap - . ." usec" ;
: bm timer swap for next elapsed ;
: fib 1- dup 2 < if drop 1 exit then dup fib swap 1- fib + ;
: fib-bm timer swap fib . elapsed ;
: lg " lazygit" system ;
: ls " ls -l" system ;
: pwd " pwd" system ;
boot->disk
