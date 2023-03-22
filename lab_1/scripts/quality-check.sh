#!/usr/bin/env bash

SCRIPT_DIR=`dirname "$(readlink -f "$BASH_SOURCE")"`
ROOT_DIR=${SCRIPT_DIR%/*}
REPORT_FILE=$ROOT_DIR/reports.txt

if [[ -f $REPORT_FILE ]]; then
    rm $REPORT_FILE
else
    touch $REPORT_FILE
fi

cd $ROOT_DIR

echo "Unit tests." >> $REPORT_FILE
echo "Unit tests are started."
npm run test -- --watch=false | grep -i "error" >> $REPORT_FILE
echo "------------------------------------------------------------" >> $REPORT_FILE
echo "Unit tests are ended."

echo "Linting." >> $REPORT_FILE
echo "Linting is started."
npm run lint --quiet | grep -i "error" >> $REPORT_FILE
echo "------------------------------------------------------------" >> $REPORT_FILE
echo "Linting is ended."

echo "e2e tests." >> $REPORT_FILE
echo "e2e tests are started."
npm run e2e | grep -i "error" >> $REPORT_FILE
echo "------------------------------------------------------------" >> $REPORT_FILE
echo "e2e tests are ended."
