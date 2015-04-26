! CPSC 355 ASSIGNMENT 6: File I/O and Floating-Point Numbers
! ===========================================================
! Completed on 05-12-2013 by HUNG, Michael (UCID: 10099049)
!
! 
!

include(macro_defs.m)                                                       ! Include macro definitions.

definitions:    define(READ, 3)
                define(OPEN, 5)
                define(CLOSE, 6)
                define(BUFFERSIZE, 8)
                define(term_fr,  %f2)
                define(limit_fr, %f4)
                define(sum_fr, %f6)

.section        ".data"
                .align  8

precisionBound:	.double 0r1.0e-10
floatingZero:	.double	0r0.0
floatingOne:    .double	0r1.0


badArgument:    .asciz  "Please provide exactly ONE filename on the command line.\n"
                .align  4

ePositiveX:     .asciz  "\nx\t\t\te^x\n"
                .align  4

eNegativeX:     .asciz  "\n\t\t\te^-x\n"
                .align  4

output:         .asciz  "\n%.10f\t%.10f\t\n"
                .align  4


EOFreached:     .asciz  "E.O.F."
                .align  4

.section        ".text"
                .align  4

local_var
var(product,	4)
var(buffer, BUFFERSIZE, 1)
var(fill,	8)


begin_fn(exp)                                                           ! Definition for exponentiation function
                fmovs	%f12,               %f10                        ! Setting up floating point registers to hold values
                fmovs	%f13,               %f11

expCompute:     cmp		%i0,                1                           ! Test for whether last multiplication has been reached
                ble		expComputeDone                                  ! If so, skip decrement and mult
                nop

                sub		%i0,                1,              %i0         ! i0 contains the x to be raised. Use as counter for number of mults

                fmuld	%f12,               %f10,           %f12        ! Multiply

                ba		expCompute                                      ! Continue the loop
                nop

expComputeDone:                                                         ! Finished, End the function and return
end_fn(exp)

begin_fn(factorial)                                                     ! Definition for factorial function
                mov     1,                  %o0                         ! Setting up registers
                mov     1,                  %o1                         ! Current product of factorial

factCompute:    smul	%o0,                %o1,            %o1         ! Multiply
                inc		%o0                                             ! Increase for next mult

                cmp		%o0,                %i0                         ! i0 contains upper bound of factorial computation
                ble		factCompute                                     ! Continue the loop
                nop

                st		%o1,                [%fp + product]             ! Store the factorial product in memory
                ld		[%fp + product],    %f14                        ! Store the factorial product to floating point register
                fitod	%f14,               %f14                        ! Convert factorial product to double
end_fn(factorial)

begin_fn(printePositiveX)                                               ! Prints products for e^x
                set     output,             %o0                         ! Setting output string
                std     %f0,                [%fp + fill]                ! f0 is the input from file
                ld      [%fp + fill],       %o1                         ! First half of original double
                ld      [%fp + fill + 4],	%o2                         ! Second half of original double

                std     sum_fr,             [%fp + fill]                ! Replacing, in memory, the original double with the computed sum
                ld      [%fp + fill],       %o3                         ! First half of sum
                ld      [%fp + fill + 4],	%o4                         ! second halg of sum

                call    printf                                          ! Print!
                nop
end_fn(printePositiveX)

begin_fn(printeNegativeX)                                               ! Same as above but for e^-x
                set     output,             %o0
                std     %f20,               [%fp + fill]
                ld      [%fp + fill],       %o1
                ld      [%fp + fill + 4],	%o2

                std     sum_fr,             [%fp + fill]
                ld      [%fp + fill],       %o3
                ld      [%fp + fill + 4],	%o4

                call    printf
                nop
end_fn(printeNegativeX)

begin_main()                                                            ! Main yay
                cmp     %i0,                2                           ! Must be exactly 2 arguments
                be      valid                                           ! Skip error and exit if valid
                nop

                set     badArgument,        %o0                         ! Error! Print error message and exit
                call    printf
                nop

                call    exit
                nop

