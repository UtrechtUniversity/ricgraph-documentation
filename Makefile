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
else ifeq ($(shell test -d /var/www/html && echo true),true)
	# E.g. for Ubuntu and Debian.
	webserver_dir := /var/www/html
else
	webserver_dir := [not_set]
endif

# The value of 'build_*_dir' must be the same as 'output_dir'
# in the _quarto-*.yml files, minus the '../'.
source_dir := source_docs_website
# For the documentation.
build_docs_dir := build_documentation
distrib_docs_dir := distrib_documentation
# For the website.
build_website_dir := build_website
distrib_website_dir := distrib_website

# Note that the Ricgraph version number is also used for the website.
ifeq ($(shell test -f $(source_dir)/README.md && echo true),true)
	ricgraph_version := $(shell sed -n 's/.*for version \([0-9.]*\) of Ricgraph.*/\1/p' $(source_dir)/README.md)
else
	ricgraph_version := [not_set]
endif

ricgraph_rep_download := https://github.com/UtrechtUniversity/ricgraph-documentation
# 'ricgraph_dir' should be done differently. It is relative to the directory
# of this Makefile.
ricgraph_dir := ../ricgraph
# The '-{0..5}' is to create multiple filenames when tarring.
ricgraph_docs_file := ricgraph_documentation-v$(ricgraph_version)-{0..3}.tar
distrib_docs_file := $(distrib_docs_dir)/$(ricgraph_docs_file)
ricgraph_docs_path := $(ricgraph_rep_download)/raw/main/$(distrib_docs_file)

ricgraph_website_file := ricgraph_website-v$(ricgraph_version).tar
distrib_website_file := $(distrib_website_dir)/$(ricgraph_website_file)
ricgraph_website_path := $(ricgraph_rep_download)/raw/main/$(distrib_website_file)


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
	@echo "- make get_website: get the website files from Ricgraph."
	@echo "- make build_documentation_website: build the documentation website."
	@echo "- make build_tutorial_pdf: build the documentation pdf with the tutorial."
	@echo "- make build_fulldoc_pdf: build the pdf with the full documentation."
	@echo "- make build_website: build the website."
	@echo "- make create_distrib_documentation: create a tar file to distribute."
	@echo "- 	 the documentation."
	@echo "- make create_distrib_website: create a tar file to distribute the website."
	@echo "- make build_all_documentation: do all the build of docs and"
	@echo "-      create_distrib_documentation of above."
	@echo "- make build_all: do all the build and create distrib files of above."
	@echo "- make install_documentation: install the documentation website."
	@echo "      This should be done on the web server hosting the documentation."
	@echo "      You will need to set command line parameter 'ricgraph_version',"
	@echo "      e.g. 'make ricgraph_version=[version without v] install_documentation'"
	@echo "- make install_website: install the website."
	@echo "      This should be done on the web server hosting the website."
	@echo "      You will need to set command line parameter 'ricgraph_version',"
	@echo "      e.g. 'make ricgraph_version=[version without v] install_website'"
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
	@echo "- ricgraph_rep_download: $(ricgraph_rep_download)"
	@echo "- build_docs_dir: $(build_docs_dir)"
	@echo "- ricgraph_docs_file: $(ricgraph_docs_file)"
	@echo "- ricgraph_docs_path: $(ricgraph_docs_path)"
	@echo "- source_dir: $(source_dir)"
	@echo "- distrib_docs_dir: $(distrib_docs_dir)"
	@echo "- distrib_docs_file: $(distrib_docs_file)"
	@echo "- ricgraph_website_file: $(ricgraph_website_file)"
	@echo "- ricgraph_website_path: $(ricgraph_website_path)"
	@echo "- build_website_dir: $(build_website_dir)"
	@echo "- distrib_website_dir: $(distrib_website_dir)"
	@echo "- distrib_website_file: $(distrib_website_file)"
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

get_website: check_user_notroot
ifeq ($(shell test ! -d $(source_dir)/website && echo true),true)
	@if [ ! -d $(ricgraph_dir) ]; then echo "Error, Ricgraph directory '$(ricgraph_dir)' does not exist."; exit 1; fi
	@echo "Get the website files:"
	cp -r $(ricgraph_dir)/website $(source_dir)
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
	sed -i 's|(\([^#]*\)\.md#\(.*\)|(https://docs.ricgraph.eu/docs/\1.html#\2|g' index.md
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


build_website: get_website check_user_notroot
	rm -rf $(build_website_dir)
	cd $(source_dir); cp _quarto-website.yml website/_quarto.yml
	cd $(source_dir)/website; quarto render


