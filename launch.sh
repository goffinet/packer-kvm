#!/bin/bash
distributions=$(ls -1 *.json) ; for x in $distributions ; do ./build.sh $x ; done
