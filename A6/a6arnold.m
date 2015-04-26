/*	CPSC 355 Fall 2013                                                                     =
 	Assignment 6 Submitted by Arnold Padillo 10097013									   =	
	T02 w/ Rashmi Kumari																   =
==========================================================================================*/

importmacro:
	include(macro_defs.m)				! Imports universal Macros

trapdefs:											! Trap definitions
	define(OPEN, 5)							! These will be manipulated with %g1
	define(READ, 3)							! Used constants are convention.
	define(CLOSE, 6)						! Will be used to Close the imported file.
	define(BUFSIZ, 8)						! Characters read at a time.
	define(fd_r, %l0)						! File descriptor in register %l0
	define(n_r,	%l1)						! Characters read checking in register %l1
	define(expval_r, %l2)                   ! Value of Exponent
	define(termval_fr, %f4)                 ! Value of term
	define(limit_fr, %f6)                   ! Limit of term
	define(termsum_fr,	%f8)                ! Sum of Terms (excluding + 1)
	
	
.section ".data"							! Writing in .data section
.align	8									! Alignment

limit:	.double 0r1.0e-10                   ! Limit used for sum calculation
zero:	.double	0r0.0						! Initializes a double 0.0
one:	.double	0r1.0						! Initializes a double 1.0



/* ===============================  Print Labels ======================================== */

error:
	.asciz "Provide ONE (1) filename to process with.\n"						! Prints in the case of invalid 
	.align	4

heading1:
	.asciz "\n	Input (x) \t	Output (e to the power of x) \t\n"
	.align	4
	
heading2:
	.asciz "	%.10f\t	%.10f\t\n"
	.align	4
	
heading3:
	.asciz "\n	Input (-x) \t	Output (e to the power of -x) \t\n"
	.align	4
		
EOF:
	.asciz "\n			End of data reached.\n"
	.align	4
		
/* ====================================================================================== */	
	
.section ".text"
.align	4

begin_fn(exponentiate)
	fmovs	%f30,	%f28
	fmovs	%f31,	%f29
	
expLoop:
	cmp		%i0,	1
	ble		endExp
	nop
	
	fmuld	%f30,	%f28,	%f30
	sub		%i0,	1,		%i0
	ba		expLoop
	nop

endExp:
end_fn(exponentiate)


local_var
var(result,	4)

begin_fn(factorial)

mov	1,	%o0
mov	1,	%o1

factLoop:
	smul	%o0,	%o1,	%o1
	inc		%o0
	cmp		%o0,	%i0
	ble		factLoop
	nop
	
	st		%o1,	[%fp + result]
	ld		[%fp + result],	%f10
	fitod	%f10,	%f10
	
end_fn(factorial)

begin_fn(printFirst)
	set	heading2,		%o0
	std	%f0,	[%fp + temp]
	ld	[%fp + temp],	%o1
	ld	[%fp + temp + 4],	%o2
	
	std	termsum_fr,	[%fp + temp]
	ld	[%fp + temp],	%o3
	ld	[%fp + temp + 4],	%o4
	
	call printf
	nop
	
end_fn(printFirst)

begin_fn(printSecond)
	set	heading2,		%o0
	std	%f22,	[%fp + temp]
	ld	[%fp + temp],	%o1
	ld	[%fp + temp + 4],	%o2
	
	std	termsum_fr,	[%fp + temp]
	ld	[%fp + temp],	%o3
	ld	[%fp + temp + 4],	%o4
	
	call printf
	nop
end_fn(printSecond)
	
local_var
	var(buf, BUFSIZ, 1)				! Buffer will read 8 bytes at a time	
	var(temp,	8)

begin_fn(main)						! Start of main()
	cmp	%i0,	2						! Need 2 Arguments
	be	valid							! If valid number of arguments, go to "valid"
	nop										! Delay slot

	set error,	%o0
	call printf
	nop
	call exit
	nop
	
