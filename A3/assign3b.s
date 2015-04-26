! CPSC 355 ASSIGNMENT 2A: Bitwise Logical and Shift Operations
! ============================================================
! Completed on 24-10-2013 by HUNG, Michael (UCID: 10099049)
!
! Implements the following array sorting algorithm.
!
! #define  SIZE 40
!
! int main()
! {
!   int v[SIZE];
!   int i, j, tmp;
!
!   /*  Initialize array to random positive integers, mod 256  */
!   for (i = 0; i < SIZE; i++) {
!     v[i] = rand() & 0xFF;
!     printf(“v[%-d]: %d\n”, i, v[i]);
!   }
!
!   /*  Sort the array using an insertion sort  */
!   for (i = 1; i < SIZE; i++) {
!     tmp = v[i];
!     for (j = i; j > 0 && tmp < v[j-1]; j--)
!       v[j] = v[j-1];
!     v[j] = tmp;
!   }
!
!   /*  Print out the sorted array  */
!   printf(“\nSorted array:\n”);
!   for (i = 0; i < SIZE; i++)
!     printf(“v[%-d]: %d\n”, i, v[i]);
! }


        
output:         .asciz  "v[%d]: %d\n"                                  ! Output string
                .align  4

.global main
        main:   save    %sp,        (-92 + -160) & -8,        %sp

                mov     40,             %i0                             ! SIZE = 40
                mov     40,             %l0                             ! Used to calculate offset by multiplying by 4. Subtract 1 each iteration; stop when equal to 0.
                clr     %l1                                             ! To be used to store offset

        init:   call    random                                          ! Calling random function; storing random integer into %o0
                nop
                
                smul    %l0,            -4,                 %l1         ! Calculate offset
                
                and     %o0,            0xFF,               %o2         ! mod 256; putting value in output register

                st      %o2,            [ %fp + %l1 ]                   ! Storing random integer mod 256 into A[i]

                set     output,         %o0                             ! Prepare output string
                sub     %i0,            %l0,                %o1         ! Prepare index for output
                call    printf                                          ! Print output string
                nop

                cmp     %l0,            1                               ! Loop for 40 iterations.
                bg,a    init                                            ! Begin sorting once array has been initialized
                sub     %l0,            1,                  %l0         ! Prepare for next iteration

        next:   mov     1,              %l0                             ! Used to store i
                clr     %l1                                             ! Used to store j
                clr     %l2                                             ! Used to store j - 1
                clr     %l3                                             ! Used to store v[i]
                clr     %l4                                             ! Used to store v[j - 1]
                clr     %l6                                             ! Used to store tmp
                clr     %l7                                             ! Used to find array element in memory by subtracting 40 then multiplying by 4; for i, j, and j-1
                
       outer:   sub     %l0,            %i0,                %l7         ! Calculating offset to find v[i]
                smul    %l7,            4,                  %l7         ! Calculating offset to find v[i]; done
                
                ld      [ %fp + %l7 ],  %l3                             ! Getting v[i]
                mov     %l3,            %l6                             ! tmp = v[i]
                
                mov     %l0,            %l1                             ! j = i
                
       inner:   cmp     %l1,            0                               ! Test: is j > 0?
                ble     skip                                            ! If not, skip the inner loop
                nop
                
                sub     %l1,            1,                  %l2         ! Calculating j - 1
                sub     %l2,            %i0,                %l7         ! Calculating offset to find v[j - 1]
                smul    %l7,            4,                  %l7         ! Calculating offset to find v[j - 1]; done
                
                ld      [ %fp + %l7 ],  %l4                             ! Getting v[j - 1]
                
                cmp     %l6,            %l4                             ! Test: is tmp < v[j - 1], i.e. is tmp - v[j-1] < 0?
                bge     skip                                            ! If not, skip the inner loop
                nop
                
                sub     %l1,            %i0,                %l7         ! Calculating offset to find v[j]
                smul    %l7,            4,                  %l7         ! Calculating offset to find v[j]; done
                
                st      %l4,            [ %fp + %l7 ]                   ! v[j] = v[j - 1]
                
                sub     %l1,            1,                  %l1         ! Updating j for next iteration
                
                ba      inner                                           ! Loop until one of the tests are failed. Assertion: Because of the bound function of the loop, one of the tests will eventually fail, always.
                nop
                
        skip:   st      %l6,            [ %fp + %l7 ]                   ! %l7 still stores offset for j. v[j] = tmp
        
                inc     %l0                                             ! Increment counter i for for loop
                
                cmp     %l0,            %i0                             ! Is i < SIZE, i.e. is i - SIZE < 0? 
                ble     outer                                           ! If so, reiterate through loops. 
                nop
                
                mov     40,             %l0                             ! Used to calculate offset by multiplying by 4. Subtract 1 each iteration; stop when equal to 0.
                clr     %l1                                             ! To be used to store offset

       print:   smul    %l0,            -4,                 %l1         ! Calculate offset
                ld      [ %fp + %l1 ],  %o2                             ! Storing v[i] to output register

                set     output,         %o0                             ! Prepare output string
                sub     %i0,            %l0,                %o1         ! Prepare index for output
                call    printf                                          ! Print output string
                nop

                cmp     %l0,            1                               ! Loop for 40 iterations.
                bg,a    print                                           ! Begin sorting once array has been initialized
                sub     %l0,            1,                  %l0         ! Prepare for next iteration

        done:   mov     1,      %g1
                ta      0
