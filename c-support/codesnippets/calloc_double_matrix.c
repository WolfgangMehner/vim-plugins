
/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  calloc_double_matrix
 *  Description:  Allocate a dynamic double-matrix of size rows*columns;
 *                return a pointer.
 * =====================================================================================
 */
  double**
calloc_double_matrix ( int rows, int columns )
{
  int      i;
  double **m;
  m     = calloc ( rows, sizeof(double*) );       /* allocate pointer array     */
  assert( m != NULL );                            /* abort if allocation failed */
  m[0]  = calloc ( rows*columns, sizeof(double) );/* allocate data array        */
  assert(*m != NULL );                            /* abort if allocation failed */
  for ( i=1; i<rows; i+=1 )                       /* set pointers               */
    m[i]  = m[i-1] + columns;
  return m;
}  /* ----------  end of function calloc_double_matrix  ---------- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  free_matrix_double
 *  Description:  Free a dynamic double-matrix.
 * =====================================================================================
 */
  double**
free_double_matrix ( double **m )
{
  free(*m);                                       /* free data array            */
  free( m);                                       /* free pointer array         */
  return NULL;
}  /* ----------  end of function free_double_matrix  ---------- */

