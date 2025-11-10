#!/bin/sh
srcFile="main.s"
objectFile="$srcFile.o"
ca65 $srcFile -o $objectFile

ld65 $objectFile -C linker.cfg -o project.nes
