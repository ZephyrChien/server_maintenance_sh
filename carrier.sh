#!/bin/bash

user_name=''
base_path="/home/${user_name}"
main_file_ss="${base_path}/ss/config.json"
swap_file_ss="${base_path}/swap/ss.json"
main_file_v2="${base_path}/v2ray/config.json"
swap_file_v2="${base_path}/swap/v2.json"
interval=600s

if [ -f "${main_file_ss}" ]; then
    cp ${main_file_ss} ${swap_file_ss}
    main_hash_ss=$(md5sum -t ${main_file_ss}|awk '{print $1}')
fi

if [ -f "${main_file_v2}" ]; then
    cp ${main_file_v2} ${swap_file_v2}
    main_hash_v2=$(md5sum -t ${main_file_v2}|awk '{print $1}')
fi


while (true); do
    if [ -f "${swap_file_ss}" ]; then
        swap_hash_ss=$(md5sum -t ${swap_file_ss}|awk '{print $1}')
        if [ ${swap_hash_ss} != ${main_hash_ss} ]; then
            main_hash_ss=${swap_hash_ss}
            sudo -u ${user_name} cp ${swap_file_ss} ${main_file_ss}
            systemctl restart ss
        fi
    fi
    if [ -f "${swap_file_v2}" ]; then
        swap_hash_v2=$(md5sum -t ${swap_file_v2}|awk '{print $1}')
        if [ ${swap_hash_v2} != ${main_hash_v2} ]; then
            main_hash_v2=${swap_hash_v2}
            sudo -u ${user_name} cp ${swap_file_v2} ${main_file_v2}
            systemctl restart v2ray
        fi
    fi
    sleep ${interval}
done