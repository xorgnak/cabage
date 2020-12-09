#!/bin/bash
export WORK_USER=$USER;
export WORK_NMAP='-v -A';
function ssh_to_server() {
    ssh $WORK_USER@$*;
}
function git_repo_commit_and_push() {
    git add . && git commit -m "$*" && git push origin main;
}                                                                                                   
watch() {
    mkdir -p $1;
    inotifywait -mq \
	      --timefmt '%s' \
	      -e modify,delete \
	      --format '{ "timestamp": "%T", "events": "%e", "file": "%f" }' $1 | while read out;
    do
	redis-cli publish "WATCH.$1" "$out";
    done > /dev/null;
}


if [ "$1" == "connect" ]; then
    shift;
    ssh_to_server $*;
elif [ "$1" == "push" ]; then
    shift;
    git_repo_commit_and_push $*;
elif [ "$1" == "pull" ]; then
    git pull;
elif [ "$1" == "user" ]; then
    export WORK_USER=$2;
elif [ "$1" == "wifi" ]; then
    wicd-curses;
elif [ "$1" == "hack" ]; then
    sudo wifite; 
elif [ "$1" == "browser" ]; then
    chromium-browser https://vango.me &
elif [ "$1" == "shark" ]; then
    sudo tshark;
elif [ "$1" == "fingerprint" ]; then
    nmap $WORK_NMAP $2;
elif [ "$1" == "scanme" ]; then
    nmap $WORK_NMAP scanme.nmap.org;
elif [ "$1" == "watch" ]; then
    watch $2;
else
    echo "usage: work [connect|push|pull|browser|user|wifi|hack|shark|fingerprint|scanme]";
    echo " connect <domain>";
    echo " push <your commit message>";
    echo " pull";
    echo " browser";
    echo " user <username>";
    echo " browser";
    echo " wifi";
    echo " hack";
    echo " shark";
    echo " fingerprint <domain>";
    echo " scanme";
    echo " watch <dir>";
    # use carefully.
fi                                                                      

