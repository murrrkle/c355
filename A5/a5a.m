! CPSC 355 ASSIGNMENT 5A: Global Variables and Separate Compilation
! =================================================================
! Completed on 22-11-2013 by HUNG, Michael (UCID: 10099049)
!
! Implements the specified C Code from Assignment 5 Part A.
!

include(macro_defs.m)                                                       ! Include macro definitions.

.global     top, stack                                                      ! top and stack are global variables.

.section    ".text"

define(STACKSIZE, 5)                                                        ! STACKSIZE = 5. Constant.
define(TRUE,      1)
define(FALSE,     0)

stackOvflw: .asciz  "\nStack overflow! Cannot push value onto stack.\n"     ! Stack Overflow error message.
            .align  4

stackUnflw: .asciz  "\nStack underflow! Cannot pop an empty stack.\n"       ! Stack Underflow error message.
            .align  4

stkIsEmpty: .asciz  "\nEmpty stack\n"                                       ! Stack is empty for display.
            .align  4

stkContent: .asciz  "\nCurrent stack contents:\n"                           ! First line of display output.
            .align  4

prtContent: .asciz  "  %d"                                                  ! Printing elements of stack.
            .align  4

lineBreak:  .asciz  "\n"                                                    ! Line Break for after display output.
            .align  4

topStack:   .asciz  " <-- top of stack"                                     ! Indicates element on top of stack.
            .align  4

begin_fn(push)                                                              ! Pushes a new element on top of stack.
            call stackFull                                                  ! Check if the stack is already full.
            nop

            cmp     %o0,        TRUE                                        ! Is the stack already full?
            be      errorFull                                               ! If it is, branch to errorFull.
            nop                                                             ! Else, proceed.

            sethi   %hi(top),   %o0                                         ! Get the address of top into %o0.
            or      %o0,        %lo(top),   %o0

            ld      [%o0],      %l0                                         ! Load value of top into %l0.

            inc     %l0                                                     ! Stack has grown by 1.
            st      %l0,        [%o0]                                       ! Update value of top.
            sll     %l0,        2,          %l0                             ! Multiply top by 4 for offset to access stack memory.

            sethi   %hi(stack), %o1                                         ! Get the address of stack in memory.
            or      %o1,        %lo(stack), %o1

            st      %i0,        [%o1 + %l0]                                 ! Store the new value on the stack.

            ba      donePush                                                ! Done pushing.
            nop

errorFull:  set     stackOvflw, %o0                                         ! Prepare Overflow error message.
            call    printf                                                  ! Print overflow eror message.
            nop

donePush:   clr     %o0                                                     ! Done pushing, clear registers used.
            clr     %o1
            clr     %l0
end_fn(push)


begin_fn(pop)                                                               ! Pops an element off the stack.
            call    stackEmpty                                              ! Check if the stack is already empty.
            nop

            cmp     %o0,        TRUE                                        ! Is the stack already empty?
            be      errorEmpty                                              ! If it is, branch to errorEmpty.
            nop                                                             ! Else, proceed.

            sethi   %hi(top),   %o0                                         ! Load address of top into %o0.
            or      %o0,        %lo(top),   %o0

            ld      [%o0],      %l0                                         ! Load value of top into %l0

            sll     %l0,        2,          %l1                             ! Get offset of top element on stack into %l1.

            sethi   %hi(stack), %o1                                         ! Load the value of the top element on stack.
            or      %o1,        %lo(stack), %o1

            ld      [%o1 + %l1],%i0                                         ! Load that value into return input register.

            dec     %l0                                                     ! Decrease top by 1.
            st      %l0,        [%o0]                                       ! Update top in memory.

            ba      donePop                                                 ! Done popping.
            nop

errorEmpty: set     stackUnflw, %o0                                         ! Prepare Underflow error message.
            call    printf                                                  ! Print Underflow error message.
            nop

donePop:    clr     %o0                                                     ! Done popping, clear registers used.
            clr     %o1
            clr     %l0
            clr     %l1
end_fn(pop)


