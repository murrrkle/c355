! CPSC 355 ASSIGNMENT 5B: External Pointer Arrays and Command-Line Arguments
! =========================================================================
! Completed on 21-11-2013 by HUNG, Michael (UCID: 10099049)
!
! Implements the specified C Code from Assignment 5 Part B. This program takes
! exactly three integer arguments and outputs the corresponding date in the 
! format "Month DaySuffix, Year." Leap years are not accounted for, but simple
! bounds on the correct number of days for each month have been placed. Only
! years from 0, up to and including year 9999, are valid. All inputs are 
! assumed to be a String representation of an integer, provided on the
! command line, and no exception handling is in place for inputs of 
! String representations of other data types.

include(macro_defs.m)                                           ! Inclusion of macro definitions for m4.

date:           .asciz  "%s %s%s, %s\n"                         ! Output for valid input. MM DD YYYY format .
                .align  4                                       ! Memory alignment.

badArguments:   .asciz  "Usage: mm dd yyyy\n"                   ! Output for wrong number of arguments.
                .align  4                                       ! Memory alignment.

badMonth:       .asciz  "Provided month is out of bounds.\n"    ! Output for invalid month argument.
                .align  4                                       ! Memory alignment.

badDay:         .asciz  "Provided day is out of bounds.\n"      ! Output for invalid day argument.
                .align  4                                       ! Memory alignment.

badYear:        .asciz  "Provided year is out of bounds.\n"     ! Output for invalid year argument.
                .align  4                                       ! Memory alignment.

.align      4                                                   ! Memory alignment.
.section    ".data"                                             ! New data section for an array of months.
            month:  .word   JA_m, FB_m, MA_m, AP_m, MY_m, JN_m, JL_m, AU_m, SE_m, OC_m, NV_m, DE_m

            JA_m:   .asciz  "January"                           ! Month names for output String.
            FB_m:   .asciz  "February"
            MA_m:   .asciz  "March"
            AP_m:   .asciz  "April"
            MY_m:   .asciz  "May"
            JN_m:   .asciz  "June"
            JL_m:   .asciz  "July"
            AU_m:   .asciz  "August"
            SE_m:   .asciz  "September"
            OC_m:   .asciz  "October"
            NV_m:   .asciz  "November"
            DE_m:   .asciz  "December"

.align      4                                                   ! Memory alignment.
.section    ".data"                                             ! New data section for an array of suffixes.
       daySuffix:   .word   st_m, nd_m, rd_m, th_m

            st_m:   .asciz  "st"                                ! Suffixes for appropriate day numbers.
            nd_m:   .asciz  "nd"
            rd_m:   .asciz  "rd"
            th_m:   .asciz  "th"

.align      4                                                   ! memory alignment
.section    ".data"                                             ! New data section upper bounds on day number.
       dayBounds:   .word   JAd_m, FBd_m, MAd_m, APd_m, MYd_m, JNd_m, JLd_m, AUd_m, SEd_m, OCd_m, NVd_m, DEd_m

            JAd_m:  .asciz  "31"                                ! Upper bounds for day numbers, relative to month.
            FBd_m:  .asciz  "28"
            MAd_m:  .asciz  "31"
            APd_m:  .asciz  "30"
            MYd_m:  .asciz  "31"
            JNd_m:  .asciz  "30"
            JLd_m:  .asciz  "31"
            AUd_m:  .asciz  "31"
            SEd_m:  .asciz  "30"
            OCd_m:  .asciz  "31"
            NVd_m:  .asciz  "30"
            DEd_m:  .asciz  "31"

.section    ".text"                                             ! The meat of the program.
begin_main                                                      ! main()

check:          cmp     %i0,            4                       ! Check the number of elements in arguments array.
                be      validArguments                          ! If exactly equal to 4, proceed.
                nop

                set     badArguments,   %o0                     ! Else, set error message in badArguments to %o0.
                call    printf                                  ! Print the error message.
                nop

                call    exit                                    ! Exit the program.
                nop

validArguments: set     month,          %l0                     ! Make the month array locally accessible. 
                set     daySuffix,      %l1                     ! Make the suffix array locally accessible.
                set     dayBounds,      %l2                     ! Make the upper bounds array locally acessible.

checkMonth:     ld      [%i1 + 4],      %o0                     ! Take the first argument for month.
                call    atoi                                    ! Change ASCII String to Integer type.
                nop

                mov     %o0,            %l3                     ! Move the new integer month to local register to avoid overwriting.
                sub     %l3,            1,      %l3             ! Subtract 1 from the month.
                smul    %l3,            4,      %l3             ! Multiply by 4. We can now use %l3 to access the month in month array.

                cmp     %o0,            0                       ! Check lower bound. If 0 < month, proceed.
                ble     badArgsM                                ! Else, branch to badArgsM to print error message and exit.
                nop
                
                cmp     %o0,            12                      ! Check upper bound. If month < 13, proceed. (i.e. 0 < month < 13).
                bg      badArgsM                                ! Else, branch to badArgsM to print error message and exit.
                nop

