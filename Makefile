# Copyright (c) 2013-2014 Galois, Inc.
# Distributed under the terms of the GPLv3 license (see LICENSE file)
#
# Author: Brent Carmer

HELIB=HElib
NTL=ntl-6.2.1
CC=clang++
CFLAGS=-std=c++11 -Ideps/$(HELIB)/src -Ideps/$(NTL)/include -g --static -Wall -O3
LFLAGS=

DEPS = deps/$(HELIB)/src/fhe.a deps/$(NTL)/src/ntl.a

HEADS = helib-instance.h helib-stub.h simon-plaintext.h simon-util.h
OBJ   = helib-instance.o helib-stub.o simon-plaintext.o simon-util.o 

all: aes multest simon-simd simon-blocks simon-plaintext

aes: aes.cpp $(OBJ)
	$(CC) $(CFLAGS) aes.cpp $(DEPS) -o aes $(LFLAGS) $(OBJ)

simon-plaintext: simon-plaintext-test.cpp $(OBJ)
	$(CC) $(CFLAGS) simon-plaintext-test.cpp $(OBJ) $(DEPS) -o simon-plaintext $(LFLAGS)

simon-blocks: simon-blocks.cpp $(OBJ)
	$(CC) $(CFLAGS) simon-blocks.cpp $(OBJ) $(DEPS) -o simon-blocks $(LFLAGS)

simon-simd: simon-simd.cpp $(OBJ)
	$(CC) $(CFLAGS) simon-simd.cpp $(OBJ) $(DEPS) -o simon-simd $(LFLAGS)

%.o: %.cpp $(HEADS)
	$(CC) $(CFLAGS) -c $<

multest: multest.cpp $(OBJ)
	$(CC) $(CFLAGS) multest.cpp $(DEPS) -o multest $(LFLAGS) $(OBJ)

deps: ntl helib

helib:
	mkdir -p deps
	[[ -d deps/$(HELIB) ]] || git clone https://github.com/shaih/HElib.git deps/$(HELIB)
	cp helib-makefile deps/$(HELIB)/src/Makefile
	cd deps/$(HELIB)/src; make

ntl:
	mkdir -p deps
	[[ -d deps/$(NTL) ]] || \
		cd deps && \
		wget http://www.shoup.net/ntl/$(NTL).tar.gz -O $(NTL).tgz && \
		tar xzf $(NTL).tgz && \
		rm -f $(NTL).tgz && \
		cd $(NTL)/include/NTL && \
		patch < ../../../../ntl.vector.h.patch;
	cd deps/$(NTL)/src; ./configure WIZARD=off; make

clean:
	rm -f aes
	rm -f multest
	rm -f simon-simd
	rm -f simon-blocks
	rm -f simon-plaintext
	rm *.o
