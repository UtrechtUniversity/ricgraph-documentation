# ########################################################################
#
# Documentation Ricgraph - Research in context graph
#
# ########################################################################
#
# MIT License
# Copyright (c) 2025 Rik D.T. Janssen
#
# ########################################################################
#
# This file is the Makefile for Ricgraph documentation.
# For make, see https://www.gnu.org/software/make.
#
# Original version Rik D.T. Janssen, February 2025.
#
# ########################################################################


# Determine where the webserver files live.
ifeq ($(shell test -d /srv/www/htdocs && echo true),true)
	# E.g. for OpenSUSE Leap & Tumbleweed.
	webserver_dir := /srv/www/htdocs
else ifeq ($(shell test -d /var/www/htdocs && echo true),true)
	# E.g. for Ubuntu and Debian.
	webserver_dir := /var/www/htdocs
else
	webserver_dir := [not_set]
endif

# The value of 'build_dir' should be the same as 'output_dir' 
# in the _quarto-*.yml files, minus the '../'.
build_dir := build_documentation
source_dir := source_documentation
distrib_dir := distrib_documentation

ifeq ($(shell test -f $(source_dir)/README.md && echo true),true)
	ricgraph_version := $(shell sed -n 's/.*for version \([0-9.]*\) of Ricgraph.*/\1/p' $(source_dir)/README.md)
else
	ricgraph_version := [not_set]
endif

# 'ricgraph_dir' should be done differently. It is relative to the directory
# of this Makefile.
ricgraph_dir := ../ricgraph
# The '-{0..5}' is to create multiple filenames when tarring.
ricgraph_doc_file := ricgraph_documentation-v$(ricgraph_version)-{0..5}.tar
ricgraph_doc_download := https://github.com/UtrechtUniversity/ricgraph-documentation
distrib_file := $(distrib_dir)/$(ricgraph_doc_file)
ricgraph_doc_path := $(ricgraph_doc_download)/tree/main/$(distrib_file)


# ########################################################################
# General targets.
# ########################################################################
help:
	@echo ""
	@echo "You can use this Makefile generate and install"
	@echo "the documentation for Ricgraph."
	@echo ""
	@echo "- make: Displays a short help message."
	@echo "- make help: Displays a short help message."
	@echo "- make get_docs: get the doc files from Ricgraph."
	@echo "- make build_documentation_website: build the documentation website."
	@echo "- make build_tutorial_pdf: build the documentation pdf with the tutorial."
	@echo "- make build_fulldoc_pdf: build the pdf with the full documentation."
	@echo "- make create_distrib: create a tar file to distribute the documentation."
	@echo "- make build_all: do all the build and create_distrib of above."
	@echo "- make install_documentation_website: install the documentation website."
	@echo "      This should be done on the web server hosting the documentation."
	@echo "      You will need to set command line parameter 'ricgraph_version',"
	@echo "      e.g. 'make ricgraph_version=[version without v] install_documentation_website'"
	@echo "- make veryclean: remove all generated files."
	@echo "- make makefile_variables: list all variables used in this Makefile."
	@echo ""


all:
	@echo ""
	@echo "You have typed 'make all'."
	@echo "With the Ricgraph Makefile, this will not install anything."
	@echo "To learn about valid Makefile options (targets), type 'make help'."
	@echo ""


makefile_variables:
	@echo ""
	@echo "This is a list of the internal variables in this Makefile:"
	@echo "- webserver_dir: $(webserver_dir)"
	@echo "- ricgraph_dir: $(ricgraph_dir)"
	@echo "- ricgraph_version: $(ricgraph_version)"
	@echo "- ricgraph_doc_file: $(ricgraph_doc_file)"
	@echo "- ricgraph_doc_download: $(ricgraph_doc_download)"
	@echo "- ricgraph_doc_path: $(ricgraph_doc_path)"
	@echo "- source_dir: $(source_dir)"
	@echo "- build_dir: $(build_dir)"
	@echo "- distrib_dir: $(distrib_dir)"
	@echo "- distrib_file: $(distrib_file)"
	@echo ""


# ########################################################################
# Ricgraph targets.
# ########################################################################

get_docs: check_user_notroot
ifeq ($(shell test ! -d $(source_dir)/docs && echo true),true)
	@if [ ! -d $(ricgraph_dir) ]; then echo "Error, Ricgraph directory '$(ricgraph_dir)' does not exist."; exit 1; fi
	@echo "Get the documentation files:"
	cp -r $(ricgraph_dir)/docs $(source_dir) 
	cp $(ricgraph_dir)/README.md $(source_dir)
	@echo "Remove the badges from the README.md file."
	@sed -i '/^\[!\[/d' $(source_dir)/README.md
	@sed -i '/^!\[/d' $(source_dir)/README.md
	@echo "Remove the logo from the README.md file."
	@sed -i '/^<img alt="Ricgraph logo"/d' $(source_dir)/README.md
endif


build_documentation_website: get_docs check_user_notroot
	cd $(source_dir); cp _quarto-documentation-website.yml _quarto.yml
	@cd $(source_dir); sed -i "s/#XX.YY#/${ricgraph_version}/" _quarto.yml
	cd $(source_dir); quarto render


