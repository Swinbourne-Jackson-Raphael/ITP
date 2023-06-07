#include <stdio.h>
#include <string.h>
#include "terminal_user_input.h"

#define LOOP_COUNT 60

void print_silly_name(my_string name);

int main()
{
  my_string name;
  name = read_string("What is your name? ");
  printf("\nYour name");

  if(strcmp(name.str, "May") == 0) {
    printf(" is an AWESOME name!");
  } else {
    print_silly_name(name);
  }

  return 0;
}

void print_silly_name(my_string name) {
    printf(" is a ");
    for (int i = 0; i < LOOP_COUNT; i++) {
      printf("silly ");
    }
  printf("name!\n");
}
