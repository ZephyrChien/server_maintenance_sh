#!/bin/bash

main_file=''
swap_file=''
interval=600s
main_hash=$(md5sum -t ${main_file}|awk '{print $1}')

while (true); do
    swap_hash=$(md5sum -t ${swap_file}|awk '{print $1}')
    if [ ${swap_hash} != ${main_hash} ]; then
        cp ${swap_file} ${main_file}
        main_hash=${swap_hash}
    fi
    sleep ${interval}
done