valid:
	set	heading1,	%o0
	call printf
	nop
	
	ld [%i1 + 4], %o0
	clr	%o1
	clr	%o2
	mov OPEN, %g1
	ta	0
	
	mov %o0, fd_r					! File descriptor saved in ff_r
	bcc open_ok						! If successfully opened, go to "opened" label
	nop
	mov	1,	%g1						! error, exit
	ta	0
	
	
read_ok:
	set	limit,	%o0
	ldd	[%o0],	limit_fr
	
	set	zero,	%o0
	ldd	[%o0],	termsum_fr

	ldd [%fp + buf],	%f0			! Reading x values

	mov		1,		expval_r
	
sumLoop:
	set		zero,	%o0
	ldd		[%o0],	termval_fr

	fmovs	%f0,	%f30
	fmovs	%f1,	%f31
	
	mov		expval_r,	%o0
	call 	exponentiate
	nop
	
	mov		expval_r,	%o0
	call	factorial	
	nop
	
	fdivd	%f30,	%f10,	termval_fr
	
	faddd	termval_fr,	termsum_fr,	termsum_fr
	
	inc		expval_r
	
	fcmpd	termval_fr,	limit_fr
	nop
	fbl		next
	nop
	
	ba		sumLoop
	nop
	
next:
	set		one,	%o0
	ldd		[%o0],	%f2
	
	faddd	%f2,	termsum_fr,	termsum_fr	! Adding 1 to the Expansion of the sum

	call printFirst
	nop
	

open_ok:
	mov	fd_r,	%o0
	add %fp,	buf,	%o1
	mov	BUFSIZ,	%o2
	mov	READ,	%g1
	ta	0
	addcc	%o0,	0,	n_r
	bg	read_ok
	nop
	
	
	
/* ================================ For e to the power of -x ============================ */
	
	
valid2:
	set	heading3,	%o0
	call	printf
	nop


	ld [%i1 + 4], %o0
	clr	%o1
	clr	%o2
	mov OPEN, %g1
	ta	0
	
	mov %o0, fd_r					! File descriptor saved in ff_r
	bcc open_ok2						! If successfully opened, go to "opened" label
	nop
	mov	1,	%g1						! error, exit
	ta	0
	
	read_ok2:
	set	limit,	%o0
	ldd	[%o0],	limit_fr
	
	set	zero,	%o0
	ldd	[%o0],	termsum_fr

	ldd [%fp + buf],	%f0			! Reading x values
	
	fnegs	%f0,	%f22			! Negate x values
	fmovs	%f1,	%f23			! Negate x values

	mov		1,		expval_r		! Increment Exponent value
	
sumLoop2:
	set		zero,	%o0
	ldd		[%o0],	termval_fr

	fmovs	%f22,	%f30
	fmovs	%f23,	%f31
	
	mov		expval_r,	%o0
	call 	exponentiate
	nop
	
	mov		expval_r,	%o0
	call	factorial	
	nop
	
	fdivd	%f30,	%f10,	termval_fr
	
	faddd	termval_fr,	termsum_fr,	termsum_fr
	
	
	inc		expval_r
	
	fcmpd	termval_fr,	limit_fr
	nop
	fbl		next2
	nop
	
	ba		sumLoop2
	nop
	
next2:
	set		one,	%o0
	ldd		[%o0],	%f2
	
	faddd	%f2,	termsum_fr,	termsum_fr	! Adding 1 to the Expansion of the sum

	call printSecond
	nop
	
open_ok2:
	mov	fd_r,	%o0
	add %fp,	buf,	%o1
	mov	BUFSIZ,	%o2
	mov	READ,	%g1
	ta	0
	addcc	%o0,	0,	n_r
	bg	read_ok2
	nop
	
	
end_of_file:
	set	EOF,	%o0
	call printf
	nop
	
end_fn(main)						! End of main()
	
