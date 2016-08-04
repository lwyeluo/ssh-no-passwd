#!/bin/bash
username=$1
password=$2
host=$3

/usr/bin/expect <<-EOF
set time 30
spawn ssh-copy-id $username@$host
expect {
    #first connect, no public key in ~/.ssh/known_hosts
    "Are you sure you want to continue connecting (yes/no)?" {
    send "yes\r"
    expect "password:"
        send "$password\r"
    }
    #already has public key in ~/.ssh/known_hosts
    "password:" {
        send "$password\r"
    }
    "Now try logging into the machine" {
        #it has authorized, do nothing!
    }
    "All keys were skipped" {

    }
}
#expect eof
EOF
exit 0