valid:          set     ePositiveX,         %o0                         ! Print heading
                call    printf
                nop

                ld      [%i1 + 4],          %o0                         ! Load and open file

                clr     %o1
                clr     %o2
                mov     OPEN,               %g1
                ta      0

                mov     %o0,                %l0                         ! If improperly opened, exit immediately. Else, continue to opening.
                bcc     opening
                nop

                mov     1,                  %g1
                ta      0

opening:        mov     %l0,                %o0                         ! Opening the file
                add     %fp,                buffer,         %o1         ! Get address of buffer
                mov     BUFFERSIZE,         %o2
                mov     READ,               %g1                         ! Tell system to read

                ta      0                                               ! System trap

                addcc	%o0,                0,              %l1
                bg      reading                                         ! File opened, read
                nop

                ba      finished                                        ! File opening failed, abort
                nop

reading:        set     precisionBound,     %o0                         ! Specify the precisionBound (10e-10)
                ldd     [%o0],              limit_fr                    ! Load it and put it into floating point register

                set     floatingZero,       %o0                         ! Provide floating point implementation of 0
                ldd     [%o0],              sum_fr                      ! Set it as current sum before beginning computation

                ldd     [%fp + buffer],     %f0                         ! Begin reading

                mov		1,                  %l2                         ! First exponent to be raised is 1

sumCompute:     set		floatingZero,       %o0                         ! Initialize %o0 to hold the value of the current term. %l2 will determine which term
                ldd		[%o0],              term_fr                     ! Load it to floating point register

                fmovs	%f0,                %f10                        ! temporary fp registers for computing term value
                fmovs	%f1,                %f11

                mov		%l2,                %o0                         ! Compute exponent
                call 	exp
                nop

                mov		%l2,                %o0                         ! Compute factorial
                call	factorial
                nop

                fdivd	%f10,               %f14,           term_fr     ! Divide to get value of term, put it in there

                faddd	term_fr,            sum_fr,         sum_fr      ! Add the term value into the register holding current sum

                inc		%l2                                             ! Incrememt to compute next term

                fcmpd	term_fr,            limit_fr                    ! Keep looping until precision bound is reached
                nop

                fbl		done                                            ! If it is reached, branch to done
                nop

                ba		sumCompute                                      ! If not, loop
                nop

done:           set		floatingOne,        %o0                         ! These lines add the remaining 1 into the sum in order to account for the 0th term
                ldd		[%o0],              %f8

                faddd	%f8,                sum_fr,         sum_fr

                call    printePositiveX
                nop

validN:         set     eNegativeX,         %o0                         ! Print heading
                call    printf
                nop

                ld      [%i1 + 4],          %o0                         ! Load and open file

                clr     %o1
                clr     %o2
                mov     OPEN,               %g1
                ta      0

                mov     %o0,                %l0                         ! If improperly opened, exit immediately. Else, continue to opening.
                bcc     openingN
                nop

                mov     1,                  %g1
                ta      0

sumComputeN:    set		floatingZero,       %o0                         ! Initialize %o0 to hold the value of the current term. %l2 will determine which term
                ldd		[%o0],              term_fr                     ! Load it to floating point register

                fmovs	%f0,                %f10                        ! temporary fp registers for computing term value
                fmovs	%f1,                %f11

                mov		%l2,                %o0                         ! Compute exponent
                call 	exp
                nop

                mov		%l2,                %o0                         ! Compute factorial
                call	factorial
                nop

                fdivd	%f10,               %f14,           term_fr     ! Divide to get value of term, put it in there

                faddd	term_fr,            sum_fr,         sum_fr      ! Add the term value into the register holding current sum

                inc		%l2                                             ! Incrememt to compute next term

                fcmpd	term_fr,            limit_fr                    ! Keep looping until precision bound is reached
                nop

                fbl		doneN                                           ! If it is reached, branch to done
                nop

                ba		sumComputeN                                     ! If not, loop
                nop
doneN:          set		floatingOne,        %o0                         ! These lines add the remaining 1 into the sum in order to account for the 0th term
                ldd		[%o0],              %f8

                faddd	%f8,                sum_fr,         sum_fr

                call    printeNegativeX
                nop

finished:       set     EOFreached,                %o0                  ! Finished! Print EOF message and exit.
                call    printf
                nop

end_main()
