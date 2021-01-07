#!/bin/bash

URL='https://api.github.com/repos/v2fly/v2ray-core/releases/latest'
TAG='"v2ray-linux-64.zip"'
INSTALL_PATH='.'
NORMAL_CONFIG='
    {"inbounds":[{"listen":"127.0.0.1","port":0,"protocol":"vmess",
    "settings":{"clients":[{"alterId":16,"id":""}]}}],
    "outbounds":[{"protocol":"freedom","settings":{}}]}
    '

try_command() {
    local is_exist=1
    for i in $*; do
        printf 'check requirement: %-8s' $i
        command -v $i > /dev/null 2>&1 || is_exist=0
        if [ $is_exist -eq 0 ]; then
            echo 'not installed'
            echo 'abort'
            exit 0
        fi
        echo 'ok'
    done
}

get_latest_release() {
    local contents=$(curl -sL $URL|jq -c '.assets')
    local length=$(echo $contents|jq 'length')
    local i=0
    while [ $i -lt $length ]; do
        local member=$(echo $contents|jq -c ".[$i]")
        local tag=$(echo $member|jq -c '.name')
        if [ $tag == $TAG ]; then
            local url=$(echo $member|jq -rc '.browser_download_url')
            echo $url
            break
        fi
        ((i++))
    done
}

download_and_unpack() {
    local url=$1
    local path=${INSTALL_PATH}/v2ray
    mkdir $path
    curl -L $url -o $path/$TAG
    echo '==========unzip=========='
    unzip -x $path/$TAG -d $path
    echo '==========clear=========='
    local files=$(ls $path|grep -v 'v2ray'|grep -v 'v2ctl')
    for i in $files; do
        echo 'rm' $i
        rm -rf $path/$i
    done
}

update_config_file() {
    local path=${INSTALL_PATH}/v2ray
    local port=$1
    local uuid=$($path/v2ctl uuid)
    config=$(echo $NORMAL_CONFIG| \
    jq --argjson p $port --arg u $uuid \
    '.inbounds[0].port=$p|.inbounds[0].settings.clients[0].id=$u')
    echo $config
}

write_systemd_file() {
    if [ $(id -u) -ne 0 ]; then
        echo 'no root priority, abort'
        exit 0
    fi
    local path=${INSTALL_PATH}/v2ray
    cat > $path/auto.sh << EOF
    #!/bin/bash
    $path/v2ray -c $path/config.json
EOF
    chmod +x $path/auto.sh

    cat > /etc/systemd/system/v2ray.service << EOF
    [Unit]
    Description=Keep Alive
    After=network.target
    Wants=network.target
    [Service]
    Type=simple
    PIDFile=/run/v2ray.pid
    ExecStart=${path}/auto.sh
    Restart=on-failure
    [Install]
    WantedBy=multi-user.target
EOF
}


main() {
    local path=$INSTALL_PATH/v2ray
    try_command jq tee curl unzip
    #
    echo '=========================='
    echo -n 'get latest release'
    local url=$(get_latest_release)
    echo 'download from'
    echo $url
    download_and_unpack $url
    #
    echo '=========================='
    echo 'config v2ray'
    echo $path/config.json
    local config=$(update_config_file 11111)
    echo $config|tee $path/config.json
    #
    echo '=========================='
    echo 'config systemd'
    echo $path/auto.sh
    echo '/etc/systemd/system/v2ray.service'
    write_systemd_file
    #
    echo '=========================='
    echo 'done'
}

main