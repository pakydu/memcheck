#!/bin/sh
aclocal -I ./
autoheader
automake -a
autoconf
