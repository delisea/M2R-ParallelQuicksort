
OUTPUT_DIRECTORY=data/`hostname`_`date +%F`
mkdir -p $OUTPUT_DIRECTORY
TOUTPUT_FILE=$OUTPUT_DIRECTORY/measurements_`date +%R`
OUTPUT_FILE=$TOUTPUT_FILE.txt

touch $OUTPUT_FILE

let "randy = $(./scripts/rand 42)"
declare -A tes
declare -A tit
let "j = 0"
for i in $@; do
	 tit[${j}]=${i}
	 tes[${j}]=0
	 let "j = $j + 1"
done

#echo ${tit[@]}
#echo ${!tit[@]}


let "ma = 5"
let "si = j"
let "len = j - 1"

let "k = $ma * $j"
while [ $k -ne 0 ]; do

# choix du test aléatoirement
let "randy = $(./scripts/rand $randy)"
let "val = $randy % $si"
let "i = 0"
while [ $val -ne 0 ]; do
	if [ ${tes[${i}]} -ne $ma ]
	then
		let "val = $val - 1"
	fi
		#echo ${tes[${i}]} -ne $ma
	#echo $val 
	if [ ${i} -eq $len ]
   then
		let "i = 0"
	else
		let "i = i + 1"
	fi
done
	# on prends le premier valide
	while [ ${tes[${i}]} -eq $ma ]; do
		if [ ${i} -eq $len ]
		then
			let "i = 0"
		else
			let "i = i + 1"
		fi
	done
	#echo $i le test choisi

	#echo test ${tit[${i}]}
	echo "Size: ${tit[${i}]}" >> $OUTPUT_FILE;
        ./src/parallelQuicksort ${tit[${i}]} >> $OUTPUT_FILE;


	let "tes[${i}] = ${tes[${i}]} + 1"
	let "k = k - 1"
done
#echo ${tes[@]}



FILENAME=$TOUTPUT_FILE
perl scripts/csv_quicksort_extractor2.pl < "$FILENAME.txt" > "${FILENAME}_wide.csv"

sort -k1n,1n "${FILENAME}_wide.csv" > "${FILENAME}_wide_sorted.csv"


#awk '{ total += $2 } END { print total/NR }' data/deliseport-GP60-2QE_2017-01-19/measurements_15\:37_wide.csv 
#paste data/deliseport-GP60-2QE_2017-01-19/measurements_15\:37_wide.csv  data/deliseport-GP60-2QE_2017-01-19/measurements_15\:48_wide.csv -d=","
#sed -n -e '/^100,/p' data/deliseport-GP60-2QE_2017-01-19/measurements_15\:37_wide.csv 

echo Size, Seq, Par, Libc > "${FILENAME}_wide_mean.csv"

declare -A mean
for i in $@; do
	 sed -n -e "/^$i,/p" "${FILENAME}_wide.csv" > "data/t.csv"

	mean[0]=$(awk '{ total += $2 } END { print total/NR }' 'data/t.csv')
	mean[1]=$(awk '{ total += $3 } END { print total/NR }' 'data/t.csv')
	mean[2]=$(awk '{ total += $4 } END { print total/NR }' 'data/t.csv')
	#echo $i, ${mean[0]}, ${mean[1]}, ${mean[2]}
	echo $i, ${mean[0]}, ${mean[1]}, ${mean[2]} >> "${FILENAME}_wide_mean.csv"
done



echo "
  set terminal png size 600,400 
  set output '${FILENAME}_wide.png'
  set datafile separator ','
  set key autotitle columnhead
	plot '${FILENAME}_wide_mean.csv' using 1:2 with linespoints, '' using 1:3 with linespoints, '' using 1:4 with linespoints, '${FILENAME}_wide_sorted.csv' using 1:2, '' using 1:3, '' using 1:4
" | gnuplot

#echo "
#  set terminal png size 600,400 
#  set output '${FILENAME}_wide.png'
#  set datafile separator ','
#  set key autotitle columnhead
#  plot '${FILENAME}_wide_mean.csv' '${FILENAME}#_wide_sorted.csv' using 1:2 with linespoints, '' using 1:3 #with linespoints, '' using 1:4 with linespoints
#" | gnuplot
echo [[file:${FILENAME}_wide.png]]
