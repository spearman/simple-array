PACKAGE=simple-array
IPKG=package.ipkg
MODULE=SimpleArray
SOURCES=$(shell find src/ -name "*.idr")

all: build

build: src/$(MODULE).ibc

install: build
	idris --install $(IPKG)

src/$(MODULE).ibc: $(SOURCES)
	idris --build $(IPKG)

repl:
	EDITOR=vim idris --repl $(IPKG)

check: $(SOURCES)
	idris --checkpkg $(IPKG)

test: $(SOURCES)
	idris --testpkg $(IPKG)

doc: $(SOURCES)
	idris --mkdoc $(IPKG)

clean:
	idris --clean $(IPKG)
	rm -rf `find src/ -name *.ibc`
	rm -rf $(PACKAGE)_doc/
