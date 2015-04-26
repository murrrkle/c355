! CPSC 355 Fall 2013 Assignment 5 Part B
! Submitted by Arnold Padillo
! T02 w/ Rashmi Kumari

importmacro:
include(macro_defs.m)       ! Imports universal Macros

output:
.asciz  "%s %s%s, %s\n"     ! Preparing output string
.align  4

error:
  .asciz "Usage: mm dd yyyy\n"   ! Error message: Insufficient/too many arguments
  .align  4
  
invaliddate:
	.asciz "Invalid Date Number \n"  ! Invalid date (>31)
	.align 4
	
invalidmonth:
	.asciz "Invalid Month Number\n" ! Invalid month (>12)
	.align 4
  
invalidyear:
  .asciz "Invalid Year Number (Enter YYYY)\n"  ! Invalid year (<1000 or > 9999)
  .align 4

.align  4
.section ".data"        ! Writing in .data section
month: .word jan_m, feb_m, mar_m, apr_m, may_m, jun_m, jul_m, aug_m, sep_m, oct_m, nov_m, dec_m ! Month array


! External Pointer array: Each element is a month

jan_m: .asciz "January"
feb_m: .asciz "February"
mar_m: .asciz "March"
apr_m: .asciz "April"
may_m: .asciz "May"
jun_m: .asciz "June"
jul_m: .asciz "July"
aug_m: .asciz "August"
sep_m: .asciz "September"
oct_m:.asciz "October"
nov_m:.asciz "November"
dec_m:.asciz "December"

.align 4
.section ".data"      ! Writing in .data section  
suffix: .word st_m, nd_m, rd_m, th_m    ! Suffix array

! External Pointer array: Each element is a suffix

st_m: .asciz "st"
nd_m: .asciz "nd"
rd_m: .asciz "rd"
th_m: .asciz "th"

.section ".text"						! Writing in the .text section
begin_main                  ! Main() starts here

  cmp %i0, 4								! Comparing arguments
  be validargs							! If there are 3 Arguments (+ Program name), the entry is valid
  nop												! Delay slot
  
  set error,  %o0						! For invalid entries
  call printf								! Call error print statement
  nop												! Delay slot
  
  call exit                 ! Exit Program: No further verification
  nop                       ! Delay Slot
  
validargs:									! Valid entry: Proceed here
  set month,	%l0   			  ! Pointer initialized for month array
  set suffix, 	%l1         ! Pointer initialized for suffix array
  
checkmonthbound1:           ! Month Bound Verification
  ld [%i1 + 4], %o0         ! Month Argument in %o0
  call atoi                 ! Converting Month String into Integer
  nop                       ! Delay Slot
  
  cmp %o0, 0                ! Month number must be Positive
  bg checkmonthbound2       ! If positive, proceed to second verification
  nop                       ! Delay Slot
  
  set invalidmonth, %o0     ! Invalid Month Error Message
  call printf               ! Prints error message
  nop                       ! Delay slot
  
  call exit                 ! Exit program: No further verification
  nop                       ! Delay slot

checkmonthbound2:           ! Month Bound Verification
  cmp %o0, 12               ! Month number must be <= 12
  ble checkdaybound1        ! If valid month, proceed to day verification
  nop                       ! Delay Slot
  
  set invalidmonth, %o0     ! Invalid Month Error Message
  call printf               ! Prints error message
  nop                       ! Delay slot
  
  call exit                 ! Exit program: No further verification
  nop                       ! Delay slot
  
checkdaybound1:             ! Day bound verification  
  ld [%i1 + 8], %o0         ! Day Argument in %o0
	call atoi                 ! Converting Day String into Integer
	nop                       ! Delay slot
  
  cmp %o0,  0               ! Day number must be Positive
  bg checkdaybound2         ! If positive, proceed to second verification
  nop                       ! Delay slot
  
  set invaliddate,  %o0     ! Invalid Day Error Message
  call printf               ! Prints error message
  nop                       ! Delay slot
  
  call exit                 ! Exit Program: No further verification
  nop                       ! Delay slot
  
checkdaybound2:             ! Day bound verification  
  cmp %o0,  31              ! Day number must be <= 31
  ble checkyearbound1       ! If valid day, proceed to suffix integration
  nop                       ! Delay slot
  
  set invaliddate,  %o0     ! Invalid Day Error Message
  call printf               ! Prints error message
  nop                       ! Delay slot
  
  call exit                 ! Exit Program: No further verification
  nop                       ! Delay slot
  
