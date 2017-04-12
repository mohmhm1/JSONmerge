#!/bin/bash
# Author: Ahmed Mahmoud 8/18/2016
# SQ reporter extract and output merged JSON data for external python parsing.
#rsync for copying only Variants json and samples.csv < 1 day since modification 
rsync -zarv  --prune-empty-dirs -mtime -1  --include "*/"  --include="*.variants.json" --include="Samples.csv" --exclude="*" source target
# copies any directory from previous day to samba
newdir=/Users/ahmed.mahmoud/Downloads/VELA_MAYO_RUN1_UVNNT;
#new directories will be cd'd and searched for SentosaBC- file names
for directories in $newdir
do 
	cd $directories/*/;
	# extract sample id from samples.csv and replace one array field with "sample: $samplename"
	for f in SentosaBC-*;
		do
   			( cd $f && sed 's/(.,*//' Samples.csv > out.csv && cut -d \, -f 1 out.csv > out1.csv &&  name=$(awk 'FNR==2' out1.csv) && echo $name && sed -ri "s/accept: true/sample: $name/g" $f.variants.json && rm out.csv && rm out1.csv )
		done
	# merge all json files into one, clean up brackets and copy the file over to the samba target
	cat **/*.variants.json >> merged.json && sed -i 's/\[//' merged.json && sed -i 's/\]//' merged.json && sed -i '1s/^/\[\n/gm; $s/$/\]/gm' merged.json && sed -i's/}/},/g' merged.json && sed -i's/},,/},/g' merged.json && sed -i -n -e x -e '$ {s/,$//;p;x;}' -e '2,$ p' merged.json && cp merged.json $directories/parsed.json
done