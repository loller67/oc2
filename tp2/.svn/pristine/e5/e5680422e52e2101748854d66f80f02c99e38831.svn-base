#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "run.h"
#include "bmp/bmp.h"
#include "filters/filters.h"
#include "rdtsc.h"
#include "quicksort.h"

int main(){

int ciclos = 1000;

int ciclosmod[3] = {ciclos, ciclos, ciclos};

unsigned long start, end;
unsigned long delta;

unsigned long promedio[3] = {0, 0, 0};
unsigned long desvio[3] = {0, 0, 0};

unsigned long q1[3];
unsigned long q3[3];
unsigned long iqr[3];

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

	//Ordeno el array
	quicksort(hsl[j], 0, ciclos-1);

	//Calculo cuartiles para filtrar
	q1[j] = hsl[j][(ciclos+1)/4];
	q3[j] = hsl[j][3*(ciclos+1)/4];
	iqr[j] = q3[j] - q1[j];

	//Filtro outliers

	for (int i = 0; i<=ciclos-1; i++){
		if ( (hsl[j][i] < q1[j]-1.5*iqr[j] ) || (hsl[j][i] > q3[j]+1.5*iqr[j] ) ){
			promedio[j] = promedio[j] - hsl[j][i];
			ciclosmod[j] = ciclosmod[j] - 1;
		}
	}

	promedio[j] = promedio[j] / ciclosmod[j];
	printf("El promedio de ciclos de reloj de la implementacion HSL_%i es de: %lu \n",j, promedio[j] );

}

//Calculo desvio estandar
for (int j = 0; j<=2; j++){

	for (int i = 0; i<=ciclos-1; i++){

	if (!( (hsl[j][i] < q1[j]-1.5*iqr[j] ) || (hsl[j][i] > q3[j]+1.5*iqr[j] ) ))
		desvio[j] = desvio[j] + ( (hsl[j][i] - promedio[j]) * (hsl[j][i] - promedio[j]) );


	}

	desvio[j] = desvio[j] / ciclosmod[j];
	desvio[j] = sqrt(desvio[j]);
	printf("El desvio estandar correspondiente a la implementacion HSL_%i es de: %lu \n",j, desvio[j] );
}


return 0;

}




