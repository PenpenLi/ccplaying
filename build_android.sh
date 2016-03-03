#!/bin/sh
# 　　CN(Common Name名字与姓氏) 
# 　　OU(Organization Unit组织单位名称) 
# 　　O(Organization组织名称) 
# 　　L(Locality城市或区域名称) 
# 　　ST(State州或省份名称) 
# 　　C(Country国家名称） 
keytool -genkey -v -alias gc -dname "CN=成都光橙互助科技有限公司,OU=ccplaying,O=ccplaying,L=chengdu,ST=sichuan,C=CN" -keyalg RSA -keysize 2048 -keypass cc123321 -keystore d1_android.keystore -storepass cc123321 -storetype JKS -validity 2000
sh ./version.sh
cocos run -p android --lua-encrypt --lua-encrypt-key "d1_key_" --lua-encrypt-sign "d1_sign_" --compile-script 1 -m release

