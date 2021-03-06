#!/bin/bash

HDD="Maxtor6K040L0 ST34321A ST320410A ST320413A ST3320613AS WD800JD WDBUZG0010BBK"
FS="ext4 fat32 ntfs"

declare -A IDS=(["Maxtor6K040L0"]="M1"
		["ST34321A"]="S1"
		["ST320410A"]="S2"
		["ST320413A"]="S3"
		["ST3320613AS"]="S4"
		["WD800JD"]="WD1"
		["WDBUZG0010BBK"]="WD2")

SIZE=5
FIRST_IT="wMB"
DATA_DIR="../data"
# Floating point numbers precision
PREC=3

for hdd in $HDD
do
    echo '\begin{longtable}{|>{\centering}m{5cm}|c|c|c|}'
    echo -n "\caption{Tabla de resultados para [${IDS[$hdd]}]}"
    echo '\\'
    echo '\hline'

    
    echo -n "\cellcolor{blue!25}\textbf{Utilización de CPU} & \cellcolor{blue!25}\textbf{ext4} &\cellcolor{blue!25}\cellcolor{blue!25}\textbf{FAT32} & \cellcolor{blue!25}\textbf{NTFS}"
    echo '\\'
    echo '\hline'

    for j in `seq 1 ${SIZE}`
    do
	echo -n "$j copias simultáneas"
	

	for fs in $FS
	do
	    sum1=$(cat $DATA_DIR/$fs/$hdd/log-$j/averages | grep "user:.*" | grep -o [[:digit:]].*)
	    sum2=$(cat $DATA_DIR/$fs/$hdd/log-$j/averages | grep "system:.*" | grep -o [[:digit:]].*)

	    if [[ ! -z "$sum1" ]]
	    then
	       data=$(echo $sum1+$sum2 | bc -l)
	    fi
	    if [[ ! -z "$data" ]]
	    then
		case $fs in
		    "ext4") ext4v=$(echo $data+${ext4v:-0} | bc -l)
			    ;;
		    "fat32") fat32v=$(echo $data+${fat32v:-0} | bc -l)
			     ;;
		    "ntfs") ntfsv=$(echo $data+${ntfsv:-0} | bc -l)
			    ;;
		esac
		echo -n " & "
                printf "%.*f" $PREC "$data"
	    fi
	    
	    unset data
	done

	echo '\\'
	echo '\hline'
    done
    if [[ ! -z "$ext4v" ]]; then
	ext4v=`printf "%.*f" $PREC "$(echo $ext4v/$SIZE | bc -l)"`
    fi
    if [[ ! -z "$fat32v" ]]; then
	fat32v=`printf "%.*f" $PREC "$(echo $fat32v/$SIZE | bc -l)"`
    fi
    if [[ ! -z "$ntfsv" ]]; then
	ntfsv=`printf "%.*f" $PREC "$(echo $ntfsv/$SIZE | bc -l)"`
    fi
    echo "Media: & $ext4v & $fat32v & $ntfsv \\\\"
    echo "\hline"

    unset ext4v
    unset fat32v
    unset ntfsv
    echo '\end{longtable}'
done