begin_fn(stackFull)                                                         ! Checks if the stack is already full.
            sethi   %hi(top),   %o0                                         ! Load address of top into %o0.
            or      %o0,        %lo(top),   %o0

            ld      [%o0],      %l0                                         ! Load value of top into %l0.

            mov     STACKSIZE,  %l5                                         ! Move maximum stack size into %l5.

            sub     %l5,        1,          %l1                             ! Max Stack size minus 1 to compare with top.

            cmp     %l0,        %l1                                         ! Does top = STACKSIZE?
            be      ifFULL                                                  ! If it does, branch to ifFULL.
            nop                                                             ! Else, proceed.

            mov     FALSE,      %i0                                         ! Return FALSE.

            ba      doneFull                                                ! Branch to doneFull.
            nop

ifFULL:     mov     TRUE,       %i0                                         ! Return TRUE and proceed to doneFULL.

doneFull:   clr     %o0                                                     ! Done checking, clear registers used.
            clr     %l0
            clr     %l1
            clr     %l5
end_fn(stackFull)


begin_fn(stackEmpty)                                                        ! Checks if the stack is already empty.
            sethi   %hi(top),   %o0                                         ! Load address of top into %o0.
            or      %o0,        %lo(top),   %o0

            ld      [%o0],      %l0                                         ! Load value of top into %l0.

            mov     -1,         %l1                                         ! Mov -1 into %l1 to compare with top.

            cmp     %l0,        %l1                                         ! Does top = -1?
            be      ifEMPTY                                                 ! If it does, branch to ifEMPTY.
            nop

            mov     FALSE,      %i0                                         ! Else, stack isn't empty so return FALSE.

            ba      doneEmpty                                               ! Branch to doneEmpty.
            nop

ifEMPTY:    mov     TRUE,       %i0                                         ! Stack is empty, return TRUE.

doneEmpty:  clr     %o0                                                     ! Done checking, clear registers used.
            clr     %l0
            clr     %l1
end_fn(stackEmpty)


begin_fn(display)                                                           ! Check if stack is empty.
            call    stackEmpty
            nop

            cmp     %o0,        TRUE                                        ! If it is, branch to isEmpty.
            be      isEmpty
            nop

            set     stkContent, %o0                                         ! Else, print the initial line for displaying.
            call    printf
            nop

            sethi   %hi(top),   %l0                                         ! Load address of top into %l0.
            or      %l0,        %lo(top),   %l0

            ld      [%l0],      %l0                                         ! Load value of top into %l0, call it i. Will be used to traverse.

            sethi   %hi(stack), %l1                                         ! Load address of stack into %l1.
            or      %l1,        %lo(stack), %l1

            mov     %l0,        %l3                                         ! Save value of top for comparing

loop:       cmp     %l0,        0                                           ! Is i still <= 0?
            bl      doneDisp                                                ! if not, branch to doneDisp.
            nop

            sll     %l0,        2,          %l2                             ! Multiply i by 4 and store in %l2 for offset to access stack.

            ld      [%l1 + %l2],%o1                                         ! Load the value in the stack at that index to %o1 for printing.

            set     prtContent, %o0                                         ! Load print statement to %o0.
            call    printf                                                  ! Print stack element.
            nop

            cmp     %l0,        %l3                                         ! Check if i = top.
            be      prtTop                                                  ! If it is, branch to prtTop.
            nop

            dec     %l0                                                     ! Decrement index i by 1.

            set     lineBreak,  %o0                                         ! Print a line break character.
            call    printf
            nop

            ba      loop                                                    ! Go back to loop.
            nop

prtTop:     set     topStack,   %o0                                         ! i = top. Set corresponding output string to %o0.
            call    printf                                                  ! Print " <-- top of stack"
            nop

            dec     %l0                                                     ! Decrement index by 1.

            set     lineBreak,  %o0                                         ! Print a line break character.
            call    printf
            nop

            ba      loop                                                    ! Go back to loop.
            nop

isEmpty:    set     stkIsEmpty, %o0                                         ! Stack is empty. Set corresponding output string to %o0.
            call    printf                                                  ! Print "Empty stack"
            nop

doneDisp:   clr     %o0                                                     ! Done displaying. Clear registers used.
            clr     %o1
            clr     %l0
            clr     %l1
            clr     %l2
            clr     %l3
end_fn(display)