# [25-2-2025] we cannot put 'getdocs' in the dependencies of this target.
# Getting files must be done separately, otherwise Quarto
# reports a missing '$'. I think is is a bug in Quarto.
build_tutorial_pdf: check_user_notroot
	@if [ ! -d $(source_dir)/docs ]; then echo "Error, docs-dir does not exist, run 'make get_docs' first."; exit 1; fi
	cd $(source_dir); cp _quarto-tutorial.yml _quarto.yml
	@cd $(source_dir); sed -i "s/#XX.YY#/${ricgraph_version}/" _quarto.yml
	cd $(source_dir); cp docs/ricgraph_tutorial.md index.md
	@cd $(source_dir); \
	sed -i 's|(images/|(docs/images/|g' index.md; \
	sed -i 's|(\([^#]*\)\.md#\(.*\)|(https://documentation.ricgraph.eu/docs/\1.html#\2|g' index.md
	cd $(source_dir); quarto render --output ricgraph_tutorial.pdf


# [25-2-2025] we cannot put 'getdocs' in the dependencies of this target.
# Getting files must be done separately, otherwise Quarto
# reports a missing '$'. I think is is a bug in Quarto.
build_fulldoc_pdf: check_user_notroot
	@if [ ! -d $(source_dir)/docs ]; then echo "Error, docs-dir does not exist, run 'make get_docs' first."; exit 1; fi
	cd $(source_dir); cp _quarto-fulldocumentation.yml _quarto.yml
	@cd $(source_dir); sed -i "s/#XX.YY#/${ricgraph_version}/" _quarto.yml
	cd $(source_dir); cp docs/ricgraph_tutorial.md index.md
	@cd $(source_dir); \
	sed -i 's|(ricgraph_|(docs/ricgraph_|g' index.md; \
	sed -i 's|(images/|(docs/images/|g' index.md; \
	echo "" >> index.md; \
	echo "<!-- Produce table of contents. To be able to use" >> index.md; \
	echo "LaTeX, you need 'raw_tex: true' in _quarto.yml. -->" >> index.md;\
	echo '\setcounter{tocdepth}{1}' >> index.md; \
	echo '\tableofcontents' >> index.md; \
	echo "" >> index.md; \
	echo '\part*{Full documentation Ricgraph}' >> index.md; \
	echo "" >> index.md
	cd $(source_dir); quarto render --output ricgraph_fulldocumentation.pdf


create_distrib:
ifeq ($(shell test -d $(build_dir) && echo true),true)
	rm -fr $(distrib_dir); mkdir $(distrib_dir)
	@# --multi-volume in needed since GitHub does not accept files > 100MB.
	tar --multi-volume --tape-length=75M -c --file=$(distrib_file) $(build_dir)
else
	@echo "Error, directory $(build_dir) does not exist."
endif


build_all: 
	make get_docs
	make build_documentation_website
	make build_tutorial_pdf
	make build_fulldoc_pdf
	make create_distrib
	@echo ""
	@echo "Building all finished."
	@echo ""


install_documentation_website: check_user_root
	@echo ""
	@echo "Starting install of Ricgraph documentation from"
	@echo "path '$(ricgraph_doc_path)' to local"
	@echo "local directory '$(webserver_dir)'."
	@echo ""
	@echo "You can set the version using the command line parameter 'ricgraph_version',"
	@echo "e.g. 'make ricgraph_version=[version without v] install_documentation_website'"
	@echo ""
	$(call are_you_sure)
	@echo ""
	@if [ -d $(webserver_dir)/ricgraph-documentation ]; then mv -f $(webserver_dir)/ricgraph-documentation $(webserver_dir)/ricgraph-documentation-old ; fi
	cd $(webserver_dir); \
	wget $(ricgraph_doc_path); \
	@#if [ ! -f $(ricgraph_doc_file) ]; then echo "Error, something went wrong downloading file '$(ricgraph_doc_file)'."; exit 1; fi
	cd $(webserver_dir); \
	mkdir ricgraph-documentation; \
	cd ricgraph-documentation; \
	tar --multi-volume -x --file=../$(ricgraph_doc_file); \
	mv $(build_dir)/* .; \
	rmdir $(build_dir)
	chown -R root:root $(webserver_dir)/ricgraph-documentation
	chmod -R go-w $(webserver_dir)/ricgraph-documentation
	@echo "Restarting webserver:"
	systemctl restart apache2


veryclean: check_user_notroot
	rm -rf $(source_dir)/docs $(build_dir) $(distrib_dir)
	rm -f $(source_dir)/README.md $(source_dir)/_quarto.yml
	rm -f $(source_dir)/index.*


check_user_root:
	@if [ $(shell id -u) != 0 ]; then echo "Error: You need to be root. Please execute 'sudo bash' and then rerun the 'make' command you started with."; exit 1; fi


check_user_notroot:
	@if [ $(shell id -u) = 0 ]; then echo "Error: You need to be a regular user. Please make sure you are and then rerun the 'make' command you started with."; exit 1; fi


define are_you_sure
	@if echo -n "Are you sure you want to proceed? [y/n] " && read ans && ! [ $${ans:-N} = y ]; then \
		echo "Make stopped."; \
		exit 1; \
	fi
endef

