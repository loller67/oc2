#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "run.h"
#include "bmp/bmp.h"
#include "filters/filters.h"
#include "rdtsc.h"
#include "quicksort.h"

/*
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/hardirq.h>
#include <linux/preempt.h>
#include <linux/sched.h>
*/
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

unsigned long blur[3][ciclos];

char* src = "img/lena.bmp";
char* dst = "img/lenapruebaBLUR.bmp";

//unsigned long flags;

for (int j = 0; j<=2; j++){

	for (int i = 0; i<=ciclos-1; i++){

	// TESTEO BLUR

		/*
		preempt_disable();
		raw_local_irq_save(flags);
		*/

		RDTSC_START(start);

		// ... codigo ...

		run_blur(j, src ,dst);

		// ... codigo ...

		RDTSC_STOP(end);

		/*
		raw_local_irq_restore(flags);
		preempt_enable();
		*/

		delta = end - start;
		blur[j][i] = delta;
		promedio[j] = promedio[j] + delta;
		
	}

	//Ordeno el array
	quicksort(blur[j], 0, ciclos-1);

	//Calculo cuartiles para filtrar
	q1[j] = blur[j][(ciclos+1)/4];
	q3[j] = blur[j][3*(ciclos+1)/4];
	iqr[j] = q3[j] - q1[j];

	//Filtro outliers

	for (int i = 0; i<=ciclos-1; i++){
		if ( (blur[j][i] < q1[j]-1.5*iqr[j] ) || (blur[j][i] > q3[j]+1.5*iqr[j] ) ){
			promedio[j] = promedio[j] - blur[j][i];
			ciclosmod[j] = ciclosmod[j] - 1;
		}
	}

	promedio[j] = promedio[j] / ciclosmod[j];
	printf("El promedio de ciclos de reloj de la implementacion BLUR_%i es de: %lu \n",j, promedio[j] );

}

//Calculo desvio estandar
for (int j = 0; j<=2; j++){

	for (int i = 0; i<=ciclos-1; i++){

		if (!( (blur[j][i] < q1[j]-1.5*iqr[j] ) || (blur[j][i] > q3[j]+1.5*iqr[j] ) ))
		desvio[j] = desvio[j] + ( (blur[j][i] - promedio[j]) * (blur[j][i] - promedio[j]) );

	}

	desvio[j] = desvio[j] / ciclosmod[j];
	desvio[j] = sqrt(desvio[j]);
	printf("El desvio estandar correspondiente a la implementacion BLUR_%i es de: %lu \n",j, desvio[j] );
}

return 0;

}

