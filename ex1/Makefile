CC=gcc
CFLAGS=-Wall


all: sender listener

sender: sender.c
	$(CC) sender.c -o sender $(CFLAGS)

listener: listener.c
	$(CC) listener.c -o listener $(CFLAGS)


.PHONY: clean
clean:
	rm sender listener