create_distrib_documentation:
ifeq ($(shell test -d $(build_docs_dir) && echo true),true)
	@echo ""
	@echo "Creating distribution file for Ricgraph documentation."
	@echo "It will be called $(distrib_docs_file)."
	@echo "You can set the version using the command line parameter 'ricgraph_version',"
	@echo "e.g. 'make ricgraph_version=[version without v] create_distrib_documentation'"
	@echo ""
	$(call are_you_sure)
	@echo ""
	rm -rf $(distrib_docs_dir); mkdir $(distrib_docs_dir)
	@# --multi-volume in needed since GitHub does not accept files > 100MB.
	tar --multi-volume --tape-length=75M -c --file=$(distrib_docs_file) $(build_docs_dir)
else
	@echo "Error, directory $(build_docs_dir) does not exist."
endif


create_distrib_website:
ifeq ($(shell test -d $(build_website_dir) && echo true),true)
	@echo ""
	@echo "Creating distribution file for Ricgraph website."
	@echo "It will be called $(distrib_website_file)."
	@echo "You can set the version using the command line parameter 'ricgraph_version',"
	@echo "e.g. 'make ricgraph_version=[version without v] create_distrib_website'"
	@echo ""
	$(call are_you_sure)
	@echo ""
	rm -rf $(distrib_website_dir); mkdir $(distrib_website_dir)
	@# --multi-volume in needed since GitHub does not accept files > 100MB.
	tar cf $(distrib_website_file) $(build_website_dir)
else
	@echo "Error, directory $(build_website_dir) does not exist."
endif


build_all_documentation:
	make get_docs
	make build_documentation_website
	make build_tutorial_pdf
	make build_fulldoc_pdf
	make create_distrib_documentation
	@echo ""
	@echo "Building all documentation finished."
	@echo ""


build_all: build_all_documentation
	make build_website
	make create_distrib_website
	@echo ""
	@echo "Building all finished."
	@echo ""


install_documentation: check_user_root
	@echo ""
	@echo "Starting install of Ricgraph documentation from"
	@echo "path '$(ricgraph_docs_path)' to local"
	@echo "local directory '$(webserver_dir)'."
	@echo ""
	@echo "You can set the version using the command line parameter 'ricgraph_version',"
	@echo "e.g. 'make ricgraph_version=[version without v] install_documentation'"
	@echo ""
	$(call are_you_sure)
	@echo ""
	@if [ -d $(webserver_dir)/ricgraph-documentation ]; then rm -rf $(webserver_dir)/ricgraph-documentation-old; mv -f $(webserver_dir)/ricgraph-documentation $(webserver_dir)/ricgraph-documentation-old ; fi
	cd $(webserver_dir); \
	bash -c "wget $(ricgraph_docs_path)"; \
	cd $(webserver_dir); \
	mkdir ricgraph-documentation; \
	cd ricgraph-documentation; \
	bash -c "tar --multi-volume -x --file=../$(ricgraph_docs_file)"; \
	mv $(build_docs_dir)/* .; \
	rmdir $(build_docs_dir); \
	rm ../ricgraph_documentation-*.tar
	chown -R root:root $(webserver_dir)/ricgraph-documentation
	chmod -R go-w $(webserver_dir)/ricgraph-documentation
	@echo "Restarting webserver:"
	systemctl restart apache2


install_website: check_user_root
	@echo ""
	@echo "Starting install of Ricgraph website from"
	@echo "path '$(ricgraph_website_path)' to local"
	@echo "local directory '$(webserver_dir)'."
	@echo ""
	@echo "You can set the version using the command line parameter 'ricgraph_version',"
	@echo "e.g. 'make ricgraph_version=[version without v] install_website'"
	@echo ""
	$(call are_you_sure)
	@echo ""
	@if [ -d $(webserver_dir)/ricgraph-website ]; then rm -rf $(webserver_dir)/ricgraph-website-old; mv -f $(webserver_dir)/ricgraph-website $(webserver_dir)/ricgraph-website-old ; fi
	cd $(webserver_dir); \
	bash -c "wget $(ricgraph_website_path)"; \
	cd $(webserver_dir); \
	mkdir ricgraph-website; \
	cd ricgraph-website; \
	bash -c "tar xf ../$(ricgraph_website_file)"; \
	mv $(build_website_dir)/* .; \
	rmdir $(build_website_dir); \
	rm ../ricgraph_website-*.tar
	chown -R root:root $(webserver_dir)/ricgraph-website
	chmod -R go-w $(webserver_dir)/ricgraph-website
	@echo "Restarting webserver:"
	systemctl restart apache2


veryclean: check_user_notroot
	rm -rf $(source_dir)/docs $(build_docs_dir) $(distrib_docs_dir)
	rm -f $(source_dir)/README.md $(source_dir)/_quarto.yml
	rm -f $(source_dir)/index.*
	rm -rf $(source_dir)/website $(build_website_dir) $(distrib_website_dir)
	rm -f $(source_dir)/website/_quarto.yml


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

