#!/usr/bin/env bash

set -e

dirname=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)
cd "$dirname"

if [ "$TERM_PROGRAM" == "vscode" ]; then
    clear
fi

ADDR="188.166.103.165"

if [[ -z "${USER}" ]]; then
    echo "`USER` not set" 1>&2
    exit 1
fi

dos2unix www/deploy.sh
if  grep -q -U $'\015' www/deploy.sh; then
    echo "deploy.sh contains carriage return" 1>&2
    exit 1
fi

npm run clean
npm run build

if [[ $(git diff --stat) != '' ]]; then
    echo "Git working tree is dirty" 1>&2
    exit 1
fi

echo "Packing..."
tar -v -czf deploy.tar.gz \
    static \
    www/nginx.conf

echo "Uploading..."
scp -i .ssh/$ADDR/$USER/id_rsa deploy.tar.gz $USER@$ADDR:/home/vallentin/snippets.tar.gz

echo "Deploying..."
ssh $USER@$ADDR -i .ssh/$ADDR/$USER/id_rsa "bash -s" < www/deploy.sh

rm -f deploy.tar.gz
