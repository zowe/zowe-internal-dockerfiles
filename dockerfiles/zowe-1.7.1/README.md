# Zowe Docker file

## Requirements
 - certificates
 - docker
 - z/OSMF up and running
 - ZSS and ZSS Cross memory server up and running

**TL;DR**:
```sh
docker pull vvvlc/zowe:latest
docker run -it -p 60004:60004 -p 60014:8544 -h myhost.acme.net \
  --env ZOWE_ZOSMF_HOST=mf.acme.net \
  --env ZOWE_ZOSMF_PORT=1443 \
  --env ZOWE_ZSS_HOST=mf.acme.net \
  --env ZOWE_ZSS_PORT=60012 \
  --env LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY \
  --mount type=bind,source=c:\temp\certs,target=/root/zowe/certs vvvlc/ \ 
  zowe:latest
```
Open browser and test it
 - API Mediation Layer: https://myhost.acme.net:60004
 - ZAF: https://myhost.acme.net:60014

## Preparing certificates for your host
If already have certificates you can skip this part.
```
mkdir certs
cd certs
```
1) Generate certificate keypair using java keytool
 - Replace `myhost.acme.net` with your hostname. 
 - password has to be word password
 - keystore filename server.p12
 - `CN=` has to by valid hostname 
 - `-ext ExtendedKeyUsage=clientAuth,serverAuth`
```
keytool -genkeypair -alias apiml -keyalg RSA -keysize 2048 -keystore server.p12 -dname "CN=myhost.acme.net, OU=demo, O=Acme Inc, L=San Jose, S=California, C=US" -keypass password -storepass password -storetype PKCS12 -startdate 2019/09/01 -validity 730 -ext ExtendedKeyUsage=clientAuth,serverAuth
```

2) Generate CSR using java keytool
 - Replace `myhost.acme.net` with your hostname. 
 - in `SAN` have `myhost.acme.net`.
 - password has to be word password
 - keystore filename server.p12
 - `CN=` has to by valid hostname 
