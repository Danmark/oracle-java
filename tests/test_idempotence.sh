#!/usr/bin/env bash
# #################
#
# Bash script to run idempotence tests.
#
# version: 1.2
#
# usage:
#
#   test_idempotence [options]
#
# options:
#
#   --box       The name of the Vagrant box or host name
#   --inventory The Ansible inventory in the form of a file or string "host,"
#   --playbook  The path to the Ansible test playbook
#
# example:
#
#   # on localhost
#   bash test_idempotence.sh
#
#   # on a Vagrant box
#   bash test_idempotence.sh \
#       --box precise64
#       --inventory .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
#
#
# author(s):
#   - Pedro Salgado <steenzout@ymail.com>
#
# #################


# GREEN : SGR code to set text color (foreground) to green.
GREEN='\033[0;32m'
# RED : SGR code to set text color (foreground) to red.
RED='\033[0;31m'
# SGR code to set text color (foreground) to no color.
NC='\033[0m'
# The idempotence pass criteria.
PASS_CRITERIA="changed=0.*failed=0"

# the name of the virtualenv
VIRTUALENV_NAME=$(which python | awk -F / 'NF && NF-2 { print ( $(NF-2) ) }')


while [[ $# > 1 ]]
do
key="$1"

    case $key in

        --box)
        # the name of the Vagrant box or host name
        BOX="$2"
        shift;;

        --inventory)
        # the Ansible inventory in the form of a file or string "host,"
        INVENTORY="$2"
        shift;;

        --playbook)
        # the path to the Ansible test playbook
        PLAYBOOK="$2"
        shift;;

        *)
        # unknown option
        ;;

    esac
    shift
done

# the name of the Vagrant box or host name
BOX=${1:-localhost}
# the Ansible inventory in the form of a file or string "host,"
INVENTORY=${2:-'localhost,'}
# the path to the Ansible test playbook
PLAYBOOK=${3:-test.yml}
# the logfile to hold the output of the playbook run
LOGFILE="log/${BOX}_${VIRTUALENV_NAME}.log"

EXTRA_ARGS=''
if [ $BOX == "localhost" ]; then
    EXTRA_ARGS="--connection=local"
fi

echo "[INFO] ${BOX} ${VIRTUALENV_NAME} running idempotence test..."
ansible-playbook -i ${INVENTORY} --limit ${BOX} ${PLAYBOOK} ${EXTRA_ARGS} 2>&1 | tee ${LOGFILE} | \
    grep "${BOX}" | grep -q "${PASS_CRITERIA}" && \
    echo -ne "[TEST] ${BOX} ${VIRTUALENV_NAME} idempotence : ${GREEN}PASS${NC}\n" || \
    (echo -ne "[TEST] ${BOX} ${VIRTUALENV_NAME} idempotence : ${RED}FAILED${NC} ${PASS_CRITERIA}\n" && exit 1)
