#!/bin/bash

PROJ_ROOT=/root/redflex-infrastructure
TEST_REPORT_DIR=$PROJ_ROOT/test_report
TEST_WORKSPACE=/tmp/test_workspace

rm -rf $TEST_REPORT_DIR
mkdir -p $TEST_REPORT_DIR
mkdir -p $TEST_WORKSPACE

cp -rf $PROJ_ROOT/templates $TEST_WORKSPACE/
cp -rf $PROJ_ROOT/test $TEST_WORKSPACE/

cd $TEST_WORKSPACE/test/data/templates
for dir in *; do
  if [[ -d "$dir" && -f "$dir/test_data.tf" ]]; then
    mv "$dir/test_data.tf" "$TEST_WORKSPACE/templates/$dir/data.tf"
  fi
done

cd $TEST_WORKSPACE/test
go install github.com/jstemmer/go-junit-report@v0.9.1
go test -v 2>&1 | tee >(go-junit-report > $TEST_REPORT_DIR/report.xml)
rm -rf $TEST_WORKSPACE