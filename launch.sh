#!/bin/bash
distributions=$(ls -1 *.pkr.hcl) ; for x in $distributions ; do ./build.sh $x ; done
