# Paths Variables
SHELL = /bin/sh
PREFIX = /usr/local
BIN_PREFIX = $(PREFIX)/bin

INFO_DIR = $(shell git --info-path)
HTML_DIR = $(shell git --html-path)
MAN_DIR = $(shell git --man-path)

BASH_COMPL_DIR = /usr/local/etc/bash_completion/completions
FISH_COMPL_DIR = /usr/share/fish/completions
ZSH_COMPL_DIR = /usr/local/share/zsh/site-functions

LOCAL_BIN_DIR = bin
LOCAL_COMPL_DIR = completion
LOCAL_MAN_DIR = man
LOCAL_SRC_DIR = src

GITMOVE_VERSION = $(shell . src/version.sh && echo $${GITMOVE_VERSION})

# Commands Variables
RM = rm --force
RM_DIR = $(RM) --recursive

PANDOC = pandoc
INSTALL = install
INSTALL_BIN = $(INSTALL) --mode=0755
INSTALL_DIR = $(INSTALL) --directory --mode=0755
INSTALL_MAN = $(INSTALL) --mode=0644

ASCIIDOC = asciidoc
ASCIIDOC_HTML = xhtml11
ASCIIDOC_DOCBOOK = docbook
ASCIIDOC_MAN = manpage
ASCIIDOC_CONF = --conf-file=man/asciidoc.conf
ASCIIDOC_COMMON = $(ASCIIDOC) $(ASCIIDOC_CONF) \
		--attribute=manmanual='Git Move' \
		--attribute=mansource='Yokozuna59' \
		--attribute=manversion=$(GITMOVE_VERSION)
TO_HTML = $(ASCIIDOC_COMMON) --doctype=$(ASCIIDOC_MAN) --backend=$(ASCIIDOC_HTML)
TO_XML = $(ASCIIDOC_COMMON) --doctype=$(ASCIIDOC_MAN) --backend=$(ASCIIDOC_DOCBOOK)

XMLTO = xmlto

# Commands
.PHONY: all
all: build

.PHONY: build build-bin build-doc build-info build-html build-man
build: build-bin build-doc

build-bin:
	cat src/version.sh > $(LOCAL_BIN_DIR)/git-move
	find $(LOCAL_SRC_DIR) -maxdepth 1 -iname "*.sh" -not -name "version.sh" \
		-exec sh -c "cat {} >> $(LOCAL_BIN_DIR)/git-move" \;
	chmod +x $(LOCAL_BIN_DIR)/git-move
	sed -i -e '1!{/^#!/d;}' -e '/^set -e/,+1d' -e '/main "$$@"/,+1d' $(LOCAL_BIN_DIR)/git-move
	sed -i -e '/^#!/a set -euo pipefail' $(LOCAL_BIN_DIR)/git-move
	echo 'main "$$@"' >> $(LOCAL_BIN_DIR)/git-move
	sync

build-doc: build-info build-html build-man
build-info:
	@echo git-move.info is not currently supported!
build-html:
	$(TO_HTML) $(LOCAL_MAN_DIR)/git-mv.rst
build-man:
	$(TO_XML) $(LOCAL_MAN_DIR)/git-mv.rst
	$(XMLTO) man $(LOCAL_MAN_DIR)/git-mv.xml -o $(LOCAL_MAN_DIR)


.PHONY: clean clean-bin clean-doc clean-info clean-html clean-man
clean: clean-bin clean-doc

clean-bin:
	$(RM) $(LOCAL_BIN_DIR)/git-move

clean-doc: clean-info clean-html clean-man
clean-info:
	$(RM) $(wildcard $(LOCAL_MAN_DIR)/*.info)
clean-html:
	$(RM) $(wildcard $(LOCAL_MAN_DIR)/*.html)
clean-man:
	$(RM) $(wildcard $(LOCAL_MAN_DIR)/*.1 $(LOCAL_MAN_DIR)/*.xml)


.PHONY: install install-bin install-doc install-info install-html install-man \
	install-completion install-bash install-fish install-zsh
install: install-bin install-doc install-completion

install-bin: build-bin
	$(INSTALL_DIR) $(BIN_PREFIX)
	$(INSTALL_BIN) $(LOCAL_BIN_DIR)/git-move $(BIN_PREFIX)

install-doc: build-doc install-info install-man install-html
install-info: build-info
	$(INSTALL_DIR) $(INFO_DIR)
	$(INSTALL_MAN) $(wildcard $(LOCAL_MAN_DIR)/*.info) $(INFO_DIR)
install-html: build-html
	$(INSTALL_DIR) $(HTML_DIR)
	$(INSTALL_MAN) $(wildcard $(LOCAL_MAN_DIR)/*.html) $(HTML_DIR)
install-man: build-man
	$(INSTALL_DIR) $(MAN_DIR)
	$(INSTALL_MAN) $(wildcard $(LOCAL_MAN_DIR)/*.1) $(MAN_DIR)

install-completion: install-bash install-fish install-zsh
install-bash:
	$(INSTALL_DIR) $(ZSH_COMPL_DIR)
	$(INSTALL_MAN) $(LOCAL_COMPL_DIR)/git-move.bash $(BASH_COMPL_DIR)
install-fish:
	$(INSTALL_DIR) $(ZSH_COMPL_DIR)
	$(INSTALL_MAN) $(LOCAL_COMPL_DIR)/git-move.fish $(FISH_COMPL_DIR)
install-zsh:
	$(INSTALL_DIR) $(ZSH_COMPL_DIR)
	$(INSTALL_MAN) $(LOCAL_COMPL_DIR)/git-move.zsh $(ZSH_COMPL_DIR)


.PHONY: uninstall uninstall-bin uninstall-doc uninstall-info uninstall-html \
	uninstall-man uninstall-completion uninstall-bash uninstall-fish \
	uninstall-zsh
uninstall: uninstall-bin uninstall-doc uninstall-completion

uninstall-bin:
	$(RM) $(BIN_PREFIX)/git-move

uninstall-doc: uninstall-info uninstall-html uninstall-man
uninstall-info:
	$(RM) $(addprefix $(INFO_DIR)/, \
		$(notdir $(wildcard $(LOCAL_MAN_DIR)/*.info)))
uninstall-html:
	$(RM) $(addprefix $(MAN_DIR)/, \
		$(notdir $(wildcard $(LOCAL_MAN_DIR)/*.html)))
uninstall-man:
	$(RM) $(addprefix $(HTML_DIR)/, \
		$(notdir $(wildcard $(LOCAL_MAN_DIR)/*.1)))

uninstall-completion: uninstall-bash uninstall-fish uninstall-zsh
uninstall-bash:
	$(RM) $(BASH_COMPL_DIR)/$(LOCAL_COMPL_DIR)/git-move.bash
uninstall-fish:
	$(RM) $(FISH_COMPL_DIR)/$(LOCAL_COMPL_DIR)/git-move.fish
uninstall-zsh:
	$(RM) $(ZSH_COMPL_DIR)/$(LOCAL_COMPL_DIR)/git-move.zsh


.PHONY: test
test: clean build

lint:
lint-doc:
lint-shell:
