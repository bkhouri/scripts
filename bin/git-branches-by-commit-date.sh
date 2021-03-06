#!/bin/bash

git fetch --prune

# Reference https://gist.github.com/jasonrudolph/1810768
for branch in `git branch -r | grep -v HEAD`;do echo -e `git show --format="%ci $ %cr $ %H $ %cn $ %ce $ %an $ %ae" $branch | head -n 1` \$ $branch; done | sort -r | column -t -s '$'
