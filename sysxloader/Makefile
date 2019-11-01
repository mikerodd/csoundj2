default: juno2snaps

juno2snaps.o: juno2snaps.c 
	gcc -ansi -c juno2snaps.c -o juno2snaps.o



juno2snaps: juno2snaps.o
	gcc juno2snaps.o -o juno2snaps

clean:
	-rm -f juno2snaps.o
	-rm -f juno2snaps
