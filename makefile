ARCH ?= 64
CFLAGS = -O3 -m$(ARCH)

c5: c5.c c5.h system.c
	$(CC) $(CFLAGS) c5.c system.c -o $@

run: c5
	./c5

clean:
	rm -f c5

test: c5
	./c5 block-200.c5

bin: c5
	cp -u -p c5 ~/bin/
