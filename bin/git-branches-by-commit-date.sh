#!/bin/bash

git fetch --pull

# Reference https://gist.github.com/jasonrudolph/1810768
for branch in `git branch -r | grep -v HEAD`;do echo -e `git show --format="%ci @ %cr " $branch | head -n 1` @ $branch; done | sort -r | column -t -s '@'
