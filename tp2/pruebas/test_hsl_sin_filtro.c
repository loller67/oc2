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

unsigned long hsl[3][ciclos];

char* src = "img/lena.bmp";
char* dst = "img/lenapruebaHSL.bmp";
float hh = 360.0;
float ss = 0.2;
float ll = 0.1;

for (int j = 0; j<=2; j++){

	for (int i = 1; i<=ciclos; i++){

		// TESTEO hsl

		RDTSC_START(start);

		// ... codigo ...

		run_hsl(j, src ,dst, hh, ss, ll);

		// ... codigo ...

		RDTSC_STOP(end);

		delta = end - start;
		hsl[j][i] = delta;
		promedio[j] = promedio[j] + delta;

	}

	promedio[j] = promedio[j] / ciclos;
	printf("El promedio de ciclos de reloj de la implementacion HSL_%i es de: %lu \n",j, promedio[j] );

}

//Calculo desvio estandar
for (int j = 0; j<=2; j++){

	for (int i = 1; i<=ciclos; i++){

		desvio[j] = desvio[j] + ( (hsl[j][i] - promedio[j]) * (hsl[j][i] - promedio[j]) );

	}

	desvio[j] = desvio[j] / ciclos;
	desvio[j] = sqrt(desvio[j]);
	printf("El desvio estandar correspondiente a la implementacion HSL_%i es de: %lu \n",j, desvio[j] );
}


return 0;

}