checkDay:       ld      [%i1 + 8],      %o0                     ! Take the second argument for day.
                call    atoi                                    ! Change ASCII String to Integer type.
                nop

                mov     %o0,            %l4                     ! Move the new integer day to local register to avoid overwriting.

                cmp     %l4,            0                       ! Check lower bound. If 0 < day, proceed.
                ble     badArgsD                                ! Else, branch to badArgsD to print error message and exit.
                nop

                ld      [%l2 + %l3],    %o0                     ! Load the upper bound according to the month.
                call    atoi                                    ! Change ASCII String to Integer type.
                nop
                
                cmp     %l4,            %o0                     ! Check upper bound. If day < upper bound + 1,  proceed. 
                                                                ! (i.e. 0 < day < upper bound + 1).
                bg      badArgsD                                ! Else, branch to badArgsD to print error message and exit.
                nop
                
checkYear:      ld      [%i1 + 12],     %o0                     ! Take the third argument for year.
                call    atoi                                    ! Change ASCII String to Integer type.
                nop
                
                cmp     %o0,            0                       ! Check lower bound. If year < -1, proceed.
                bl      badArgsY                                ! Else, branch to badArgsY to print error message and exit.
                nop
                
                set     9999,           %l5                     ! Set 9999 to a register to avoid Assembler Overflow
                
                cmp     %o0,            %l5                     ! Check upper bound. If year < 10000, proceed.
                bg      badArgsY                                ! Else, branch to badArgsY to print error message and exit.
                nop
                
                ba      testSuffix                              ! All arguments valid. Proceed to find appropriate suffix for day.
                nop
                
badArgsM:       set     badMonth,       %o0                     ! Set the appropriate error message to output register.
                call    printf                                  ! Print the error message.
                nop
                
                call    exit                                    ! Exit the program.
                nop

badArgsD:       set     badDay,         %o0                     ! Set the appropriate error message to output register.
                call    printf                                  ! Print the error message.
                nop
                
                call    exit                                    ! Exit the program.
                nop

badArgsY:       set     badYear,        %o0                     ! Set the appropriate error message to output register.
                call    printf                                  ! Print the error message.
                nop
                
                call    exit                                    ! Exit the program.
                nop

testSuffix:     cmp     %l4,            3                       ! Does day < 3? If not, proceed.
                ble     setSuffixA                              ! Else, branch to setSuffixA for more specific tests.
                nop
                
                cmp     %l4,            31                      ! Does day = 31? If not, proceed.
                be      setSuffixST                             ! Else, branch to setSuffixST to set suffix to "st."
                nop
                
                cmp     %l4,            21                      ! Does 20 < day < 31? If not, proceed.
                bge     setSuffixB                              ! Else, branch to setSuffixB for more specific tests.
                nop
                
                ld      [%l1 + 12],     %o3                     ! Since all tests failed, day must have suffix "th."
                
                ba      printArgs                               ! Proceed to output handling.
                nop

setSuffixA:     cmp     %l4,            3                       ! Does day = 3? If not, proceed.
                be      setSuffixRD                             ! Else, branch to setSuffixRD to set suffix to "rd."
                nop
                
                cmp     %l4,            2                       ! Does day = 2? If not, proceed.
                be      setSuffixND                             ! Else, branch to setSuffixND to set suffix to "nd."
                nop
                
                ld      [%l1 + 0],      %o3                     ! day < 3, but day != 2 | 3, so day = 1. Set suffix to "st."
                
                ba      printArgs                               ! Proceed to output handling.
                nop
                
setSuffixB:     cmp     %l4,            21                      ! Does day = 21? If not, proceed.
                be      setSuffixST                             ! Else, branch to setSuffixST to set suffix to "st."
                nop
                
                cmp     %l4,            22                      ! Does day = 22? If not, proceed.
                be      setSuffixND                             ! Else, branch to setSuffixND to set suffix to "nd."
                nop
                
                cmp     %l4,            23                      ! Does day = 23? If not, proceed.
                be      setSuffixRD                             ! Else, branch to setSuffixRD to set suffix to "rd."
                nop
                
                ld      [%l1 + 12],     %o3                     ! 23 < day < 31, so set suffix to "th."
                
                ba      printArgs                               ! Proceed to output handling.
                nop
                
setSuffixST:    ld      [%l1 + 0],      %o3                     ! Set suffix to "st."
                
                ba      printArgs                               ! Proceed to output handling.
                nop

setSuffixND:    ld      [%l1 + 4],      %o3                     ! Set suffix to "nd."
                    
                ba      printArgs                               ! Proceed to output handling.
                nop
                
setSuffixRD:    ld      [%l1 + 8],      %o3                     ! Set suffix to "rd" and proceed to output handling.
                
printArgs:      ld      [%l0 + %l3],    %o1                     ! Load month name as first output argument
                ld      [%i1 + 8],      %o2                     ! Load day number as second output argument.
                ld      [%i1 + 12],     %o4                     ! Since suffix is already set as third output argument,
                                                                ! skip it and load year number as fourth output argument.
                
                set     date,           %o0                     ! Set date as output string.
                call    printf                                  ! Print output string.
                nop
end_main
