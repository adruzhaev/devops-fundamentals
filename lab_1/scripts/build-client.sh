#!/usr/bin/env bash

SCRIPT_DIR=`dirname "$(readlink -f "$BASH_SOURCE")"`
ROOT_DIR=${SCRIPT_DIR%/*}
ENV_CONFIGURATION=$1

cd $ROOT_DIR && npm i && npm run build --configuration $ENV_CONFIGURATION

if [[ -f $ROOT_DIR/dist/client-app.zip ]];
then
    rm -R $ROOT_DIR/dist/client-app.zip
fi
 
zip -r $ROOT_DIR/dist/client-app.zip $ROOT_DIR/dist

totalFilesCount=$(find $ROOT_DIR/dist/app -type f | wc -l)
echo "There are" $totalFilesCount "files in dist/app directory and sub directories."