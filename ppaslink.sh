#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
OFS=$IFS
IFS="
"
/Library/Developer/CommandLineTools/usr/bin/ld     -z noexecstack    -x   -multiply_defined suppress -L. -o conftest `cat link11700.res` -filelist linkfiles11700.res
if [ $? != 0 ]; then DoExitLink ; fi
IFS=$OFS
