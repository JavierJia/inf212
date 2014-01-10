CC=g++
CFLAGS=-c -g -Wall -Wextra
SOURCES=good-old-time.cpp
OBJECTS=$(SOURCES:.cpp=.o)
EXECUTABLE=oldtime

all: $(SOURCES) $(EXECUTABLE) $(classes)

classes: $(CLASSES:.java=.class)

$(EXECUTABLE): $(OBJECTS) 
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.cpp.o:
	$(CC) $(CFLAGS) $< -o $@

clean: 
	$(RM) $(EXECUTABLE) *.o ./word_freqs 
