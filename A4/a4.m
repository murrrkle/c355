! CPSC 355 ASSIGNMENT 4: STRUCTURES AND SUBROUTINES
! ============================================================
! Completed on 07-11-2013 by HUNG, Michael (UCID: 10099049)
!
! Implements the following C code:
!
! #define FALSE  0
! #define TRUE   1
!
! struct point {
!   int x, y;
! };
!
! struct dimension {
!   int width, height;
! };
!
! struct box {
!   struct point origin;
!   struct dimension size;
!   int area;
! };
!
!
! struct box newBox()
! {
!   struct box b;
!
!   b.origin.x = 0;
!   b.origin.y = 0;
!   b.size.width = 1;
!   b.size.height = 1;
!   b.area = b.size.width * b.size.height;
!
!   return b;
! }
!
! void move(struct box *b, int deltaX, int deltaY)
! {
!   b->origin.x += deltaX;
!   b->origin.y += deltaY;
! }
!
! void expand(struct box *b, int factor)
! {
!   b->size.width *= factor;
!   b->size.height *= factor;
!   b->area = b->size.width * b->size.height;
! }
! 
! void printBox(char *name, struct box *b)
! {
!   printf("Box %s origin = (%d, %d)  width = %d  height = %d  area = %d\n",
	 ! name, b->origin.x, b->origin.y, b->size.width, b->size.height,
	 ! b->area);
! }
! 
! int equal(struct box *b1, struct box *b2)
! {
!   int result = FALSE;
! 
!   if (b1->origin.x == b2->origin.x) {
!     if (b1->origin.y == b2->origin.y) {
!       if (b1->size.width == b2->size.width) {
!         if (b1->size.height == b2->size.height) {
!           result = TRUE;
!         }
!       }
!     }
!   }
!
!   return result;
! }
!
! int main()
! {
!   struct box first, second;
!  
!   first = newBox();
!   second = newBox();
!
!   printf("Initial box values:\n");
!   printBox("first", &first);
!   printBox("second", &second);
!
!   if (equal(&first, &second)) {
!     move(&first, -5, 7);
!     expand(&second, 3);
!   }
!
!   printf("\nChanged box values:\n");
!   printBox("first", &first);
!   printBox("second", &second);
!}
!

include(macro_defs.m)                                                   ! Include the file macro_defs.m for extended macro usage

define(FALSE, 0)
define(TRUE, 1)

begin_struct(point)                                                     ! New structure: point. Has two integer fields - 8 bytes.

    field(x, 4)
    field(y, 4)

end_struct(point)                                                       ! End definition for structure: point

begin_struct(dimension)                                                 ! New Structure: dimension. Has two integer fields - 8 bytes.

    field(width, 4)
	field(height, 4)

end_struct(dimension)                                                   ! End definition for structure: dimension

begin_struct(box)                                                       ! New Structure: box. Has five integer fields for a total of 20 bytes.

    field(origin, align_of_point, size_of_point)
	field(size, align_of_dimension, size_of_dimension)
	field(area, 4)

end_struct(box)                                                         ! End definition for structure: box

local_var                                                               ! New local variables:
    var(b_first_s, align_of_box, size_of_box)                           ! b_first_s of data type box. 20 bytes.
    var(b_second_s, align_of_box, size_of_box)                          ! b_second_s of data type box. 20 bytes.

begin_fn(newBox)                                                        ! New Function: newBox. Initializes point_x, point_y, dimension_height, dimension_width, and box_area

    add     %fp,                        %i0,                    %o0     ! Getting the address for a new box to initialize.
	st	    %g0,                        [%o0 + point_x]                 ! Store 0 in point_x
	st	    %g0,                        [%o0 + point_y]                 ! Store 0 in point_y
	mov	    1,                          %l1                             ! Moving 1 to %l1
	st      %l1,                        [%o0 + dimension_width]         ! Store 1 in dimension_width
	st	    %l1,                        [%o0 + dimension_height]        ! Store 1 in dimension_height
    st      %l1,                        [%o0 + box_area]                ! Store 1 in box_area

end_fn(newBox)                                                          ! End definition for function: newBox

begin_fn(move)                                                          ! New Function: move. Takes three arguments - box address and modifiers. Changes point_x and point_y of given box.

    add     %fp,                        %i0,                    %o0     ! Getting the address for the box to modify.
    ld      [%o0 + point_x],            %l0                             ! Getting the old point_x
    ld      [%o0 + point_y],            %l1                             ! Getting the old point_y
    add     %l0,                        %i1,                    %l0     ! Adding old point_x with x modifier
    add     %l1,                        %i2,                    %l1     ! Adding old point_y with y modifier
    st      %l0,                        [%o0 + point_x]                 ! Storing the new point_x
    st      %l1,                        [%o0 + point_y]                 ! Storing the new point_y

end_fn(move)                                                            ! End definition for function: move

begin_fn(expand)                                                        ! New Function: expand. Takes two arguments - box address and multiplier factor. Changes dimension_height and dimension_width of given box.

    add     %fp,                        %i0,                    %o0     ! Getting the address for the box to modify
    ld      [%o0 + dimension_width],    %l0                             ! Getting the old dimension_width
    ld      [%o0 + dimension_height],   %l1                             ! Getting the old dimension_height
    smul    %l0,                        %i1,                    %l0     ! Multiplying old dimension_width with multiplier
    smul    %l1,                        %i1,                    %l1     ! Multiplying old dimension_height with multiplier
    smul    %l0,                        %l1,                    %l2     ! Multiplying new dimension_width and dimension_height for new box_area
    st      %l0,                        [%o0 + dimension_width]         ! Storing new dimension_width
    st      %l1,                        [%o0 + dimension_height]        ! Storing new dimension_height
    st      %l2,                        [%o0 + box_area]                ! Storing new box_area

