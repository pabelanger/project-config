#!/bin/bash -xe

# Copyright 2013 OpenStack Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# this is a puppet module
if [ -r metadata.json ]; then
    MODULE_NAME=$(basename `git rev-parse --show-toplevel`)
    puppet module build .
    # so we can re-use "tarball" publisher
    mv pkg dist
    if [ -z "$ZUUL_REFNAME" ] || [ "$ZUUL_REFNAME" == "master" ]; then
        mv dist/*.tar.gz dist/$MODULE_NAME-master.tar.gz
    # need to figure how to deal with stable branches
    fi
else
# this a python project
    venv=${1:-venv}

    export UPPER_CONSTRAINTS_FILE=$(pwd)/upper-constraints.txt

    rm -f dist/*.tar.gz
    tox -e$venv python setup.py sdist
fi

FILES=dist/*.tar.gz
for f in $FILES; do
    echo "SHA1sum for $f:"
    sha1sum $f | awk '{print $1}' > $f.sha1
    cat $f.sha1

    echo "MD5sum for $f:"
    md5sum $f  | awk '{print $1}' > $f.md5
    cat $f.md5
done
