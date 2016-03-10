#!/bin/sh
TARGET=$1
sh ./version.sh
cocos compile -p ios --lua-encrypt --lua-encrypt-key "d1_key_" --lua-encrypt-sign "d1_sign_" --compile-script 1 -t $TARGET -m release --sign-identity "iPhone Distribution: Cao Jun (977549GP8P)"

2-test-1
