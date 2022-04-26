#!/bin/bash

appserver=$(yc compute instance list | grep "reddit-app" | awk '{print $10}')
dbserver=$(yc compute instance list | grep "reddit-db" | awk '{print $10}')

if [ "$1" == "--list" ]
then
    cat << EOM
    {
        "_meta": {
            "hostvars": {
                "appserver": {
                    "ansible_host": "$appserver"
                },
                "dbserver": {
                    "ansible_host": "$dbserver"
                }
            }
        },

        "app": {
            "hosts": [
                "appserver"
            ]
        },

        "db": {
            "hosts": [
                "dbserver"
            ]
        }
    }
EOM
elif [ "$1" == "--host" ]
then
    cat << EOM
    {
        "_meta": {
        "hostvars": {
            "appserver": {
                "ansible_host": "$appserver"
            },
            "dbserver": {
                "ansible_host": "$dbserver"
            }
        }
    }
EOM
else
  echo "{ }"
fi
