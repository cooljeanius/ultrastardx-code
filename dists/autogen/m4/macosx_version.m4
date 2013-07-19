dnl# This file is part of UltraStar Deluxe.
dnl# Created by the UltraStar Deluxe Team.

dnl# SYNOPSIS
dnl#
dnl#   AC_MACOSX_VERSION
dnl#
dnl# DESCRIPTION
dnl#
dnl#   Determines the Mac OS X and Darwin version.
dnl#
dnl#   +----------+---------+
dnl#   | Mac OS X |  Darwin |
dnl#   +----------+---------+
dnl#   |     10.4 |       8 |
dnl#   |     10.5 |       9 |
dnl#   |     10.6 |      10 |
dnl#   |     10.7 |      11 |
dnl#   |     10.8 |      12 |
dnl#   +----------+---------+

AC_DEFUN([AC_MACOSX_VERSION],
[
    AC_PATH_PROG([SW_VERS], [sw_vers], [AC_MSG_ERROR([sw_vers is required to check for Mac OS X version.])])
    AC_MSG_CHECKING([for Mac OS X version])
    MACOSX_VERSION=`sw_vers -productVersion`
    AX_EXTRACT_VERSION([MACOSX], [$MACOSX_VERSION])
    AC_MSG_RESULT([@<:@$MACOSX_VERSION@:>@])
    AC_SUBST([MACOSX_VERSION])

    AC_PATH_PROG([UNAME], [uname], [AC_MSG_ERROR([uname is required to check for Darwin version.])])
    AC_MSG_CHECKING([for Darwin version])
    DARWIN_VERSION=`uname -r | cut -f1 -d.`
    AC_MSG_RESULT([@<:@$DARWIN_VERSION@:>@])
    AC_SUBST([DARWIN_VERSION])
])
