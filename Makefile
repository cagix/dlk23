## Run 'make book' or 'make slides' to build the faq material.
##
## (a) You can use the toolchain installed in the Docker image "pandoc-lecture",
##     which comes ready to use (no other dependencies).
## (b) Alternatively, you need to
##         (1) install all tools (Pandoc, Hugo, TexLive) manually to your
##             operating system, and
##         (2) clone the pandoc-lecture repo plus relearn theme locally to a
##             specific location (${HOME}/.local/share/pandoc/):
##             "git clone --depth 1 https://github.com/cagix/pandoc-lecture.git ${HOME}/.local/share/pandoc/"
##             "wget https://github.com/McShelby/hugo-theme-relearn/archive/refs/tags/${RELEARN}.tar.gz"
##             "tar -zxf ${RELEARN}.tar.gz --strip-components 1 -C ${HOME}/.local/share/pandoc/hugo/hugo-theme-relearn/"
##             (Alternatively, just use "make install_scripts_locally" using https://github.com/cagix/pandoc-lecture/)
##
## To build the mentioned Docker image or for the required packages for a native
## installation, see https://github.com/cagix/pandoc-lecture/docker.
##
## If you want to use the Docker image to build the faq material, start the
## container interactively using "make runlocal" and run the desired Make targets
## in the interactive container shell.


#--------------------------------------------------------------------------------
# Tools
#--------------------------------------------------------------------------------
PANDOC           = pandoc

## Where do we find the content from https://github.com/cagix/pandoc-lecture,
## i.e. the resources for Pandoc and the themes for Hugo?
##     (a) If we run inside the Docker container or inside the GitHub action,
##         we find the files in ${XDG_DATA_HOME}/pandoc/.
##     (b) If we are running locally (native installation), we look for the
##         files at ${HOME}/.local/share/pandoc/.
## XDG_DATA_HOME can be set externally
XDG_DATA_HOME   ?= $(HOME)/.local/share
PANDOC_DIRS      = --resource-path=".:$(XDG_DATA_HOME)/pandoc/:$(XDG_DATA_HOME)/pandoc/resources/"

## Define options to be used by Pandoc
PANDOC_ARGS      = $(PANDOC_DIRS)


#--------------------------------------------------------------------------------
# Source and target files for book and slides
#--------------------------------------------------------------------------------
MARKDOWN_SOURCES = peer-feedback.md
OUTPUT_DIR       = docs

SLIDES_TARGET    = $(MARKDOWN_SOURCES:%.md=$(OUTPUT_DIR)/%.pdf)
PPTX_Target      = $(MARKDOWN_SOURCES:%.md=$(OUTPUT_DIR)/%.pptx)


#--------------------------------------------------------------------------------
# Main targets
#--------------------------------------------------------------------------------
.DEFAULT_GOAL:=help

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: runlocal
runlocal: ## Start Docker container "pandoc-lecture" into interactive shell
	docker run  --rm -it  -v "$(shell pwd):/pandoc" -w "/pandoc"  -u "$(shell id -u):$(shell id -g)"  --entrypoint "bash"  pandoc-lecture


.PHONY: all
all: slides pptx ## Make everything

.PHONY: slides
slides: $(OUTPUT_DIR) $(SLIDES_TARGET) ## Create LaTeX/Beamer slides

.PHONY: pptx
pptx: $(OUTPUT_DIR) $(PPTX_Target) ## Create PowerPoint slides


.PHONY: clean
clean: ## Clean up intermediate files

.PHONY: distclean
distclean: clean ## Clean up intermediate files and generated artifacts
	rm -rf $(SLIDES_TARGET) $(PPTX_Target) $(OUTPUT_DIR)


#--------------------------------------------------------------------------------
# Internal targets
#--------------------------------------------------------------------------------
$(OUTPUT_DIR):
	mkdir -p $@

$(SLIDES_TARGET): $(OUTPUT_DIR)/%.pdf: %.md
	$(PANDOC) $(PANDOC_ARGS) -d beamer $< -o $@

$(PPTX_Target): $(OUTPUT_DIR)/%.pptx: %.md
	$(PANDOC) $(PANDOC_ARGS) $< -o $@