checkyearbound1:            ! Year Bound verification
  ld [%i1 + 12],  %o0       ! Year Argument in %o0
  call atoi                 ! Converting Year String into Integer
  nop                       ! Delay slot
  
  cmp %o0, 1000             ! Year number must be 4 Digits
  bge checkyearbound2       ! If more >= 1000, proceed to next verification
  nop                       ! Delay slot
  
  set invalidyear, %o0      ! Invalid Year Error Message
  call printf               ! Prints error message
  nop                       ! Delay slot
  
  call exit                 ! Exit Program: No further verification
  nop                       ! Delay slot
  
checkyearbound2:            ! Year Bound verification
  set 9999, %l3             ! Year number must be 4 Digits
  cmp %o0, %l3              ! Year number must be <= 9999
  ble generalcase           ! If <= 9999, proceed to suffix verification
  nop                       ! Delay slot
  
  set invalidyear, %o0      ! Invalid Year Error Message
  call printf               ! Prints error message
  nop                       ! Delay slot
  
  call exit                 ! Exit Program: No further verification
  nop                       ! Delay slot
  
generalcase:								! General Case: The suffix will be th
  ld [%i1 + 8], %o0         ! Suffix argument in %o0
  call atoi                 ! Converting String into Integer
  nop                       ! Delay Slot
	mov 12, %l2               ! Offset for Suffix "th" in array

checkfirst:									! Case 1: The Suffix will be st for 1
	cmp %o0, 1                ! Is the Day number = 1 ?
	bne checksecond           ! If not, check if Day number = 2
	nop                       ! Delay slot

	mov 0, %l2                ! If the Day number = 1, its suffix will be "st"

checksecond:								! Case 2: The suffix will be nd for 2
	cmp %o0, 2                ! Is the Day number = 2?
	bne checkthird            ! If not, check if Day number = 3
	nop                       ! Delay slot

	mov 4,	%l2               ! If the Day number = 2, its suffix will be "nd"

checkthird:									! Case 3: The suffix will be rd for 3
	cmp	%o0, 3                ! Is the Day number = 3?
	bne	twentyfirst           ! If not, check if Day number = 21
	nop                       ! Delay slot

	mov 8, %l2                ! If the Day number = 3, its suffix will be "rd"
  
twentyfirst:                ! Case 4 : The suffix will be st for 21
  cmp %o0,  21              ! Is the Day number = 21?
  bne twentysecond          ! If not, check if Day number = 22
  nop                       ! Delay slot
  
  mov 0, %l2                ! If the day number is 21, its suffix will be "st"
  
twentysecond:								! Case 4: The suffix will be nd for 22
	cmp %o0, 22               ! Is the day number = 22?
	bne twentythird           ! If not, check if Day number = 23
	nop                       ! Delay slot

	mov 4, %l2                ! If the day number = 22, its suffix will be "nd"

twentythird:								! Case 5: The suffix will be rd for 23
	cmp %o0, 23               ! Is the day number = 23?
	bne thirtyfirst           ! If not, check if Day number = 31
	nop                       ! Delay slot

	mov 8, %l2                ! If the day number = 23, its suffix will be "rd"
  
thirtyfirst:                ! Case 6: The suffix will be st for 31
  cmp %o0,  31              ! Is the day number = 31?
  bne next                  ! If not, general case is applied.
  nop                       ! Delay slot
  
  mov 0, %l2                ! If the day number = 31, its suffix will be "st"

next:
  ld [%i1 + 4], %o0					! Loading first argument into %l1
	call atoi									! Converting ASCII to Integer
	nop												! Delay slot
	
	smul	%o0,	4,	%o0				! Multiply argument to use as offset
	sub		%o0,	4,	%o0				! Adjust offset
	ld [%l0 + %o0],	%o1				! Load corresponding month

	ld [%i1 + 8], %o2					! Date argument into %o2
	ld [%l1 + %l2], %o3       ! Suffix argument into %o3

  
  ld [%i1 + 12], %o4				! Year argument into %o4
 
  set output, %o0           ! Date message
  call	printf              ! Print message
  nop	                      ! Delay slot

end_main                    ! End of Main()
	
