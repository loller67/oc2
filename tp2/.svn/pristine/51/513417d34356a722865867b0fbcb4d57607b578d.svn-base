# ************************************************************************* #
# Organizacion del Computador II                                            #
#                                                                           #
#   Trabajo Practico 2                                                      #
#                                                                           #
# ************************************************************************* #

all: makes tests

CFLAGS=-Wall -Wextra -pedantic -O0 -ggdb -lm -std=c99

makes:
	make -C bmp
	make -C filters

%.o: %.c run.h quicksort.h 
	gcc $(CFLAGS) -c -o $@ $<
	
tests: run.o quicksort.o test_blur.o test_merge.o test_hsl.o makes
	gcc $(CFLAGS) test_blur.o run.o filters/*.o bmp/*.o quicksort.o -o 1_test_blur -lm 
	gcc $(CFLAGS) test_merge.o run.o filters/*.o bmp/*.o quicksort.o -o 2_test_merge -lm
	gcc $(CFLAGS) test_hsl.o run.o filters/*.o bmp/*.o quicksort.o -o 3_test_hsl -lm

clean:
	make -C bmp clean
	make -C filters clean
	rm  -f *.o 1_test_blur 2_test_merge 3_test_hsl