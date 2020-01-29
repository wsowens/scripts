#!/usr/bin/bash


if [[ $1 == "" ]] || [[ $2 == "" ]]
then
    echo "Usage: "
    echo "quickfilter '[coverages]...' [beds]... "
    echo ""
    echo "Example:"
    echo "quickfilter '10 30 100' condition1.bed condition2.bed condition3.bed"
    exit -1
fi

# storing the path of filtercov, the Rust program from wowens
# if you have a different copy of filtercov, just edit as appropriate
filtercov_bin="/ufrc/riva/wowens/apps/rust/filtercov/target/release/filtercov"
coverage=$1
for filename in ${@:2}
do
	srun --ntasks=1 --mem=5gb -t 10:00:00 $filtercov_bin "${coverage}" $filename &
done
