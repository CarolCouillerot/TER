for d in ./*/; do
	cd $d;
	for f in ./*.txt; do
		rm $f
	done
	for f in ./*.xml; do
		rm $f
	done
	for f in ./*.back; do
		rm $f
	done
	cd ..
done
