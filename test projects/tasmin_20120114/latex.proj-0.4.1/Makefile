# 
# $Id: Makefile 36 2006-10-26 06:21:25Z rgb $
#
#======================================================================
# THIS IS A "GENERIC" MAKEFILE FOR LATEX PROJECTS
#
# make          alone makes only the $(DVI) file, running latex twice
# so that all references and toc's are correct.
#
# make ps       makes $(PS) (and $(DVI) if necessary)
# make pdf      makes $(PDF) (and $(PS) and $(DVI) as necessary)
# make html     makes $(HTML) via latex2html, I hope...
# make clean    deletes all transient build files and output formats.
# make tar      makes $(TAR) from >>all<< the sources
# make gz       makes $(TARGZ) from >>all<< the sources
# make svn      does a svn commit and creates the timestamp $(SVN)
# make sync     does a svn commit and runs syncsvn to list of
#               SVNROOT hosts
# 
#=======================================================================
# We always define the project directory name all by itself as
# one project may have many sources.  This directory name is the name
# of the SVN tree and the base name of any packaging of the project
# in default targets below.
#========================================================================
DIR = latex.proj
SOURCE = project.tex
WEBSITEHOST = login.phy.duke.edu
# Relative to $(HOME) on WEBSITEHOST
WEBDIR = public_html/General
VERSION = 0.4
RELEASE = 1

# The list of includes are things required for the build to work.  Examples

# might be included .tex or .sty files, embedded .eps files, and so forth.
# Naturally, anything on this list should be in the SVN tree.
FIGS = $(shell ls *.fig  2>&1 | sed -e "/\/bin\/ls:/d")
INCLUDE = OPL.tex $(FIGS)

# Source and temporary objects
SOURCES = $(SOURCE) $(INCLUDE) $(FEPS)
LOGS = $(SOURCE:.tex=.log)
TOC = $(SOURCE:.tex=.toc)
AUX = $(SOURCE:.tex=.aux)
ERR = $(SOURCE:.tex=.err)
OUT = $(SOURCE:.tex=.out)
DVI = $(SOURCE:.tex=.dvi)
# Production objects
HTMLDIR = $(SOURCE:.tex=)
PS = $(SOURCE:.tex=.ps)
PDF = $(SOURCE:.tex=.pdf)
A4PS = $(SOURCE:.tex=.a4.ps)
A4PDF = $(SOURCE:.tex=.a4.pdf)
FEPS = $(FIGS:.fig=.eps)
TAR = $(DIR).tar
TGZ = $(DIR)-$(VERSION).$(RELEASE).tgz
ABS = $(DIR).abs
PHP = $(DIR).php
SVN = $(DIR).svn.time

# Build targets (from rules)
all:	$(DVI) $(PDF) $(A4PDF)
ps:	$(DVI) $(PS)
pdf:	$(DVI) $(PS) $(PDF)
a4ps:	$(DVI) $(A4PS)
a4pdf:	$(DVI) $(A4PS) $(A4PDF)
tar:	$(TAR)
$(TGZ): tgz

# Build targets (from commands)
html:	$(SOURCES)
	latex2html -local_icons $(SOURCE)

$(HTMLDIR):
	make html

tar:	$(SOURCES)
	rm -f $(DVI) $(AUX) $(LOG) $(ERR) $(PS) $(PDF)
	rm -f .$(DIR)-$(VERSION).$(RELEASE)
	mkdir -p .$(DIR)-$(VERSION).$(RELEASE)
	cp -a * .$(DIR)-$(VERSION).$(RELEASE)
	mv .$(DIR)-$(VERSION).$(RELEASE) $(DIR)-$(VERSION).$(RELEASE)
	# Exclude any cruft/development directories and SVN stuff.  Add
	# lines as needed.  Note that we exclude ALL tarballs.
	tar -cvpf $(TAR) \
            --exclude=SVN --exclude=CRUFT \
            --exclude=*.tgz \
            --exclude=*.tar \
            ./$(DIR)-$(VERSION).$(RELEASE)
	rm -rf $(DIR)-$(VERSION).$(RELEASE)

