#!/bin/sh

# makePDFimage.sh
# TeXnicle
#
# Created by Martin Hewitson on 1/2/10.
# Copyright 2010 bobsoft. All rights reserved.


if [ $# -lt 5 ]
then
        echo "usage: makePDFimage.sh <tmpdir> <in.tex> <cropped.pdf> <texpath> <gspath>"
  exit
fi

tmpdir=$1
texin=$2
pdfout=$3
texpath=$4
gspath=$5


PATH=$PATH:$texpath:$gspath

# echo $PATH

# pdf produced
name=${texin%\.*}.pdf

#echo "running: pdflatex -interaction=nonstopmode -output-directory=$tmpdir $texin > /dev/null && pdfcrop --margins '2 2 2 2' $name $pdfout "

# pdflatex the source TeX file first
pdflatex -interaction=nonstopmode -output-directory=$tmpdir $texin > /dev/null  && pdfcrop --margins '2 2 2 2' $name $pdfout > /dev/null 

#echo "DONE"
exit 1
