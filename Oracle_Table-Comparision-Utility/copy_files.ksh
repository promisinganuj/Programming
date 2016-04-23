#!/usr/bin/ksh
error(){
        echo "$1" 1>&2
        exit 1
}

if [[ $# -lt 3 ]]; then
        error "Usage: $0 <drop_info> <date (yyyymmdd)> <target_dir>"
fi

base_dir="/data/io/drop_location/"
dir=`echo $3 | tr "[:upper:]" "[:lower:]"`
drop_info=`echo $1 | tr "[:upper:]" "[:lower:]"`

cd ${base_dir}
if [[ $? -eq 1 ]]; then
        error "Error: Cannot change to base directory, please check script and/or environment..."
fi

mkdir -p ${dir}

cd /data/datadrop_$2
if [[ $? -eq 0 ]]; then
        for file in *.txt; do
                cp -a ${file} ${base_dir}/$3/${file%%.*}_${drop_info}.txt
        done
else
        error "Error: Cannot change directory, please check the parameters passed..."
fi

exit 0
