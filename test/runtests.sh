#! /usr/bin/env sh
mkdir -p build
haxe -cmd "node build/nodejs_test.js" test/travis.hxml
