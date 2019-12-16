# Zowe Docker Images
Possible improvements of dockeimages.

## TODO

- [x] expose folder with certificate `--mount type=bind,source=c:/temp/vlcvi01-keystore,target=/root/zowe/1.7.1/components/api-mediation/keystore`
- [x] expose static api def of API ML `--mount type=bind,source=c:/temp/vlcvi01-zowe-user-dir,target=/root/zowe-user-dir/api-mediation/api-defs`
- [x] support for `--only-install`, `--only-config`, `--post-start` to pause the installation/configration process

      docker build -t zowe/docker:1.7.1 .
      docker run -it \
          -p 60004:60004 \
          -p 60014:8544 \
          -p 60002:7552 \
          -p 60003:7553 \
          -h 6W5PZY2.wifi.broadcom.net \
          --env ZOWE_ZOSMF_HOST=usilca32.lvn.broadcom.net \
          --env ZOWE_ZOSMF_PORT=1443 \
          --env ZOWE_ZSS_HOST=usilca32.lvn.broadcom.net \
          --env ZOWE_ZSS_PORT=60012 \
          --env LAUNCH_COMPONENT_GROUPS=GATEWAY \
          --mount type=bind,source=c:/temp/vlcvi01,target=/root/zowe/certs \
          --mount type=bind,source=c:/temp/vlcvi01-keystore,target=/root/zowe/1.7.1/components/api-mediation/keystore \
          --mount type=bind,source=c:/temp/vlcvi01-zowe-user-dir,target=/root/zowe-user-dir/api-mediation/api-defs \
          --mount type=bind,source=C:/Users/vv632728/workspaces/zowe,target=/root/zowe/src \
          zowe/docker:1.7.1 --only-config
      
      Use `--only-install`, `--only-config`, `--post-start` to stop install/config, then use `mc` to investigate content of image
 - [ ] support for Docker on Z
 - [ ] build of docker image as part of Zowe build pipeline
 - [ ] use Alpine instend of Ubuntu  (to shring footprint of docker image)  (NOTE: Alpine is missing `pax` command)
 - [ ] integrate z/OSMF API emulator to run off Z, (use it when `ZOWE_ZOSMF_HOST/ZOWE_ZOSMF_PORT` is not specified), so user can play with MVS, USS, Dataset explorer
 - [ ] use dummy Authenticator for ZAF when (`ZOWE_ZSS_HOST/ZOWE_ZSS_PORT` is not specified), so user can login and inpect to ZAF without having ZSS running
 