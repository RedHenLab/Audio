#!/bin/bash
#
# Strip timestamps and metadata from tpt files, and mark the speaker information
#
# Changelog
#
# 2017-07-08 the number of >> does not always match with that of |NER_01|Person, this 
# file is written to fix this bug
#
#
# -----------------------------------------------------------------------------------------------------


LANG=C
FFIL=$1
DIR=$2
FIL=$DIR/${FFIL%.*}.chevron.tpt

# Create the path
if [ ! -d $DIR ] ; then mkdir -p $DIR ; fi

# Get the text lines (improve for files before 2000)
egrep '^2.*\|(CC|TR|NER)' $DIR/$FFIL | cut -d"|" -f4-9 > $FIL

# Remove square brackets and their contents -- only works if the bracket is also closed
sed -i -r 's/\[[^]]*]//g' $FIL


#cp $FIL /home/owen_he/temptest
# Replace the beginning of a sentence that contains (voice over) and ends at : with ||
sed -i -r 's_^.[^\n]*voice over.*:_||_g' $FIL

# Remove parentheses and their contents
sed -i -r 's/[(][^)]*[)]//g' $FIL

# Collect the speakers
#grep ">>[^:]*:" $FIL > $SPK  

# Replace strings from >> to colon with >>
#sed -i -r 's/>>[^:]*:/>>/g' $FIL


# Replace strings from >> to colon with >>
#sed -i -r 's/Person=[^:]*:/>>/g' $FIL


# Remove copyright and registered trademark symbols
sed -i 's/©//g' $FIL
sed -i 's/®//g' $FIL

# Remove musical notes, ascii and utf-8
sed -i 's/o\/~//g' $FIL
sed -i 's/♪//g' $FIL

# Remove junk characters
sed -i 's/\xEF\xBF\xBD//g' $FIL
sed -i 's/\xFB\x2D//g' $FIL
sed -i 's/\x9F\x7F//g' $FIL
sed -i 's/\[\x7F//g' $FIL

# Remove hyphens, and periods
sed -i 's/>>>//g' $FIL
sed -i 's/>>//g' $FIL
sed -i 's/ - / /g' $FIL
sed -i 's/--/ /g' $FIL
sed -i 's/ \. \. \./\./g' $FIL
sed -i 's/\. \. \./\./g' $FIL
sed -i 's/ \. \./\./g' $FIL
sed -i 's/\. \./\./g' $FIL
sed -i 's/ \./\./g' $FIL
sed -i 's/\./\./g' $FIL
sed -i 's/\.\.*/\./g' $FIL

# Remove junk strings (any number)
sed -i 's/_}_{\%//g' $FIL

# Remove tabs and newlines, and finally double spaces
tr -d "\t\n\r" < $FIL > $FIL-1 ; mv $FIL-1 $FIL
sed -i 's/  */ /g' $FIL

# Replace strings from >> to colon with >>
sed -i -r 's/Person=[^:]*:/>>/g' $FIL

# Add a newline at the end if missing
sed -i -e '$a\' $FIL