end_fn(expand)                                                          ! End definition of function: expand

begin_fn(equal)                                                         ! New Function: equal. Tests for equality between two boxes.

    ld      [%fp + b_first_s + point_x],    %l0                         ! Load point_x of b_first_s
    ld      [%fp + b_second_s + point_x],   %l1                         ! Load point_x of b_second_s

    ld      [%fp + b_first_s + point_y],    %l2                         ! Load point_y of b_first_s
    ld      [%fp + b_second_s + point_y,],  %l3                         ! Load point_y of b_second_s

    ld      [%fp + b_first_s + dimension_height],   %l4                 ! Load dimension_height of b_first_s
    ld      [%fp + b_second_s + dimension_height],  %l5                 ! Load dimension_height of b_second_s

    ld      [%fp + b_first_s + dimension_width],    %l6                 ! Load dimension_width of b_first_s
    ld      [%fp + b_second_s + dimension_width],   %l7                 ! Load dimension_width of b_second_s

    cmp     %l0,    %l1                                                 ! Test for equality between point_x's
    bne,a   false                                                       ! If not equal, branch to false
    mov     FALSE,  %o0                                                 ! return 0 for FALSE; filled delay slot

    cmp     %l2,    %l3                                                 ! Test for equality between point_y's
    bne,a   false                                                       ! If not equal, branch to false
    mov     FALSE,  %o0                                                 ! return 0 for FALSE; filled delay slot

    cmp     %l4,    %l5                                                 ! Test for equality between dimension_height
    bne,a   false                                                       ! If not equal, branch to false
    mov     FALSE,  %o0                                                 ! return 0 for FALSE; filled delay slot

    cmp     %l6,    %l7                                                 ! Test for equality betwen dimension_width
    bne,a   false                                                       ! If not equal, branch to false
    mov     FALSE,  %o0                                                 ! return 0 for FALSE; filled delay slot

    mov     TRUE,   %o0                                                 ! All tests passed, move 1 into %o0

false:      mov     %o0,    %i0                                         ! Move result into %i7 for returning window

end_fn(equal)                                                           ! End definition of function: equal

printInit:  .asciz  "Initial Box values:"
            .align  4

printCh:    .asciz  "\nChanged Box values:"
            .align  4

messageA:   .asciz  "Box: %s\n"
            .align  4

messageB:   .asciz  "origin = (%d, %d) \n width = %d \n height = %d \n area = %d \n"
            .align  4

begin_fn(printBox)                                                      ! New Function: printBox. Takes the address of a given box in %i0, and a string in %i1.

    set     messageA,                   %o0                             ! Preparing the message to print the string.


    call    printf                                                      ! Printing box name.
    mov     %i1,                        %o1                             ! Moving the string into output register for printing; filled delay slot



    add     %fp,                        %i0,                    %l0     ! Getting address of the box
    ld      [%l0 + point_x],            %o1                             ! Storing point_x of the box into output register
    ld      [%l0 + point_y],            %o2                             ! Storing point_y of the box into output register
    ld      [%l0 + dimension_height],   %o3                             ! Storing dimension_height of the box into output register
    ld      [%l0 + dimension_width],    %o4                             ! Storing dimension_width of the box into output register
    ld      [%l0 + box_area],           %o5                             ! Storing box_area of the box into output register

    call    printf                                                      ! Printing box data
    set     messageB,                   %o0                             ! Preparing the message to print the data; filled delay slot

end_fn(printBox)                                                        ! End definition of function: printBox.


begin_main                                                              ! Begin main program


    call    newBox                                                      ! Initialize values in b_first_s
    mov     b_first_s,                  %o0                             ! Provide address of first box as argument to newBox; filled delay slot


    call    newBox                                                      ! Initialize values in b_second_s
    mov     b_second_s,                 %o0                             ! Provide address of second box as argument to newBox; filled delay slot


    call    printf
    set     printInit,                  %o0                             ! Print message to indicate we are now printing the initial values of the boxes; filled delay slot

    set     "first",                    %o1                             ! Pass string argument for function call
    call    printBox                                                    ! Print the values in b_first_s
    set     b_first_s,                  %o2                             ! Pass first box address as argument for function call; filled delay slot

    set     "second",                   %o1                             ! Pass string argument for function call
    call    printBox                                                    ! Print the values in b_second_s
    set     b_second_s,                 %o2                             ! Pass second box address as argument for function call; filled delay slot

    clr     %o0                                                         ! Clear output registers for later function calls
    clr     %o1

    call    equal                                                       ! Test for equality. A 1 or 0 is returned in %o0.
    clr     %o2                                                         ! Filled delay slot

    cmp     %o0,                        1                               ! Did the test pass? If it did, continue on. If not, branch to done, and end main.
    bne     done
    nop

    set     b_first_s,                  %o0                             ! The following three lines set arguments for use in function move. Used on b_first_s.
    mov     -5,                         %o1


    call    move                                                        ! Function move called.
    mov     7,                          %o2                             ! Filled delay slot

    set     b_second_s,                 %o0                             ! Set arguments for us in function expand. Used on b_second_s


    call    expand                                                      ! Function expand called.
    mov     3,                          %o1                             ! Filled delay slot


    call    printf
    set     printCh,                    %o0                             ! Print message to indicate we are now printing the new values of the boxes; filled delay slot

    set     "first",                    %o1                             ! From this point, the rest of the program gives arguments to printBox in order to print the values of b_first_s and b_second_s
    call    printBox
    set     b_first_s,                  %o2                             ! Filled delay slot

    set     "second",                   %o1
    call    printBox
    set     b_second_s,                 %o2                             ! Filled delay slot


    done:
end_main
