#!/usr/bin/env bash

usage() {
    cat 1>&2 <<EOF
Usage: $(basename $0) -o OUTFILE [-g GEOMETRY] [-s INITIAL SECTION NUMBER] INFILES...
EOF
    exit $1
}

OUTFILE=
INFILES=
GEOMETRY=
INITIALSECTION=0

while [ $# -ne 0 ]; do
    case $1 in
        -o) shift;
            OUTFILE=$1;;
        -g) shift;
            GEOMETRY=$1;;
        -s) shift;
            INITIALSECTION=$(($1 - 1));;
        -h) usage 0;;
         *) INFILES="$INFILES $1";;
    esac
    shift;
done

if [ "$OUTFILE" = "" ]; then
   usage 1;
fi

function get_base_fn() {
    local tmp_var1="$(basename $1)"
    echo "${tmp_var1%%.*}"
}

function format_section_name() {
    sed -E "s/_/ /g"
}



TMPFILE=$(mktemp /tmp/pdfconcattoc-XXXXXX.tex)

TITLE="$(get_base_fn "$OUTFILE")"

TEXSCRIPT="\documentclass{article}
\usepackage[top=0.75in]{geometry}
%\usepackage{geometry}
\usepackage[utf8]{inputenc}
\usepackage[]{pdfpages}
\usepackage[hidelinks]{hyperref}
\usepackage{fancyhdr}

\setcounter{section}{${INITIALSECTION}}

\geometry{$GEOMETRY}

\title{${TITLE}}
\date{}

\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
%\rhead{Page \thepage}
\newlength{\leftdisplacement}
\setlength{\leftdisplacement}{0.5\paperwidth - 0.5\textwidth - 0.25in}
\lhead{\moveleft \leftdisplacement \hbox{\leftmark}}
\lfoot{}
\rfoot{}

% Credit to Werner at https://tex.stackexchange.com/a/129985
\newcommand{\fakesection}[1]{%
  \clearpage
  \newpage
  \phantomsection
  \par\refstepcounter{section}
  \sectionmark{#1}% Add section mark (header)
  \addcontentsline{toc}{section}{\protect\numberline{\thesection}#1}% Add section to ToC
}

\begin{document}

\maketitle
\tableofcontents
\thispagestyle{empty}
\clearpage

\pagebreak
"

for infile in $INFILES
do
    infile_abs=$(realpath "$infile")
    TEXSCRIPT="${TEXSCRIPT}
\fakesection{$(get_base_fn $infile | format_section_name)}
\includepdf[pages=-,pagecommand={},fitpaper=true]{${infile_abs}}"
done
TEXSCRIPT="${TEXSCRIPT}
\end{document}"

echo "$TEXSCRIPT" > "$TMPFILE"
TMPFILEOUT=$(echo "$TMPFILE" | sed -E "s/tex$/pdf/g")
TMPFILE=$(realpath "$TMPFILE")
OUTFILE=$(realpath "$OUTFILE")

cd /tmp/

# Need to compile multiple times so that TOC references page numbers correctly
# Compilation 1: add sections
# Compilation 2: add TOC
# Compilation 3: adjust TOC page refs (in case TOC spans multiple pages)
for i in $(seq 1 3); do
    pdflatex "$TMPFILE" > /dev/null
done
mv "$TMPFILEOUT" "$OUTFILE"
rm $(get_base_fn $TMPFILE).*
