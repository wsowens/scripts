#!/usr/bin/bash


if [[ $1 == "" ]] || [[ $2 == "" ]]
then
    echo "Usage: "
    echo "quickfix [beds]... "
    echo ""
    echo "Example:"
    echo "quickfix condition1.bed condition2.bed condition3.bed"
    exit -1
fi

# storing the path of fixdmap, the Rust program from wowens
# if you have a different copy of fixdmap, just edit as appropriate
fixdmap_bin="/ufrc/riva/wowens/apps/rust/fixdmap/target/release/fixdmap"
coverage=$1
for filename in $@
do
	srun --ntasks=1 --mem=5gb -t 10:00:00 $fixdmap_bin $filename ${filename%.bed}.fixed.bed &
done
