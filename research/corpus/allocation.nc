+ <stdlib.h>
s Node
  value: int
  next: *Node
f main() -> int
  head: *Node = malloc(sizeof *head)
  if head == NULL
    return 1
  head->value = 7
  head->next = NULL
  answer: int = head->value
  free(head)
  return answer != 7
