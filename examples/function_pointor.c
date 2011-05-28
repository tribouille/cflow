#include <stdlib.h>
#include <unistd.h>
void	lol();
struct test
{
  int	i;
  void	(*f)();
};

struct test	toto [] =
  {
    {0, NULL},
    {1, lol},
    {2, lol}
  };

void	lol()
{
  write(1, "lol\n", 4);
}

int	main()
{
  int i;
  for (i=2; i > 0; --i)
    {
      toto[i].f();
    }
  return (0);
}
