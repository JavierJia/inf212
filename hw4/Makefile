JFLAGS = -d .
JC = javac
.SUFFIXES: .java .class
.java.class:
	$(JC) $(JFLAGS) $*.java

CLASSES=*.java

default: classes

classes: $(CLASSES:.java=.class)

clean: 
	$(RM) -rf ./ADT
