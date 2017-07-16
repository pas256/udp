CC=gcc
CFLAGS=-Wall


all: client server

client: client.c
	$(CC) client.c -o client $(CFLAGS)

server: server.c
	$(CC) server.c -o server $(CFLAGS)


.PHONY: clean
clean:
	rm client server
