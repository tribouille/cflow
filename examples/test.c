typedef struct toto
{
  int		i;
}		toto_t;

const void	f(int i[5], const int j, ...);
char	g(toto_t *j, toto_t *m);

char	g(toto_t *j, toto_t *m)
{
  int	i;

  f((j = 0), i);
}

int	il()
{
  int i,j;
  return (1);
}

int	main(int ac, char **av)
{
  int	i;
  int	j;
  toto_t	m;

  f(i, j);
  g(0, &m);
  il();
  return (0);
}

const void	f(int i[5], const int j, ...)
{
  toto_t	m;

  i = j =0;
  s();
  g(0, &m);
}

void s()
{
}