#========================================================================
# This is a complicated target, but VERY USEFUL.  It makes a .tgz tarball
# of the exact form preferred for an RPM.  Eventually I'll add a sed script
# that automatically fixes the accompanying rpm spec file to correspond
# right before building the tgz to really automate this, so that I can just
# move the spec to SPEC, move the source tgz to SOURCE and do an
# rpm -ba blah.spec.
#========================================================================
tgz:	$(SOURCES)
	rm -f $(DVI) $(AUX) $(LOG) $(ERR) $(PS) $(PDF)
	rm -f .$(DIR)-$(VERSION).$(RELEASE)
	mkdir -p .$(DIR)-$(VERSION).$(RELEASE)
	cp -a * .$(DIR)-$(VERSION).$(RELEASE)
	mv .$(DIR)-$(VERSION).$(RELEASE) $(DIR)-$(VERSION).$(RELEASE)
	# Exclude any cruft/development directories and SVN stuff.  Add
	# lines as needed.  Note that we exclude ALL tarballs.
	tar -cvpf $(TAR) \
            --exclude=SVN --exclude=CRUFT \
            --exclude=*.tgz \
            --exclude=*.tar \
            ./$(DIR)-$(VERSION).$(RELEASE)
	gzip $(TAR)
	mv $(TAR).gz $(TGZ)
	rm -rf $(DIR)-$(VERSION).$(RELEASE)

#========================================================================
# These targets require a subversion repository to exist.  In my case
# I actually maintain a tree of repositories, one per project by project
# name (so I can update them and rsync them separately).  Rather than
# use only one subversion repo over the network via e.g. ssh, I prefer
# to keep a local copy on my laptop and rsync it to mirrors of the whole
# repo on my household server and the physics department, but of course
# you can do things your own way here by changing the target commands.
#========================================================================
svn:
	cat $(SVN) | \
	sed -e '/^New Checkin/d' >> $(SVN).tmp
	mv $(SVN).tmp $(SVN)
	echo "New Checkin `date`" >> $(SVN)	# Will force a commit and increment revision
	svn commit .		# doesn't sync (yet).

sync:
	cat $(SVN) | \
	sed -e '/^New Checkin/d' >> $(SVN).tmp
	mv $(SVN).tmp $(SVN)
	echo "New Checkin `date`" >> $(SVN)	# Will force a commit and increment revision
	svn commit .		# Do the commit
	rsync -avz /home/rgb/Src/svn-tree/latex.proj login.phy.duke.edu:Src/svn-tree
	rsync -avz /home/rgb/Src/svn-tree/latex.proj 209.42.212.5:Src/svn-tree

# Clean up all the junk build files and output formats to save space.
clean:
	rm -f $(DVI) $(AUX) $(LOGS) $(OUT) $(TOC) $(ERR) $(PS) $(PDF) $(A4PS) $(A4PDF)

#========================================================================
# This install target is for projects offered up on a website, and may
# or may not be useful to you.  I have sundry PHP scripts that autobuild
# what is uploaded into a menu for a project, with its own abstract.
#========================================================================
install: $(HTMLDIR) $(PS) $(PDF) $(A4PS) $(A4PDF) $(ABS) $(PHP) $(TGZ)
	(ssh $(WEBSITEHOST) mkdir -p $(WEBDIR)/$(DIR);\
	rsync -avz $(TGZ) $(WEBSITEHOST):$(WEBDIR)/$(DIR)/;\
	rsync -avz $(HTMLDIR) $(WEBSITEHOST):$(WEBDIR)/$(DIR)/;\
	rsync -avz $(PDF) $(WEBSITEHOST):$(WEBDIR)/$(DIR)/;\
	rsync -avz $(PS) $(WEBSITEHOST):$(WEBDIR)/$(DIR)/;\
	rsync -avz $(A4PDF) $(WEBSITEHOST):$(WEBDIR)/$(DIR)/;\
	rsync -avz $(A4PS) $(WEBSITEHOST):$(WEBDIR)/$(DIR)/;\
	rsync -avz $(ABS) $(WEBSITEHOST):$(WEBDIR)/$(DIR)/;\
	rsync -avz $(PHP) $(WEBSITEHOST):$(WEBDIR)/)

#========================================================================
# Rule for making dvi out of tex.  Do it twice to build table of contents
# and resolve forward references.  Insert other build commands to e.g.
# process bibtex or graphics as needed.
#========================================================================
%.dvi:%.tex $(SOURCES)
	latex $< $@
	latex $< $@

# Rule for making postscript image
%.ps:%.dvi
	dvips -Pamz -Pcmz -o $@ $<

# Rule for making pdf image
%.pdf:%.ps
	ps2pdf $<

# Rule for making postscript image
%.a4.ps:%.dvi
	dvips -Pamz -Pcmz -t A4 -o $@ $<

# Rule for making pdf image
%.a4.pdf:%.a4.ps
	ps2pdf $<

# Rule for making .fig->.eps
%.eps:%.fig
	fig2dev -L eps $< > $@

