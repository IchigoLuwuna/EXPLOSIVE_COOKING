#!/bin/sh
for srcFile in *.s; do
	objectFile="$srcFile.o"
	ca65 $srcFile -o $objectFile
done

ld65 *.o -C linker.cfg -o project.nes
