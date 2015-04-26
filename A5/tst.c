#include <stdio.h>
#include <stdlib.h>

#define STACKSIZE   5
#define FALSE       0
#define TRUE        1

/* Function Prototypes */
void push(int value);
int pop();
int stackFull();
int stackEmpty();
void display();

/* Global Variables */
int stack[STACKSIZE];
int top = -1;


void push(int value)
{
    if (stackFull())
        printf("\nStack overflow! Cannot push value onto stack.\n");
    else {
        stack[++top] = value;
    }
}
 
int pop()
{
    register int value;
    
    if (stackEmpty()) {
        printf("\nStack underflow! Cannot pop an empty stack.\n");
        return (-1);
    } else {
        value = stack[top];
        top--;
        return value;
    }
}
 
int stackFull()
{
    if (top == STACKSIZE - 1)
        return TRUE;
    else
        return FALSE;
}
 
int stackEmpty()
{
    if (top == -1)
        return TRUE;
    else
        return FALSE;
}
 
void display()
{
    register int i;
    
    if (stackEmpty())
        printf("\nEmpty stack\n");
    else {
        printf("\nCurrent stack contents:\n");
        for (i = top; i >= 0; i--) {
            printf("  %d", stack[i]);
            if (i == top) {
                printf(" <-- top of stack");
            }
            printf("\n");
        }
    }
}
