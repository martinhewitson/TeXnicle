#!/bin/sh

# makePDFimage.sh
# TeXnicle
#
# Created by Martin Hewitson on 1/2/10.
# Copyright 2010 bobsoft. All rights reserved.
#
#//  Redistribution and use in source and binary forms, with or without
#//  modification, are permitted provided that the following conditions are met:
#//      * Redistributions of source code must retain the above copyright
#//        notice, this list of conditions and the following disclaimer.
#//      * Redistributions in binary form must reproduce the above copyright
#//        notice, this list of conditions and the following disclaimer in the
#//        documentation and/or other materials provided with the distribution.
#//  
#//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
#//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#//

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
