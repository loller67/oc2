#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "run.h"
#include "bmp/bmp.h"
#include "filters/filters.h"
#include "rdtsc.h"

int main(){

int ciclos = 1000;

unsigned long start, end;
unsigned long delta;

unsigned long promedio[3] = {0, 0, 0};
unsigned long desvio[3] = {0, 0, 0};

unsigned long merge[3][ciclos];

char* src1 = "img/lena.bmp";
char* src2 = "img/colores.bmp";
char* dst = "img/lenaprueba.bmp";
float value = 0.5;


for (int j = 0; j<=2; j++){

	for (int i = 1; i<=ciclos; i++){

	// TESTEO MERGE

		RDTSC_START(start);

		// ... codigo ...

		run_merge(j, src1 , src2, dst, value);

		// ... codigo ...

		RDTSC_STOP(end);

		delta = end - start;
		merge[j][i] = delta;
		promedio[j] = promedio[j] + delta;

	}

	promedio[j] = promedio[j] / ciclos;
	printf("El promedio de ciclos de reloj de la implementacion MERGE_%i es de: %lu \n",j, promedio[j] );

}

//Calculo desvio estandar
for (int j = 0; j<=2; j++){

	for (int i = 1; i<=ciclos; i++){

		desvio[j] = desvio[j] + ( (merge[j][i] - promedio[j]) * (merge[j][i] - promedio[j]) );

	}

	desvio[j] = desvio[j] / ciclos;
	desvio[j] = sqrt(desvio[j]);
	printf("El desvio estandar correspondiente a la implementacion MERGE_%i es de: %lu \n",j, desvio[j] );
}


return 0;

}