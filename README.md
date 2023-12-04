# Make FAQ

A somewhat [generic Makefile](https://gist.github.com/abzrg/115345cf1f3eaeb4caf49ce8b897b76e)

## Documentation

GNU Make comes with info docs

```sh
info make
info make foreach
info make text functions
```

## VPATH

- https://make.mad-scientist.net/papers/how-not-to-use-vpath/

- (really good explanation on some of the make functions as well)
  https://make.mad-scientist.net/papers/advanced-auto-dependency-generation/

## Implicit/Builtin rules

```sh
make -p
```

tbd

## Implicit variables

also see the output of `make -p`

```
CC                  # gcc, clang
CFLAGS              # -g -Wall -Wextra -std=c11
CXX                 # g++, clang++
CXXFLAGS            # -g -Wall -Wextra -std=c++20
CPPFLAGS            # -I/usr/local/include/ -DNODBUG
LDFLAGS             # -L/usr/local/lib/
LDLIBS              # -lm -ldl -lglfw
...
```

## Debug Makefiles

tbd

How make understood the rules thus far:

```sh
make -d
```

another command:

```
make --trace
```

## Projects with common/nested makefiles

https://stackoverflow.com/questions/54568192/using-makefiles-in-nested-directories

## Autodependency generation

If a target depends on some header files then it would be a bit unwieldy to check
for exactly how many header it might be needing. We need a way to automatically
find out which files should be considered as dependency for a target.

The following command lists all the header files `main.c` depends on.

```sh
gcc -M main.c
```

---

g++ (or gcc in general) cooperates with make using -M. -M implies -E, which
causes compilation to stop after the preprocessor stage. -M causes the C
preprocessor to output a dependency rule suitable for make, instead of outputting
preprocessed C source. You do this in a separate invocation of gcc with all the
-I and -D args you would give to the main compile, but with -M also.

-MP and -MT are variants of the basic -M option. For understanding what happens,
you want to get to grips with -M first.



For a good explanation of how to use -M, at the command line type:-

```
info make Rules Auto
```

I suggest you try building a Makefile following the instructions to generate the
.d makefiles. Experiment with -M or -MM, then maybe -MP. See if you can find a
use for -MT. As always, post any further questions

[ref](https://www.experts-exchange.com/questions/22109046/How-to-understand-the-M-MT-MP-options-of-g.html)

---

Docs:

- [Preprocessor Options](https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html)
- `info make Rules Auto`

Readings:

- https://make.mad-scientist.net/papers/advanced-auto-dependency-generation/
    - https://stackoverflow.com/questions/8025766/makefile-auto-dependency-generation
- https://stackoverflow.com/questions/41530474/makefile-dependencies-what-should-be-a-dependency
- \* https://stackoverflow.com/questions/2394609/makefile-header-dependencies


## OS Detecting

```make
UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
# do something Linux-y
endif
ifeq ($(UNAME), Solaris)
# do something Solaris-y
endif
```

or

```make
ifeq ($(OS),Windows_NT)
    CCFLAGS += -D WIN32
    ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
        CCFLAGS += -D AMD64
    else
        ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
            CCFLAGS += -D AMD64
        endif
        ifeq ($(PROCESSOR_ARCHITECTURE),x86)
            CCFLAGS += -D IA32
        endif
    endif
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        CCFLAGS += -D LINUX
    endif
    ifeq ($(UNAME_S),Darwin)
        CCFLAGS += -D OSX
    endif
    UNAME_P := $(shell uname -p)
    ifeq ($(UNAME_P),x86_64)
        CCFLAGS += -D AMD64
    endif
    ifneq ($(filter %86,$(UNAME_P)),)
        CCFLAGS += -D IA32
    endif
    ifneq ($(filter arm%,$(UNAME_P)),)
        CCFLAGS += -D ARM
    endif
endif
```

[ref](https://stackoverflow.com/questions/714100/os-detecting-makefile)

---

## Automatic Variables

List of automatic variables:

- `$@`: current target
- `$<`: first prerequisite
- `$^`: all prerequisite
- `$?`: prerequisites that have changed
- `$|`: order-only prerequisite
- `$*`: the content of matched pattern % (tbd)
- `$+`: (tbd)

Docs:

- [tbd]()

## Built-in Functions

List:

- Text functions
- Filename functions
- Conditional functions
- Value functions
- Shell functions
- Control functions

Examples:

```make
$(SRCS:.c=.o)
$(addprefix build/,$(OBJS))
$(if ..) $(or ..) $(and ..)
$(foreach var,list,text)
$(value (VARIABLE))
$(shell ..)
$(error ..)
$(warning ..)
$(info ..)
```

## Assignment Operators

- `=`: Verbatim assignment (some problem with recursive assignment)
- `:=`: Simple expansion
- `!=`: Shell output
- `?=`: Conditional assignment
- `+=`: Append to

Examples:

```make
SRCS = main.c
SRCS := $(wildcard *.c)
SRCS != find . -name '*.c'
SRCS := $(shell find . -name '*.c')
CC_FLAGS += Wextra
CFLAGS ?= $(CC_FLAGS)
FOO :=$(BAR) # Comment
```



## Resources

Blogs/Docs:

- [Rules of Makefiles](https://make.mad-scientist.net/papers/rules-of-makefiles/)
- [makefile for c opengl with glfw and glad](https://codereview.stackexchange.com/questions/78855/makefile-for-c-opengl-with-glfw-and-glad)

Videos:

- [Makefiles, but in English](https://youtu.be/FfG-QqRK4cY)
- [Advanced makefile](https://www.youtube.com/watch?v=Pect1FUKhvk)
- [Makefile variables are complicated - makefile assignment tutorial](https://www.youtube.com/watch?v=z4uPHjxYyPs)
