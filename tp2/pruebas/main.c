#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "run.h"
#include "bmp/bmp.h"
#include "filters/filters.h"
#include "rdtsc.h"

int main(){


int ciclos = 100;

unsigned long start, end;
unsigned long delta;

unsigned long blurC[ciclos];
unsigned long suma = 0;

for (int i = 1; i<=100; i++){

	RDTSC_START(start);

	// ... codigo ...

	char* src = "lena.bmp";
	char* dst = "lenaprueba.bmp";

	run_blur(2, src ,dst);

	// ... codigo ...

	RDTSC_STOP(end);

	delta = end - start;
	blurC[i] = delta;
	suma += delta;

}
	suma = suma / ciclos;
	printf("Cantidad de Ciclos promedio: %lu \n", suma);

return 0;

}