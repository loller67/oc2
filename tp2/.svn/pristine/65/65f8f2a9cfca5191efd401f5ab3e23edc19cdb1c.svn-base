
#include "quicksort.h"

//funcion para dividir el array y hacer los intercambios
int dividir(unsigned long *array, int inicio, int fin)
{
  int izq;
  int der;
  unsigned long pibote;
  unsigned long temp;
 
  pibote = array[inicio];
  izq = inicio;
  der = fin;
 
  //Mientras no se cruzen los índices
  while (izq < der){
    while (array[der] > pibote){
	  der--;
    }
 
	while ((izq < der) && (array[izq] <= pibote)){
      izq++;
    }
 
    // Si todavia no se cruzan los indices seguimos intercambiando
	if(izq < der){
      temp= array[izq];
      array[izq] = array[der];
      array[der] = temp;
    }
  }
 
  //Los indices ya se han cruzado, ponemos el pivote en el lugar que le corresponde
  temp = array[der];
  array[der] = array[inicio];
  array[inicio] = temp;
 
  //La nueva posición del pivote
  return der;
}


//						Funcion Quicksort
//======================================================================
//funcion recursiva para hacer el ordenamiento
void quicksort(unsigned long *array, int inicio, int fin)
{
  int pivote;
  if(inicio < fin)
  {
    pivote = dividir(array, inicio, fin );
    quicksort( array, inicio, pivote - 1 );//ordeno la lista de los menores
    quicksort( array, pivote + 1, fin );//ordeno la lista de los mayores
  }
}
 
//======================================================================