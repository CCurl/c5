app := c5
app32 := c5-32

CXX := clang
CXXFLAGS := -m64 -O3
C32FLAGS := -m32 -O3

srcfiles := $(shell find . -name "*.cpp")
incfiles := $(shell find . -name "*.h")
LDLIBS   := -lm

all: $(app)

$(app): $(srcfiles) $(incfiles)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $(app) $(srcfiles) $(LDLIBS)
	ls -l $(app)

$(app32): $(srcfiles) $(incfiles)
	$(CXX) $(C32FLAGS) $(LDFLAGS) -o $(app32) $(srcfiles) $(LDLIBS)
	ls -l $(app32)

clean:
	rm -f $(app) $(app32)

test: $(app)
	./$(app) block-200.c5

run: $(app)
	./$(app)

run32: $(app32)
	./$(app32)

bin: $(app)
	cp -u -p $(app) ~/bin/
