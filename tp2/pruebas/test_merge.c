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

unsigned long merge[3][ciclos];

char* src1 = "img/lena.bmp";
char* src2 = "img/colores.bmp";
char* dst = "img/lenaprueba.bmp";
float value = 0.5;


for (int j = 0; j<=2; j++){

	for (int i = 0; i<=ciclos-1; i++){

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

	//Ordeno el array
	quicksort(merge[j], 0, ciclos-1);

	//Calculo cuartiles para filtrar
	q1[j] = merge[j][(ciclos+1)/4];
	q3[j] = merge[j][3*(ciclos+1)/4];
	iqr[j] = q3[j] - q1[j];

	//Filtro outliers

	for (int i = 0; i<=ciclos-1; i++){
		if ( (merge[j][i] < q1[j]-1.5*iqr[j] ) || (merge[j][i] > q3[j]+1.5*iqr[j] ) ){
			promedio[j] = promedio[j] - merge[j][i];
			ciclosmod[j] = ciclosmod[j] - 1;
		}
	}


	promedio[j] = promedio[j] / ciclosmod[j];
	printf("El promedio de ciclos de reloj de la implementacion MERGE_%i es de: %lu \n",j, promedio[j] );

}

//Calculo desvio estandar
for (int j = 0; j<=2; j++){

	for (int i = 0; i<=ciclos-1; i++){

		if (!( (merge[j][i] < q1[j]-1.5*iqr[j] ) || (merge[j][i] > q3[j]+1.5*iqr[j] ) ))
		desvio[j] = desvio[j] + ( (merge[j][i] - promedio[j]) * (merge[j][i] - promedio[j]) );

	}

	desvio[j] = desvio[j] / ciclosmod[j];
	desvio[j] = sqrt(desvio[j]);
	printf("El desvio estandar correspondiente a la implementacion MERGE_%i es de: %lu \n",j, desvio[j] );
}


return 0;

}

