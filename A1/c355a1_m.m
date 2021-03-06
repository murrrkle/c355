! CPSC 355 ASSIGNMENT 1: Basic Assembly Language Programming
! ==========================================================
! Completed on 09-25-2013 by HUNG, Michael (UCID: 10099049)
!                 
! This program computes the expression:

!       y = 2x^3 − 19x^2 + 9x + 45  for  -2 <= x <= 10

! It will then store the minimum y within that domain of x
! and print a corresponding message.
!
! As opposed to c355a1.s, this version implements macros
! and has been optimized by filling the nop delay slots.

define(min_r, l0)       ! min:      minimum
define(x_r, l1)         ! x:        current x value
define(t1_r, l2)        ! t1 - t3:  algebraic terms
define(t2_r, l3)
define(t3_r, l4)
define(y_r, l5)         ! y:        computed y value

define(mul1_r, o0)      ! mul1:     first argument for .mul
define(outst_r, o0)     ! outst:    first argument for string output
define(mul2_r, o1)      ! mul2:     second argument for .mul
define(outx_r, o1)      ! outx:     second argument for string output
define(outy_r, o2)      ! outy:     third argument for string output
define(outmin_r, o3)    ! outmin:   fourth argument for string output

define(a3, 2)           ! a0 - a3:  arithmetic constants for computational purposes
define(a2, 19)
define(a1, 9)
define(a0, 45)

define(xmax, 10)        ! xmax:     upper bound for domain


.global main
        main:   save    %sp,    -96,        %sp
                
                mov     -2,     %x_r                            ! Domain of function is -2 <= x <= 10. Loop iterates through each of the 13 integer values.
                clr     %min_r                                  ! Initialize the register for holding the minimum y.
                
                loop:   mov     %x_r,       %mul1_r             ! x in %o0
                        call    .mul                            ! x * x = x^2; result of x^2 in %o0
                        mov     %x_r,       %mul2_r             ! x in %o1; filled delay slot
                        
                        mov     %mul1_r,    %mul2_r             ! x^2 in %o1
                        call    .mul                            ! x * x^2 = x^3; result of x^3 in %o0
                        mov     %x_r,       %mul1_r             ! x in %o0; filled delay slot
                        
                        mov     %mul1_r,    %mul2_r             ! x^3 in o1
                        call    .mul                            ! 2 * x^3; result of 2x^3 in %o0
                        mov     a3,         %mul1_r             ! 2 in %o0; filled delay slot
                        
                        mov     %mul1_r,    %t1_r               ! Stored 2x^3 in %l2. First term stored.
                        
                        mov     %x_r,       %mul1_r             ! x in %o0
                        call    .mul                            ! x * x = x^2; result of x^2 in %o0
                        mov     %x_r,       %mul2_r             ! x in %o1; filled delay slot
                        
                        mov     %mul1_r,    %mul2_r             ! x^2 in %o1
                        call    .mul                            ! 19 * x^2; 19x^2 in %o0
                        mov     a2,         %mul1_r             ! 19 in %o0; filled delay slot
                        
                        mov     %mul1_r,    %t2_r               ! Stored 19x^2 in %l3. Second term stored.
                
                        mov     %x_r,       %mul1_r             ! x in %o0
                        call    .mul                            ! x * 9 = 9x; result of 9x in %o0
                        mov     a1,         %mul2_r             ! 9 in %o1; filled delay slot
                        
                        mov     %mul1_r,    %t3_r               ! Stored 9x to %t3_r
                        add     %t3_r,      a0,         %t3_r   ! Compute 9x + 45 and store result in %l4_r. Third and Fourth terms stored.
                
                        sub     %t1_r,      %t2_r,      %y_r    ! Compute 2x^3 - 19x^2 and store result in %l5
                        add     %t3_r,      %y_r,       %y_r    ! Compute 2x^3 - 19x^2 + 9x + 45 and store result in %l5. Computation for y-value is complete.
                
                        cmp     %min_r,     %y_r                ! Compare the newly computed y-value to the current minimum
                        bge,a   setMin                          ! If cmp returns a value greater than 0, then the new y-value is smaller than the old minimum. Go to setMin branch, store it as the new minimum, and print a message
                        mov     %y_r,       %min_r              ! Set the new minimum; filled delay slot

                        set     output,     %outst_r            ! Store output string to %o0 as first argument for printf
                        mov     %x_r,       %outx_r             ! Store current x-value as second argument for printf
                        mov     %y_r,       %outy_r             ! Store newly computed y-value as third argument for printf

                
                        call    printf                          ! Print the output message.
                        mov     %min_r,     %outmin_r           ! Store current minimum as fourth argument for printf; filled delay slot
                                
                        cmp     %x_r,       xmax                ! Are we still within the domain?
                        bl,a    loop                            ! If so, execute the loop branch again.
                        inc     %x_r                            ! Update the domain; filled delay slot
                                        
                        ba      done                            ! We are outside the domain, now. Skip setMin and end the program at the done branch.

                setMin: set     output,     %outst_r            ! Store output string to %o0 as first argument for printf
                        mov     %x_r,       %outx_r             ! Store current x-value as second argument for printf
                        mov     %y_r,       %outy_r             ! Store newly computed y-value as third argument for printf
                        
                        call    printf                          ! Print the output message.
                        mov     %min_r,     %outmin_r           ! Store current minimum as fourth argument for printf; filled delay slot
                                
                        cmp     %x_r,       xmax                ! Are we still within the domain?
                        bl,a    loop                            ! If so, execute the loop branch again.
                        inc     %x_r                            ! Update the domain; filled delay slot           
       
                output: .asciz "When x = %d, y = %d. The minimum = %d\n"    ! Output string for printing appropriate message.
                        .align 4
     
                done:   mov     1,          %g1                 ! End the program.
                        ta      0