```
keytool -certreq -alias apiml -keystore server.p12 -storepass password -file server.csr -keyalg RSA -storetype PKCS12 -dname "CN=myhost.acme.net, OU=demo, O=Acme Inc, L=San Jose, S=California, C=US"  -ext SAN=dns:myhost.acme.net -ext ExtendedKeyUsage=clientAuth,serverAuth
```

 3) sign your csr (this is done by someone in your organization)
 7) Save certs next to `server.p12`
    - server.p7b   (PKCS#7 - contains chain of certificates)
    - server.cer  (X.509 - your signed certificate)
	- xxxx.cer     (individual certs from PKCS#7 in separate files)
 8) Import `server.p7b` into `server.p12`
    ```
    keytool -import -alias apiml -trustcacerts -file server.p7b -keystore server.p12 -storepass password
    ```
 Finally files in folder `certs`
   - `digicert_global_root_ca.cer`  
   - `digicert_sha2_secure_server_ca_digicert_global_root_ca_.cer`
   - `server.cer`
   - `server.p12`
  
   **Note**: you can delete `server.csr` and `server.p7b`, or you can keep them in this folder.

## Building docker image
### Building docker image on Linux
Navigate to `zowe-1.5.0` folder
```sh
cd zowe-1.5.0
docker build -t zowe/docker:1.5.0 .
```

### Building docker image on Windows
Navigate to `zowe-1.5.0` folder
```powershell
cd zowe-1.5.0
docker build -t zowe/docker:1.5.0 .
```

Expected output
```
PS C:\Users\vv632728\workspaces\zowe\docker\zowe-dockerfiles\zowe-1.5.0> docker build -t zowe/docker:1.5.0 .
Sending build context to Docker daemon  457.6MB
...
Successfully tagged zowe/docker:1.5.0
SECURITY WARNING: You are building a Docker image from Windows against a non-Windows Docker host. All files and directories added to build context will have '-rwxr-xr-x' permissions. It is recommended to double check and reset permissions for sensitive files and directories.
```

## Executing Zowe Docker Container 
 - prepare folder with certificates, you should have it from previous step.
 - adjust `docker start` command
   - `-h <hostname>` - hostname of docker host (hostname of your laptop eg: myhost.acme.net)
   - `ZOWE_ZOSMF_HOST=<zosmf_hostname>` - z/OSMF hostname (eg mf.acme.net)
   - `ZOWE_ZOSMF_PORT=<zosmf_port>` - z/OSMF port eg (1443)
   - `ZOWE_ZSS_HOST=<zss_hostname>` - ZSS host (eg mf.acme.net)
   - `ZOWE_ZSS_PORT=<zss_port>` - ZSS port z/OSMF port eg (60012)
   - `source=<folder with certs>` - folder where you have your certs
   - `LAUNCH_COMPONENT_GROUPS=<DESKTOP or GATEWAY>` - whay do you want to start
     - DESKTOP - only desktop
     - GATEWAY - only GATEWAY + explorers
     - GATEWAY,DESKTOP - both 

```cmd
docker run -it -p 60004:60004 -p 60014:8544 -h <hostname> --env ZOWE_ZOSMF_HOST=<zosmf_hostname> --env ZOWE_ZOSMF_PORT=<zosmf_port> --env ZOWE_ZSS_HOST=<zss_hostname> --env ZOWE_ZSS_PORT=<zss_port> --env LAUNCH_COMPONENT_GROUPS=<DESKTOP or GATEWAY> --mount type=bind,source=<folder with certs>,target=/root/zowe/certs zowe/docker:1.5.0
```

If you want to 
 - use it with different z/OSMF and ZSS change `ZOWE_ZOSMF_xxx` and `ZOWE_ZSS_xxx`
 - start only a component change `LAUNCH_COMPONENT_GROUPS`
 - run it on differen machine
    - move image to different machine
    -  execute `docker start` with updated `-h <hostname>`

### Windows
 - prepare folder with certificates 
   I have my certificates in `c:\workspaces\ZooTainers-Hackathon2019\certs`
```
c:\workspaces\ZooTainers-Hackathon2019\certs>dir
 Volume in drive C is Windows
 Volume Serial Number is 5EB2-BB6A

 Directory of c:\workspaces\ZooTainers-Hackathon2019\certs

10/10/2019  09:35 AM    <DIR>          .
10/10/2019  09:35 AM    <DIR>          ..
10/10/2019  09:12 AM             1,338 digicert_global_root_ca.cer
10/10/2019  09:12 AM             1,647 digicert_sha2_secure_server_ca_digicert_global_root_ca_.cer
10/10/2019  09:12 AM             2,472 server.cer
10/10/2019  09:12 AM             5,965 server.p12
               4 File(s)         11,422 bytes
               2 Dir(s)  179,745,226,752 bytes free
```
An example of `docker start` command
```cmd
docker run -it -p 60004:60004 -p 60014:8544 -p 60003:7553 -h myhost.acme.net --env ZOWE_ZOSMF_HOST=mf.acme.net --env ZOWE_ZOSMF_PORT=1443 --env ZOWE_ZSS_HOST=mf.acme.net --env ZOWE_ZSS_PORT=60012 --env LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY --mount type=bind,source=c:\workspaces\ZooTainers-Hackathon2019\certs,target=/root/zowe/certs zowe/docker:1.5.0
```

### Linux
```sh
docker run -it -p 60004:60004 -p 60014:8544 -p 60003:7553 -h myhost.acme.net --env ZOWE_ZOSMF_HOST=mf.acme.net --env ZOWE_ZOSMF_PORT=1443 --env ZOWE_ZSS_HOST=mf.acme.net --env ZOWE_ZSS_PORT=60012 --env LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY --mount type=bind,source=/home/john/certs,target=/root/zowe/certs zowe/docker:1.5.0
```

## Test it
Open browser and test it
 - API Mediation Layer: https://mf.acme.net:60004
 - API ML Discovery Service: https://mf.acme.net:60003/
 - ZAF: https://mf.acme.net:60014

## Building REST APIs for API mediation Layer running in Docker

Running in Windows10 in Windows Linux subsystem. In this setup ZAF is disabled and we start only the API Mediation Layer.

1) setup certificates in c:/temp/vlcvi01
1) create an empty folder for Zowe certificates c:/temp/vlcvi01-keystore
1) create an empty folder for Zowe userdir c:/temp/vlcvi01-zowe-user-dir
1) start Zowe docker container and expose discovery port 7553 on 60003
    ```sh
    docker run -it \
        -p 60004:60004 \
        -p 60014:8544 \
        -p 60002:7552 \
        -p 60003:7553 \
        -h 6W5PZY2.wifi.broadcom.net \   <--- IS THIS NEEDED ~~~~~~~!!!!!!!!!!!!!!!
        --env ZOWE_ZOSMF_HOST=usilca32.lvn.broadcom.net \
        --env ZOWE_ZOSMF_PORT=1443 \
        --env ZOWE_ZSS_HOST=usilca32.lvn.broadcom.net \
        --env ZOWE_ZSS_PORT=60012 \
        --env LAUNCH_COMPONENT_GROUPS=GATEWAY \
        --mount type=bind,source=c:/temp/vlcvi01,target=/root/zowe/certs \
        --mount type=bind,source=c:/temp/vlcvi01-keystore,target=/root/zowe/1.7.1/components/api-mediation/keystore \
        --mount type=bind,source=c:/temp/vlcvi01-zowe-user-dir,target=/root/zowe-user-dir \
        zowe/docker:1.7.1 $@
    ```

### adding a new static definition of an api running outside of your workstation
go to `c:/temp/vlcvi01-zowe-user-dir/api-mediation/api-defs` create a new yaml file
```yaml
#
services:
  - serviceId: my-hello-service
    title: My static defined hello 
    description: My static defined hello 
    catalogUiTileId:
    instanceBaseUrls:
      - https://a.hostname.diffrent.than.my.machine:60006/
    homePageRelativeUrl:
    routedServices:
      - gatewayUrl: ui/v1
        serviceRelativeUrl: /ui/v1/explorer-jes
```

**NOTE:** either restart container or reload static definitions 

How to [reload static definitions](https://docs.zowe.org/stable/extend/extend-apiml/api-mediation-onboard-an-existing-rest-api-service-without-code-changes.html#optional-reload-the-services-definition-after-the-update-when-the-api-mediation-layer-is-already-started)

 - convert c:/temp/vlcvi01-keystore/localhost/locahost.keystore.p12 to pem 
    ```sh
    openssl pkcs12 -in localhost.keystore.p12 -out localhost.pem -passin pass:password -nodes -clcerts
    ```
 - do POST request on discovery service `/discovery/api/v1/staticApi`
    ```sh
    http --cert=newfile.pem  -j POST https://6W5PZY2.wifi.broadcom.net:60003/discovery/api/v1/staticApi
    ```
 - test your api

### adding a new static definition of an api running on your workstation
...
...
Petr's pull request
https://github.com/zowe/sample-spring-boot-api-service/pull/58