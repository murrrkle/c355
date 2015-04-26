! CPSC 355 ASSIGNMENT 2A: Bitwise Logical and Shift Operations
! ============================================================
! Completed on 10-10-2013 by HUNG, Michael (UCID: 10099049)
!

        
output:         .asciz  "v[%d]: %d\n"                                  ! Output string
                .align  4

.global main
        main:   save    %sp,        (-92 + -160) & -8,        %sp

                clr     %l0                                             ! counter
                clr     %l1                                             ! counter for inner loop
                clr     %l2                                             ! tmp: temporary storage
                clr     %l5                                             ! inner loop index

                mov     -160,            %l3                            ! Changing offset
                mov     1,               %l4                            ! index calculation for outer loop

        forA:   call    random                                          ! Calling random function; storing random integer into %o0
                nop

                and     %o0,            0xFF,               %o2         ! mod 256; putting value in output register

                st      %o2,            [ %fp + %l3 ]                   ! storing random integer mod 256 into A[i]

                add     %l3,            4,                  %l3         ! preparing offset for next iteration

                set     output,         %o0                             ! Prepare output string
                mov     %l0,            %o1                             ! Prepare index for output
                call    printf                                          ! Print output string
                nop

                cmp     %l0,            39                              ! Loop for 40 iterations
                bl,a    forA                                            ! Begin sorting once array has been initialized
                inc     %l0

        outer:  smul    %l0,            -4,                 %l3         ! Find array element in memory
                ld      [ %fp + %l3 ],  %l2                             ! storing element into temporary storage

                mov     %l4,            %l1                             ! Preparing counter for inner loop


        inner:  cmp     %l1,            0
                ble     skip
                nop

                sub     %l3,            4,                  %l5         ! finding what is stored at index (j - 1)
                ld      [ %fp + %l5 ],  %l6                             ! store in memory

                cmp     %l2,            %l6
                ble     skip
                nop

                st      %l6,            [ %fp + %l5 ]

                sub     %l1,            1,                  %l1

                ba      inner

        skip:   add     %l5,            4,                  %l5
                st      %l2,            [ %fp + %l5 ]

                sub     %l0,            1,                  %l0
                inc     %l4

                cmp     %l0,            0
                bg      outer
                nop

                clr     %o1
                mov     -160,           %l3

        print:  set     output,         %o0
                ld      [ %fp + %l3 ],  %o2
                call    printf
                nop

                inc     %o1
                add     %l3,            4,                  %l3

                cmp     %o1,            40
                bl      print
                nop


        mov     1,      %g1
        ta      0
