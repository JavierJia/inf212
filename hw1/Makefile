CC=g++
CFLAGS=-c -Wall
SOURCES=good-old-time.cpp
OBJECTS=$(SOURCES:.cpp=.o)
EXECUTABLE=oldtime

all: $(SOURCES) $(EXECUTABLE)
		
$(EXECUTABLE): $(OBJECTS) 
		$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.cpp.o:
		$(CC) $(CFLAGS) $< -o $@

