#!/bin/bash

PWD=$(pwd -P)
BASE_DIR="$(cd $(dirname $0)/..)"

EXIT() { cd $PWD; }
trap clenaup EXIT

dart test -j 1 --coverage=coverage --reporter=json > coverage/result.json
dart run coverage:test_with_coverage
genhtml coverage/lcov.info --output=genthml_example
