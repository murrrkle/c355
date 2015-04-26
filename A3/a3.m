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

include(macro_defs.m)

! Output

define(outst_r,     o0)
define(out1_r,      o1)
define(out2_r,      o2)

! Storing array
define(SIZE_r,      i0)
define(ftmini_r,    l0)
define(offset1_r,   l1)

! Sorting array

define(i_r,         l0)
define(j_r,         l1)
define(jmin1_r,     l2)
define(vi_r,        l3)
define(vj_r,        l4)
define(tmp_r,       l6)
define(offset2_r,   l7)

define(offset3_r,   l1)

output:         .asciz  "v[%d]: %d\n"                                  ! Output string
                .align  4

.global main
        main:   save    %sp,            (-92 + -160) & -8,        %sp

                mov     40,             %SIZE_r                         ! SIZE = 40
                mov     40,             %ftmini_r                       ! Used to calculate offset by multiplying by 4. Subtract 1 each iteration; stop when equal to 0.
                clr     %offset1_r                                      ! To be used to store offset

        init:   call    random                                          ! Calling random function; storing random integer into %o0
                nop
                
                smul    %ftmini_r,      -4,                 %offset1_r  ! Calculate offset
                
                and     %o0,            0xFF,               %out2_r     ! mod 256; putting value in output register

                st      %out2_r,        [ %fp + %offset1_r ]            ! Storing random integer mod 256 into A[i]

                set     output,         %outst_r                        ! Prepare output string

                call    printf                                          ! Print output string
                sub     %SIZE_r,        %ftmini_r,          %out1_r     ! Prepare index for output; filled delay slot

                cmp     %ftmini_r,      1                               ! Loop for 40 iterations.
                bg,a    init                                            ! Begin sorting once array has been initialized
                sub     %ftmini_r,      1,                  %ftmini_r   ! Prepare for next iteration

        next:   mov     1,              %i_r                            ! Used to store i
                clr     %j_r                                            ! Used to store j
                clr     %jmin1_r                                        ! Used to store j - 1
                clr     %vi_r                                           ! Used to store v[i]
                clr     %vj_r                                           ! Used to store v[j - 1]
                clr     %tmp_r                                          ! Used to store tmp
                clr     %offset2_r                                      ! Used to find array element in memory by subtracting 40 then multiplying by 4; for i, j, and j-1
                
       outer:   sub     %i_r,           %SIZE_r,            %offset2_r  ! Calculating offset to find v[i]
                smul    %offset2_r,     4,                  %offset2_r  ! Calculating offset to find v[i]; done
                
                ld      [ %fp + %offset2_r ],               %vi_r       ! Getting v[i]
                mov     %vi_r,          %tmp_r                          ! tmp = v[i]
                
                mov     %i_r,           %j_r                            ! j = i
                
       inner:   cmp     %j_r,           0                               ! Test: is j > 0?
                ble     skip                                            ! If not, skip the inner loop
                nop
                
                sub     %j_r,           1,                  %jmin1_r    ! Calculating j - 1
                sub     %jmin1_r,       %SIZE_r,            %offset2_r  ! Calculating offset to find v[j - 1]
                smul    %offset2_r,     4,                  %offset2_r  ! Calculating offset to find v[j - 1]; done
                
                ld      [ %fp + %offset2_r ],               %vj_r       ! Getting v[j - 1]
                
                cmp     %tmp_r,         %vj_r                           ! Test: is tmp < v[j - 1], i.e. is tmp - v[j-1] < 0?
                bge     skip                                            ! If not, skip the inner loop
                nop
                
                sub     %j_r,           %SIZE_r,            %offset2_r  ! Calculating offset to find v[j]
                smul    %offset2_r,     4,                  %offset2_r  ! Calculating offset to find v[j]; done
                
                st      %vj_r,          [ %fp + %offset2_r ]            ! v[j] = v[j - 1]
                

                
                ba      inner                                           ! Loop until one of the tests are failed. Assertion: Because of the bound function of the loop, one of the tests will eventually fail, always.
                sub     %j_r,           1,                  %j_r        ! Updating j for next iteration; filled delay slot
                
        skip:   add     %j_r,           1,                  %offset2_r
                sub     %j_r,           %SIZE_r,            %offset2_r  ! Calculating offset to find v[j]
                smul    %offset2_r,     4,                  %offset2_r  ! Calculating offset to find v[j]; done

                st      %tmp_r,         [ %fp + %offset2_r ]            ! %offset2_r still stores offset for j. v[j] = tmp
        
                inc     %i_r                                            ! Increment counter i for for loop
                
                cmp     %i_r,           %SIZE_r                         ! Is i < SIZE, i.e. is i - SIZE < 0? 
                ble     outer                                           ! If so, reiterate through loops. 
                nop
                
                mov     40,             %i_r                            ! Used to calculate offset by multiplying by 4. Subtract 1 each iteration; stop when equal to 0.
                clr     %offset3_r                                      ! To be used to store offset

       print:   smul    %i_r,           -4,                 %offset3_r  ! Calculate offset
                ld      [ %fp + %offset3_r ],               %out2_r     ! Storing v[i] to output register

                set     output,         %outst_r                        ! Prepare output string

                call    printf                                          ! Print output string
                sub     %SIZE_r,        %i_r,               %out1_r     ! Prepare index for output; filled delay slot

                cmp     %i_r,           1                               ! Loop for 40 iterations.
                bg,a    print                                           ! Begin sorting once array has been initialized
                sub     %i_r,           1,                  %i_r        ! Prepare for next iteration

        done:   mov     1,      %g1
                ta      0
