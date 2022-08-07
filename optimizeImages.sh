#!/bin/bash

for i in `find static/ -name '*.png'`; do
    newName=`echo "${i}" | sed -e 's/\.png/.webp/g'`
    if [[ -e "${newName}" ]]; then
        continue
    fi
    echo "Generating ${newName}"
    convert "${i}" "${newName}"
done
