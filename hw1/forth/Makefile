JFLAGS = -d .
JC = javac
.SUFFIXES: .java .class
.java.class:
	$(JC) $(JFLAGS) $*.java

CLASSES=Forth.java

default: classes

classes: $(CLASSES:.java=.class)

clean: 
	$(RM) -rf ./forth
