#!/bin/bash
#
# Continuous integration script that Jenkins (or whatever) calls which:
# Deploys to dev, staging or production as appropriate

set -u # Variables must be explicit
set -e # If any command fails, fail the whole thing
set -o pipefail

source utilities/add_key.sh -vvv
source utilities/init.sh

ansible-playbook deploy.yaml -i ./inventory -vvv
