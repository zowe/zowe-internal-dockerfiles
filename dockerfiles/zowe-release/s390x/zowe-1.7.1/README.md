# Zowe in Docker
Zowe in Docker allows to run Zowe components (API Mediation Layer, z/OS Services and ZAF) on your workstation (Windows, Linux, macOS) instead of z/OS. This introduces a concept of sandboxes / isolation  of individual developers who may need to perform disruptive tests that may affect others. Without Docker a Zowe environment would have to be created for individual developers. 
 > Each developer has own Zowe instance for a local development that could be restarted or reconfigured anytime without affecting others.

## Requirements
 - Docker on your workstation
 - (optionally) signed certificates by a trusted Certification Authority (CA)
 - (optionally) [static definitions](https://docs.zowe.org/stable/extend/extend-apiml/api-mediation-onboard-an-existing-rest-api-service-without-code-changes.html#define-your-service-and-api-in-yaml-format) of APIs for API Mediation Layer
 - (optionally) z/OSMF installed, configured and running on z/OS
 - (optionally) ZSS and ZSS Cross memory server installed, configured and running on z/OS

**TL;DR**:
Installation and configuration steps
 1) Installation
    ```sh
    docker pull vvvlc/zowe:latest
    ```
  2) Configuration and start of Zowe Docker container
      * (optional) Store [signed certificates](#preparing-certificates-signed-with-a-publicly-trusted-ca-for-your-host) in `c:/zowe/certs`
      * (optional) Store [static definitions](https://docs.zowe.org/stable/extend/extend-apiml/api-mediation-onboard-an-existing-rest-api-service-without-code-changes.html#define-your-service-and-api-in-yaml-format) of APIs in `c:/zowe/zowe-user-dir/api-mediation/api-defs/`
      * z/OSMF running on mf.acme.net:1443
      * ZSS running on mf.acme.net:8542
      * customize and execute `docker run` command 
          ```sh
          docker run -it \
                  -p 8544:8544 \
                  -p 7552:7552 \
                  -p 7553:7553 \
                  -p 7554:7554 \
                  -p 8545:8545 \
                  -p 8547:8547 \
                  -p 1443:1443 \
                  --net="bridge" \
                  -h myhost.acme.net \
                  --env ZOWE_ZOSMF_HOST=mf.acme.net \
                  --env ZOWE_ZOSMF_PORT=1443 \
                  --env ZOWE_ZSS_HOST=mf.acme.net \
                  --env ZOWE_ZSS_PORT=8542 \
                  --env LAUNCH_COMPONENT_GROUPS=GATEWAY,DESKTOP \
                  --mount type=bind,source=c:/zowe/certs,target=/root/zowe/certs \
                  --mount type=bind,source=c:/zowe/keystore,target=/root/zowe/current/components/api-mediation/keystore \
                  --mount type=bind,source=c:/zowe/zowe-user-dir,target=/root/zowe-user-dir/ \
                  --name "zowe" \
                  --rm \
                  vvvlc/zowe:latest
          ```
 3) Open browser and test it
    - API Mediation Layer: https://myhost.acme.net:7554
    - Discovery service: https://myhost.acme.net:7553
    - ZAF: https://myhost.acme.net:8544

## Preparing certificates signed with a publicly trusted CA for your host
If you already have certificates ready you store them in .
```
mkdir c:\zowe\certs
cd c:\zowe\certs
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
    - server.cer   (X.509 - your signed certificate)
    - xxxx.cer     (individual certs from PKCS#7 in separate files)
 8) Import `server.p7b` into `server.p12`
    ```
    keytool -import -alias apiml -trustcacerts -file server.p7b -keystore server.p12 -storepass password
    ```

Example of a content of  `c:\zowe\certs`
```
10/10/2019  09:12 AM             1,338 digicert_global_root_ca.cer
10/10/2019  09:12 AM             1,647 digicert_sha2_secure_server_ca_digicert_global_root_ca_.cer
10/10/2019  09:12 AM             2,472 server.cer
10/10/2019  09:12 AM             5,965 server.p12
```
  
   **Note**: you can delete `server.csr` and `server.p7b`, or you can keep them in this folder.


## Building Zowe Docker image
This step is not needed because image is already available in docker hub.
In case you don't trust pre-builded images perform
```sh
git checkout https://github.com/zowe/zowe-dockerfiles
cd zowe-dockerfile/dockerfiles/zowe-1.7.1
docker build -t zowe/docker:1.7.1 -t zowe/docker:latest -t  vvvlc/zowe:1.7.1$1 -t vvvlc/zowe:latest .
```

Expected output on Windows 10 with Docker:
```
PS C:\Users\vv632728\workspaces\zowe\docker\zowe-dockerfiles\zowe-1.7.1> docker build -t zowe/docker:1.7.1 .
Sending build context to Docker daemon  457.6MB
...
Successfully tagged zowe/docker:1.7.1
SECURITY WARNING: You are building a Docker image from Windows against a non-Windows Docker host. All files and directories added to build context will have '-rwxr-xr-x' permissions. It is recommended to double check and reset permissions for sensitive files and directories.
```

## Starting Zowe Docker Container 
 - prepare folder with certificates, you should have it from previous step.
 - adjust `docker run` command
   - `-h <hostname>` - hostname used in docker container has to be the hostname of your laptop eg: myhost.acme.net.
   - `ZOWE_ZOSMF_HOST=<zosmf_hostname>` - z/OSMF hostname (eg mf.acme.net), if you set `ZOWE_ZOSMF_HOST=''` fakeOSMF is started instead.
   - `ZOWE_ZOSMF_PORT=<zosmf_port>` - z/OSMF port (eg 1443)
   - `ZOWE_ZSS_HOST=<zss_hostname>` - ZSS host (eg mf.acme.net)
   - `ZOWE_ZSS_PORT=<zss_port>` - ZSS port z/OSMF port (eg 8542)
   - `--mount type=bind,source=<folder with certs>` - folder where you have your certs
   - `LAUNCH_COMPONENT_GROUPS=<DESKTOP or GATEWAY>` - what do you want to start
     - DESKTOP - only desktop
     - GATEWAY - only GATEWAY including MVS, USS and JES explorers 
     - GATEWAY,DESKTOP - both 

```cmd
docker run -it \
        -p 8544:8544 \
        -p 7552:7552 \
        -p 7553:7553 \
        -p 7554:7554 \
        -p 8545:8545 \
        -p 8547:8547 \
        -p 1443:1443 \
        --net="bridge" \
        -h myhost.acme.net \
        --env ZOWE_ZOSMF_HOST=mf.acme.net \
        --env ZOWE_ZOSMF_PORT=1443 \
        --env ZOWE_ZSS_HOST=mf.acme.net \
        --env ZOWE_ZSS_PORT=8542 \
        --env LAUNCH_COMPONENT_GROUPS=GATEWAY,DESKTOP \
        --mount type=bind,source=c:/zowe/certs,target=/root/zowe/certs \
        --mount type=bind,source=c:/zowe/keystore,target=/root/zowe/current/components/api-mediation/keystore \
        --mount type=bind,source=c:/zowe/zowe-user-dir,target=/root/zowe-user-dir/ \
        --name "zowe" \
        --rm \
        vvvlc/zowe:latest
```
 - If you want to start only a component adjust `LAUNCH_COMPONENT_GROUPS`.
 - If run it on different machine
    - pull image on another machine
    - execute `docker run` with updated `-h <hostname>`
 - additional start up options `docker run -it ... vvvlc/zowe:latest <startup options>`
   - `--only-install` - pause execution of start of container after installation
   - `--only-config` - pause execution of start of container after configuration
   - `--post-start` - pause execution of start of container after start of zowe (this is an similar to `docker exec -it zowe /bin/bash`)
   - `--regenerate-certificates` - enforce regeneration certificates regardles of content of `/root/zowe/current/components/api-mediation/keystore`
### on and off mainframe development
When you want to use a z/OSMF and ZSS on mainframe specify z/OSMF host and port and ZSS host and port. For example z/OSMF is running on mf.acme.net:443 and ZSS mf.acme.net:60012, then
start zowe docker container with 
```sh
docker run -it \
    ...
    --env ZOWE_ZOSMF_HOST=mf.acme.net \
    --env ZOWE_ZOSMF_PORT=443 \
    --env ZOWE_ZSS_HOST=mf.acme.net \
    --env ZOWE_ZSS_PORT=60012 \
    -h mypc.acme.net \
    ...
```

When you don't have an access to z/OSMF and ZSS you can start Zowe container with a mock of z/OSMF called fakeOSMF.
To activate fakeOSMF set `ZOWE_ZOSMF_HOST=''`. Default fakeOSMF port is `1443` to override default port specify `ZOWE_ZOSMF_PORT=2443`. Optionally you can export fakeOSMF port so it is available on host.
```sh
docker run -it \
    -p 1443:1443
    --env ZOWE_ZOSMF_HOST='' \
    --env ZOWE_ZOSMF_PORT=2443 \
    --env ZOWE_ZSS_HOST='' \
    --env ZOWE_ZSS_PORT=60012 \
    -h mypc.acme.net \
    ...
```
After successful start of Zowe container fakeOSMF is reachable on `mypc.acme.net:2443`, using HTTPS certificates for Zowe.
Command to test it:
```sh
curl 'https://mypc.acme.net:2443/zosmf/info' -H  'X-CSRF-ZOSMF-HEADER: aa' --user a:b
```

Further details on fakeOSMF are in [fakeosmf.py](tools/fakeosmf.py)

**NOTE**: There is no mock for ZSS.


## Building REST APIs for API mediation Layer running in Docker
In this scenario we disable ZAF and start only the API Mediation Layer, we use fakeOSMF so we don't need mainframe backend with z/OSMF. We use Windows 10 with Windows Linux Subsystem and Docker for development.

1) setup certificates in `c:/zowe/certs`
1) create an empty folder for Zowe certificates `c:/zowe/keystore`
1) create an empty folder for Zowe user-dir `c:/zowe/zowe-user-dir`
1) start Zowe docker container and expose discovery port `7553`, fakeOSMF port `1443`, gateway port `7554`.
    ```sh
      docker run -it \
          -p 8544:8544 \
          -p 7552:7552 \
          -p 7553:7553 \
          -p 7554:7554 \
          -p 8545:8545 \
          -p 8547:8547 \
          -p 1443:1443 \
          --net="bridge" \
          -h myhost.acme.net \
          --env ZOWE_ZOSMF_HOST='' \
          --env ZOWE_ZOSMF_PORT=1443 \
          --env LAUNCH_COMPONENT_GROUPS=GATEWAY \
          --mount type=bind,source=c:/zowe/certs,target=/root/zowe/certs \
          --mount type=bind,source=c:/zowe/keystore,target=/root/zowe/current/components/api-mediation/keystore \
          --mount type=bind,source=c:/zowe/zowe-user-dir,target=/root/zowe-user-dir/ \
          --name "zowe" \
          --rm \
          vvvlc/zowe:latest $@
    ```
### Hostname of your workstation does not match subject alternate names in certificate
When hostname of your machine does not match alternate names in certificate modify `%WINDIR%\System32\drivers\etc\hosts`
to add alternate names from certificate eg
```
127.0.0.1 hostname_from_subject_alternate_names_1
127.0.0.1 hostname_from_subject_alternate_names_2
```
**NOTE**: For WLS in Win10 you need to modify `/etc/hosts` as well althoug a comment in file 
  > This file is automatically generated by WSL based on the Windows hosts file, but I had to add these lines as well
```
127.0.0.1 hostname_from_subject_alternate_names_1
127.0.0.1 hostname_from_subject_alternate_names_2
```

### Adding a new static definition of an api running outside of your workstation
go to `c:/zowe/zowe-user-dir/api-mediation/api-defs/` create a new yaml file
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

Either restart container or reload static definitions using the following command while container is running
```sh
docker exec -it zowe /root/zowe/tools/refresh-static-apis.sh
```
expected output:
```sh
$ docker exec -it zowe /root/zowe/tools/refresh-static-apis.sh
Refreshing static definitions https://6W5PZY2.wifi.broadcom.net:7553/discovery/api/v1/staticApi
HTTP/1.1 200 
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Content-Type: application/json;charset=UTF-8
Date: Fri, 27 Dec 2019 14:31:08 GMT
Expires: 0
Pragma: no-cache
Transfer-Encoding: chunked
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block

[
    {
        "actionType": "ADDED", 
        "app": "ZOSMF", 
        "appGroupName": null, 
        "asgName": null, 
        "countryId": 1, 
        "dataCenterInfo": {
            "@class": "com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo", 
            "name": "MyOwn"
        }, 
        "healthCheckUrl": null, 
        "homePageUrl": null, 
        "hostName": "6W5PZY2.wifi.broadcom.net", 
        "instanceId": "STATIC-6W5PZY2.wifi.broadcom.net:zosmf:1443", 
        "ipAddr": "172.17.0.2", 
        "isCoordinatingDiscoveryServer": false, 
        "lastDirtyTimestamp": 1577457068318, 
        "lastUpdatedTimestamp": 1577457068338, 
        "leaseInfo": {
            "durationInSecs": 90, 
            "evictionTimestamp": 0, 
            "lastRenewalTimestamp": 0, 
            "registrationTimestamp": 0, 
            "renewalIntervalInSecs": 30, 
            "serviceUpTimestamp": 0
        }, 
        "metadata": {
            "apiml.apiInfo.api-v1.documentationUrl": "https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.izua700/IZUHPINFO_RESTServices.htm", 
            "apiml.apiInfo.api-v1.gatewayUrl": "api/v1", 
            "apiml.catalog.tile.description": "IBM z/OS Management Facility REST services", 
            "apiml.catalog.tile.id": "zosmf", 
            "apiml.catalog.tile.title": "z/OSMF services", 
            "apiml.catalog.tile.version": "1.0.0", 
            "apiml.routes.api-v1.gatewayUrl": "api/v1", 
            "apiml.routes.api-v1.serviceUrl": "/zosmf/", 
            "apiml.service.description": "IBM z/OS Management Facility REST API service", 
            "apiml.service.title": "IBM z/OSMF", 
            "version": "2.0.0"
        }, 
        "overriddenStatus": "UNKNOWN", 
        "secureHealthCheckUrl": null, 
        "secureVipAddress": "zosmf", 
        "sid": "na", 
        "status": "UP", 
        "statusPageUrl": null, 
        "vipAddress": "zosmf"
    }, 
]
```

### Adding a new static definition of an api running on your workstation
go to `c:/zowe/zowe-user-dir/api-mediation/api-defs/` create a new yaml file
```yaml
#
services:
  - serviceId: my-hello-service
    title: My static defined hello 
    description: My static defined hello 
    catalogUiTileId:
    instanceBaseUrls:
      - https://host.docker.internal:60006/
    homePageRelativeUrl:
    routedServices:
      - gatewayUrl: api/v1
        serviceRelativeUrl: /api/v1/
```
We assume that service is already started on your host on port 60006 and provides APIs.
Either restart container or reload static definitions using the following command while container is running
```sh
docker exec -it zowe /root/zowe/tools/refresh-static-apis.sh
```

### Registering a new api running on your workstation
 1) Install Zowe REST API SDK and Sample Service. [Installation instructions](https://github.com/zowe/sample-spring-boot-api-service/blob/master/zowe-rest-api-sample-spring/README.md).
 2) For integration with Zowe in Docker follow [these instructions](https://github.com/zowe/sample-spring-boot-api-service).

 **NOTE**: Reload of static definitions is not needed because Sample Service registers into API Mediation layer during startup.

Quick summary of steps:
 1. extract localca c:\zowe\certs
    ```cmd
    cd zowe-rest-api-sample-spring
    keytool -exportcert -keystore config/local/truststore.p12 -storepass password -alias localca -rfc > c:\zowe\certs\localca.cer
    ```
 2. start Zowe container and enforce regeneration of certificates via  `--regenerate-certificates`
    ```sh
    docker run -it ... vvvlc/zowe:1.7.1 --regenerate-certificates
    ```
    
    **NOTE**: option `--regenerate-certificates` is need only first time to register file `localca.cer` created in first step.
3. build [zowe-rest-api-sample-spring](https://github.com/zowe/sample-spring-boot-api-service) service
    ```sh
    ./gradlew build
    ```
    When you get 
     > Shared object src/main/resources/lib/libzowe-commons-secur.so is missing. Run `./gradlew zosbuild` in directory /home/vlcvi01/src/zowe/zowe-sample/zowe-rest-api-commons-spring to build it yourself

    You need to unzip zowe-rest-api-sample-spring.zip rather than cloning git repo.
4. start [zowe-rest-api-sample-spring](https://github.com/zowe/sample-spring-boot-api-service) service
    ```sh
    ./gradlew bootRun \
        --args='--spring.config.additional-location=file:./config/local/application.yml \
        --apiml.enabled=true --apiml.service.serviceId=zowesample \
        --apiml.service.hostname=host.docker.internal \
        --apiml.service.ipAddress=127.0.0.1 \
        --apiml.service.discoveryServiceUrls=https://myhost.acme.net:7553/eureka'
    ```
