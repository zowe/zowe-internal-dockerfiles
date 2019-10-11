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
Step 1/16 : FROM loyaltyone/docker-slim-java-node
 ---> faaf5f51785e
Step 2/16 : EXPOSE 60004/tcp
 ---> Using cache
 ---> 152156f9ee15
Step 3/16 : EXPOSE 8544/tcp
 ---> Using cache
 ---> c228c3b25b53
Step 4/16 : ENV NODE_HOME='/usr/local'
 ---> Using cache
 ---> 56b9b8199194
Step 5/16 : ENV ZOWE_JAVA_HOME='/usr'
 ---> Using cache
 ---> 6b12595bd14c
Step 6/16 : ENV ZOWE_ZOSMF_HOST='zosmf'
 ---> Using cache
 ---> a6d189bedaef
Step 7/16 : ENV ZOWE_ZOSMF_PORT='1443'
 ---> Using cache
 ---> 3a39149f2dfc
Step 8/16 : ENV ZOWE_ZSS_HOST='zss'
 ---> Using cache
 ---> 832416d8f6b0
Step 9/16 : ENV ZOWE_ZSS_PORT='8542'
 ---> Using cache
 ---> ecc2a71305e7
Step 10/16 : ENV LAUNCH_COMPONENT_GROUPS='GATEWAY,DESKTOP'
 ---> Using cache
 ---> 1f6272fc0219
Step 11/16 : RUN apt-get update && apt-get install -y --no-install-recommends jq moreutils pax openjdk-8-jdk-headless build-essential mc && rm -rf /var/lib/apt/lists/*
 ---> Using cache
 ---> 5d8240c4b45e
Step 12/16 : RUN echo "dash dash/sh boolean false" | debconf-set-selections
 ---> Using cache
 ---> e119c87d8e5d
Step 13/16 : RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash
 ---> Using cache
 ---> be10586716d0
Step 14/16 : COPY * /root/zowe/
 ---> f5dc04ede14e
Step 15/16 : RUN cd /root/zowe/ && ./install.sh && rm -f /root/zowe/*.pax && rm -rf /root/zowe/zowe/ && apt-get purge -y pax build-essential && apt autoremove -y && rm -rf /var/lib/apt/lists/*
 ---> Running in 94eb17508c4b
BASH=/bin/bash
BASHOPTS=cmdhist:complete_fullquote:extquote:force_fignore:hostcomplete:interactive_comments:progcomp:promptvars:sourcepath
BASH_ALIASES=()
BASH_ARGC=()
BASH_ARGV=()
BASH_CMDS=()
BASH_LINENO=([0]="0")
BASH_SOURCE=([0]="./install.sh")
BASH_VERSINFO=([0]="4" [1]="4" [2]="12" [3]="1" [4]="release" [5]="x86_64-pc-linux-gnu")
BASH_VERSION='4.4.12(1)-release'
CA_CERTIFICATES_JAVA_VERSION=20170531+nmu1
DEBUG=
DIRSTACK=()
EUID=0
GROUPS=()
HOME=/root
HOSTNAME=94eb17508c4b
HOSTTYPE=x86_64
IFS=$' \t\n'
JAVA_DEBIAN_VERSION=8u162-b12-1~deb9u1
JAVA_HOME=/docker-java-home/jre
JAVA_VERSION=8u162
LANG=C.UTF-8
LAUNCH_COMPONENT_GROUPS=GATEWAY,DESKTOP
MACHTYPE=x86_64-pc-linux-gnu
NODE_HOME=/usr/local
NODE_VERSION=8.11.1
OLDPWD=/
OPTERR=1
OPTIND=1
OSTYPE=linux-gnu
PATH=/root/zowe:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
PIPESTATUS=([0]="0")
PPID=1
PS4='+ '
PWD=/root/zowe
SHELL=/bin/bash
SHELLOPTS=braceexpand:hashall:interactive-comments
SHLVL=2
TERM=dumb
UID=0
WORK_DIR=/root/zowe
YARN_VERSION=1.5.1
ZOWE_INSTALL_ROOT=/root/zowe/1.5.0
ZOWE_JAVA_HOME=/usr
ZOWE_ZOSMF_HOST=zosmf
ZOWE_ZOSMF_PORT=1443
ZOWE_ZSS_HOST=zss
ZOWE_ZSS_PORT=8542
_=
zowe-1.5.0/licenses/
...
zowe-1.5.0/install/zowe-install.yaml
Processing api-mediation-package-0.8.4.pax file.
Processing explorer-jes-0.0.22.pax file.
Processing explorer-mvs-0.0.15.pax file.
Processing explorer-uss-0.0.13.pax file.
Processing zss.pax file.
Processing sample-angular-app.pax file.
Processing sample-iframe-app.pax file.
Processing sample-react-app.pax file.
Processing tn3270-ng2.pax file.
Processing vt-ng2.pax file.
Processing zlux-core.pax file.
Processing zlux-editor.pax file.
Processing zlux-workflow.pax file.
Processing zosmf-auth.pax file.
Processing zss-auth.pax file.
---------------------------------------------------------------------
grep: /root/: Is a directory
Warning: ping command not found trying oping
Error: neither ping nor oping has not been found, add folder with ping or oping on $PATH, normally they are in /bin
/root/zowe/zowe/scripts/zowe-init.sh: line 225: 94eb17508c4b: command not found
Error: 94eb17508c4b command failed to find hostname
    Please enter the ZOWE_EXPLORER_HOST of this system
/root/zowe/zowe/scripts/zowe-init.sh: line 302: 94eb17508c4b: command not found
Error: 94eb17508c4b command failed to find IP
error : ZOWE_EXPLORER_HOST or ZOWE_IPADDRESS is an empty string
    Please enter the ZOWE_IPADDRESS of this system
Error: User entered blank ZOWE_IPADDRESS
Info: Using ZOWE_IPADDRESS=
error : ZOWE_EXPLORER_HOST or ZOWE_IPADDRESS is an empty string
Reading variables from zowe-install.yaml
Beginning install of Zowe 1.5.0 into directory  /root/zowe/1.5.0
pax: WARNING! These patterns were not matched:
zssServer
/root/zowe/zowe/scripts/zlux-install-script.sh: line 40: extattr: command not found
chmod: cannot access 'bin/zssServer': No such file or directory
Zowe 1.5.0 runtime install completed into directory /root/zowe/1.5.0
The install script zowe-install.sh does not need to be re-run as it completed successfully
---------------------------------------------------------------------
zowe-install.sh -I was specified, so just installation ran. In order to use Zowe, you must configure it by running /root/zowe/1.5.0/scripts/configure/zowe-configure.sh
Reading package lists...
Building dependency tree...
Reading state information...
The following packages were automatically installed and are no longer required:
  binutils cpp cpp-6 dpkg-dev g++ g++-6 gcc gcc-6 libasan3 libatomic1
  libc-dev-bin libc6-dev libcc1-0 libcilkrts5 libdpkg-perl libgcc-6-dev
  libgomp1 libisl15 libitm1 liblsan0 libmpc3 libmpfr4 libmpx2 libquadmath0
  libstdc++-6-dev libtsan0 libubsan0 linux-libc-dev make patch
Use 'apt autoremove' to remove them.
The following packages will be REMOVED:
  build-essential* pax*
0 upgraded, 0 newly installed, 2 to remove and 0 not upgraded.
After this operation, 195 kB disk space will be freed.
(Reading database ... 15486 files and directories currently installed.)
Removing build-essential (12.3) ...
Removing pax (1:20161104-2) ...

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Reading package lists...
Building dependency tree...
Reading state information...
The following packages will be REMOVED:
  binutils cpp cpp-6 dpkg-dev g++ g++-6 gcc gcc-6 libasan3 libatomic1
  libc-dev-bin libc6-dev libcc1-0 libcilkrts5 libdpkg-perl libgcc-6-dev
  libgomp1 libisl15 libitm1 liblsan0 libmpc3 libmpfr4 libmpx2 libquadmath0
  libstdc++-6-dev libtsan0 libubsan0 linux-libc-dev make patch
Processing triggers for libc-bin (2.24-11+deb9u3) ...
Removing intermediate container 94eb17508c4b
 ---> 8aada6eec4e0
Step 16/16 : ENTRYPOINT (cd /root/zowe/ && ./run.sh && cd /root/zowe/1.5.0/scripts/internal && bash ./run-zowe.sh; sleep infinity)
 ---> Running in b8b83dbbfcbd
Removing intermediate container b8b83dbbfcbd
 ---> 17e3d023fae9
Successfully built 17e3d023fae9
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
docker run -it -p 60004:60004 -p 60014:8544 -h myhost.acme.net --env ZOWE_ZOSMF_HOST=mf.acme.net --env ZOWE_ZOSMF_PORT=1443 --env ZOWE_ZSS_HOST=mf.acme.net --env ZOWE_ZSS_PORT=60012 --env LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY --mount type=bind,source=c:\workspaces\ZooTainers-Hackathon2019\certs,target=/root/zowe/certs zowe/docker:1.5.0
```

### Linux
```cmd
docker run -it -p 60004:60004 -p 60014:8544 -h myhost.acme.net --env ZOWE_ZOSMF_HOST=mf.acme.net --env ZOWE_ZOSMF_PORT=1443 --env ZOWE_ZSS_HOST=mf.acme.net --env ZOWE_ZSS_PORT=60012 --env LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY --mount type=bind,source=/home/john/certs,target=/root/zowe/certs zowe/docker:1.5.0
```

Expected output
```
BASH=/bin/bash
BASHOPTS=cmdhist:complete_fullquote:extquote:force_fignore:hostcomplete:interactive_comments:progcomp:promptvars:sourcepath
BASH_ALIASES=()
BASH_ARGC=()
BASH_ARGV=()
BASH_CMDS=()
BASH_LINENO=([0]="0")
BASH_SOURCE=([0]="./run.sh")
BASH_VERSINFO=([0]="4" [1]="4" [2]="12" [3]="1" [4]="release" [5]="x86_64-pc-linux-gnu")
BASH_VERSION='4.4.12(1)-release'
CA_CERTIFICATES_JAVA_VERSION=20170531+nmu1
CERTS_DIR=/root/zowe/certs
DEBUG=
DIRSTACK=()
EUID=0
GROUPS=()
HOME=/root
HOSTNAME=myhost.acme.net
HOSTTYPE=x86_64
IFS=$' \t\n'
JAVA_DEBIAN_VERSION=8u162-b12-1~deb9u1
JAVA_HOME=/docker-java-home/jre
JAVA_VERSION=8u162
LANG=C.UTF-8
LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY
MACHTYPE=x86_64-pc-linux-gnu
NODE_HOME=/usr/local
NODE_VERSION=8.11.1
OLDPWD=/
OPTERR=1
OPTIND=1
OSTYPE=linux-gnu
PATH=/root/zowe:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
PIPESTATUS=([0]="0")
PPID=6
PS4='+ '
PWD=/root/zowe
SHELL=/bin/bash
SHELLOPTS=braceexpand:hashall:interactive-comments
SHLVL=2
TERM=xterm
UID=0
YARN_VERSION=1.5.1
ZOWE_INSTALL_ROOT=/root/zowe/1.5.0
ZOWE_JAVA_HOME=/usr
ZOWE_ZOSMF_HOST=mf.acme.net
ZOWE_ZOSMF_PORT=1443
ZOWE_ZSS_HOST=mf.acme.net
ZOWE_ZSS_PORT=60012
_=
YARN_VERSION=1.5.1
LANG=C.UTF-8
HOSTNAME=myhost.acme.net
OLDPWD=/
NODE_HOME=/usr/local
JAVA_HOME=/docker-java-home/jre
ZOWE_ZOSMF_HOST=mf.acme.net
JAVA_VERSION=8u162
PWD=/root/zowe
HOME=/root
ZOWE_ZOSMF_PORT=1443
ZOWE_JAVA_HOME=/usr
ZOWE_EXPLORER_HOST=myhost.acme.net
_BPXK_AUTOCVT=OFF
CA_CERTIFICATES_JAVA_VERSION=20170531+nmu1
NODE_VERSION=8.11.1
JAVA_DEBIAN_VERSION=8u162-b12-1~deb9u1
TERM=xterm
LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY
SHLVL=2
ZOWE_ZSS_PORT=60012
ZOWE_IPADDRESS=127.0.0.1
PATH=/root/zowe:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin
ZOWE_ZSS_HOST=mf.acme.net
_=/usr/bin/env
grep: /root/: Is a directory
Warning: ping command not found trying oping
Error: neither ping nor oping has not been found, add folder with ping or oping on $PATH, normally they are in /bin
/root/zowe/1.5.0/scripts/configure/zowe-init.sh: line 264: myhost.acme.net: command not found
warning :  myhost.acme.net did not match stated IP address 127.0.0.1
Reading variables from zowe-install.yaml
Beginning to configure zowe installed in /root/zowe/1.5.0
/root/zowe/1.5.0/scripts/configure/zowe-install-iframe-plugin.sh: line 49: chtag: command not found
/root/zowe/1.5.0/scripts/configure/zowe-install-iframe-plugin.sh: line 49: chtag: command not found
/root/zowe/1.5.0/scripts/configure/zowe-install-iframe-plugin.sh: line 49: chtag: command not found
/root/zowe/1.5.0/scripts/configure/zowe-install-iframe-plugin.sh: line 49: chtag: command not found
Attempting to setup Zowe API Mediation Layer certificates ... 
  Setting up Zowe API Mediation Layer certificates...
apiml_cm.sh --action trust-zosmf has failed. See /root/zowe/1.5.0/scripts/configure/log/config_2019-10-10-09-44-15.log for more details
WARNING: z/OSMF is not trusted by the API Mediation Layer. Follow instructions in Zowe documentation about manual steps to trust z/OSMF
  Issue following commands as a user that has permissions to export public certificates from z/OSMF keyring:
    cd /root/zowe/1.5.0/api-mediation
    scripts/apiml_cm.sh --action trust-zosmf --zosmf-keyring IZUKeyring.IZUDFLT --zosmf-userid IZUSVR
  Certificate setup done.
Attempting to setup Zowe Scripts ... 
Attempting to setup Zowe Proclib ... 
logname: no login name
logname: no login name
Unable to create the PROCLIB member 
  Failed to put ZOWESVR.JCL in a PROCLIB dataset.
  Please add it manually from /root/zowe/1.5.0/ZOWESVR.JCL to your PROCLIB
    To find PROCLIB datasets, issue /$D PROCLIB in SDSF
/root/zowe/1.5.0/scripts/zowe-runtime-authorize.sh: line 20: extattr: command not found
chgrp: invalid group: ‘IZUADMIN’
  The current user does not have sufficient authority to modify all the file and directory permissions.
  A user with sufficient authority must run /root/zowe/1.5.0/scripts/zowe-runtime-authorize.sh
To start Zowe run the script /root/zowe/1.5.0/scripts/zowe-start.sh
   (or in SDSF directly issue the command /S ZOWESVR)
To stop Zowe run the script /root/zowe/1.5.0/scripts/zowe-stop.sh
  (or in SDSF directly the command /C ZOWESVR)
depth=2 C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert Global Root CA
verify return:1
depth=1 C = US, O = DigiCert Inc, CN = DigiCert SHA2 Secure Server CA
verify return:1
depth=0 C = US, ST = California, L = San Jose, O = Broadcom Inc, OU = IT, CN = *.lvn.broadcom.net
verify return:1
DONE
Certificate was added to keystore
ZOWE_JAVA_HOME already exists on the PATH
ZOWE_JAVA_HOME already exists on the PATH
ZOWE_JAVA_HOME already exists on the PATH
ZLUX_NODE_LOG_FILE=/root/zowe/1.5.0/zlux-app-server/log/nodeServer-2019-10-10-09-45.log
Show Environment
_BPX_JOBNAME=ZOWE1DT
YARN_VERSION=1.5.1
LANG=C.UTF-8
HOSTNAME=myhost.acme.net
OLDPWD=/root/zowe/1.5.0/zlux-app-server/bin
NODE_PATH=../..:../../zlux-server-framework/node_modules:
NODE_HOME=/usr/local
JAVA_HOME=/docker-java-home/jre
ZOWE_ZOSMF_HOST=mf.acme.net
ZLUX_LOG_PATH=/root/zowe/1.5.0/zlux-app-server/log/nodeServer-2019-10-10-09-45.log
JAVA_VERSION=8u162
PWD=/root/zowe/1.5.0/zlux-app-server/lib
HOME=/root
ZOWE_ZOSMF_PORT=1443
ZOWE_JAVA_HOME=/usr
_BPXK_AUTOCVT=ON
minWorkers=2
CA_CERTIFICATES_JAVA_VERSION=20170531+nmu1
NODE_VERSION=8.11.1
JAVA_DEBIAN_VERSION=8u162-b12-1~deb9u1
dir=.
TERM=xterm
LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY
ZOWE_PREFIX=ZOWE1
SHLVL=3
ZOWE_ZSS_PORT=60012
PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
_CEE_RUNOPTS=XPLINK(ON),HEAPPOOLS(ON)
ZOWE_ZSS_HOST=mf.acme.net
_=/usr/bin/env
Show location of node
node is /usr/local/bin/node
Starting node
/root/zowe/1.5.0/scripts/utils/validatePortAvailable.sh: line 14: onetstat: command not found
[explorer-jes] config file /root/zowe/1.5.0/jes_explorer/server/configs/config.json:
[explorer-jes] paths will be served:
[explorer-jes]   - /ui/v1/explorer-jes => /root/zowe/1.5.0/jes_explorer/app
[explorer-jes] is started and listening on 8546...

[explorer-mvs] config file /root/zowe/1.5.0/mvs_explorer/server/configs/config.json:
[explorer-mvs] paths will be served:
[explorer-mvs]   - /ui/v1/explorer-mvs => /root/zowe/1.5.0/mvs_explorer/app
[explorer-mvs] is started and listening on 8548...

[explorer-uss] config file /root/zowe/1.5.0/uss_explorer/server/configs/config.json:
[explorer-uss] paths will be served:
[explorer-uss]   - /ui/v1/explorer-uss => /root/zowe/1.5.0/uss_explorer/app
[explorer-uss] is started and listening on 8550...

/root/zowe/1.5.0/components/files-api/bin/validate.sh: line 36: oping: command not found
Error 0: ZOWE_EXPLORER_HOST
/root/zowe/1.5.0/components/files-api/bin/validate.sh: line 47: return: 1-0: numeric argument required
ZOWE_JAVA_HOME already exists on the PATH
2019-10-10 09:45:05.240 <ZWED:2613> root INFO (_zsf.cluster,clusterManager.js:509) Master 2613 is running.
2019-10-10 09:45:05.330 <ZWED:2613> root INFO (_zsf.cluster,clusterManager.js:173) Fork 2 workers.
2019-10-10 09:45:05.343 <ZWED:2613> root INFO (_zsf.cluster,clusterManager.js:111) Fork worker 0
2019-10-10 09:45:05.382 <ZWED:2613> root INFO (_zsf.cluster,clusterManager.js:111) Fork worker 1
2019-10-10 09:45:06.455 <ZWEADS1:main: > root INFO  (c.c.m.p.s.BuildInfo,BuildInfo.java:23) Service discovery-service version 1.1.9 #57 on null by b13bf66d104c commit 92b9fe3
2019-10-10 09:45:06.470 <ZWEAGW1:main: > root INFO  (c.c.m.p.s.BuildInfo,BuildInfo.java:23) Service gateway-service version 1.1.9 #57 on null by b13bf66d104c commit 92b9fe3
2019-10-10 09:45:07.096 <ZWEAAC1:main: > root INFO  (c.c.m.p.s.BuildInfo,BuildInfo.java:23) Service api-catalog-services version 1.1.9 #57 on null by b13bf66d104c commit 92b9fe3
2019-10-10 09:45:09.174 <ZWED:2717> root INFO (_zsf.cluster,clusterManager.js:514) Worker 1 pid 2717
2019-10-10 09:45:09.210 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: ../deploy -> /root/zowe/1.5.0/zlux-app-server/deploy
2019-10-10 09:45:09.232 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: ../deploy/product -> /root/zowe/1.5.0/zlux-app-server/deploy/product
2019-10-10 09:45:09.243 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: ../deploy/site -> /root/zowe/1.5.0/zlux-app-server/deploy/site
2019-10-10 09:45:09.244 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: ../deploy/instance -> /root/zowe/1.5.0/zlux-app-server/deploy/instance
2019-10-10 09:45:09.253 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: ../deploy/instance/groups -> /root/zowe/1.5.0/zlux-app-server/deploy/instance/groups
2019-10-10 09:45:09.254 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: ../deploy/instance/users -> /root/zowe/1.5.0/zlux-app-server/deploy/instance/users
2019-10-10 09:45:09.254 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: ../deploy/instance/ZLUX/plugins -> /root/zowe/1.5.0/zlux-app-server/deploy/instance/ZLUX/plugins
2019-10-10 09:45:09.255 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: ../bin/zssServer.sh -> /root/zowe/1.5.0/zlux-app-server/bin/zssServer.sh
2019-10-10 09:45:09.258 <ZWED:2717> root WARN (_zsf.bootstrap,auth-manager.js:57) RBAC is disabled in the configuration. All authenticated users will have access to all servces. Enable RBAC in the configuration to control users' access to individual services
2019-10-10 09:45:09.274 <ZWED:2717> root INFO (_zsf.bootstrap,index.js:150) Skip child process spawning on worker 1 /root/zowe/1.5.0/zlux-app-server/bin/zssServer.sh
2019-10-10 09:45:09.422 <ZWED:2717> root INFO (_zsf.network,webserver.js:144) HTTPS config valid, will listen on: 0.0.0.0
2019-10-10 09:45:09.443 <ZWED:2717> root INFO (_zsf.bootstrap,webserver.js:64) Using Certificate: /root/zowe/1.5.0/api-mediation/keystore/localhost/localhost.keystore.cer
2019-10-10 09:45:09.577 <ZWED:2712> root INFO (_zsf.cluster,clusterManager.js:514) Worker 0 pid 2712
2019-10-10 09:45:09.630 <ZWED:2712> root INFO (_zsf.utils,util.js:280) Resolved path: ../deploy -> /root/zowe/1.5.0/zlux-app-server/deploy
2019-10-10 09:45:09.638 <ZWED:2712> root INFO (_zsf.utils,util.js:280) Resolved path: ../deploy/product -> /root/zowe/1.5.0/zlux-app-server/deploy/product
2019-10-10 09:45:09.638 <ZWED:2712> root INFO (_zsf.utils,util.js:280) Resolved path: ../deploy/site -> /root/zowe/1.5.0/zlux-app-server/deploy/site
2019-10-10 09:45:09.638 <ZWED:2712> root INFO (_zsf.utils,util.js:280) Resolved path: ../deploy/instance -> /root/zowe/1.5.0/zlux-app-server/deploy/instance
2019-10-10 09:45:09.639 <ZWED:2712> root INFO (_zsf.utils,util.js:280) Resolved path: ../deploy/instance/groups -> /root/zowe/1.5.0/zlux-app-server/deploy/instance/groups
2019-10-10 09:45:09.639 <ZWED:2712> root INFO (_zsf.utils,util.js:280) Resolved path: ../deploy/instance/users -> /root/zowe/1.5.0/zlux-app-server/deploy/instance/users
2019-10-10 09:45:09.640 <ZWED:2712> root INFO (_zsf.utils,util.js:280) Resolved path: ../deploy/instance/ZLUX/plugins -> /root/zowe/1.5.0/zlux-app-server/deploy/instance/ZLUX/plugins
2019-10-10 09:45:09.640 <ZWED:2712> root INFO (_zsf.utils,util.js:280) Resolved path: ../bin/zssServer.sh -> /root/zowe/1.5.0/zlux-app-server/bin/zssServer.sh
2019-10-10 09:45:09.645 <ZWED:2717> root INFO (_zsf.install,webapp.js:1101) installing root service proxy at /login
2019-10-10 09:45:09.661 <ZWED:2712> root WARN (_zsf.bootstrap,auth-manager.js:57) RBAC is disabled in the configuration. All authenticated users will have access to all servces. Enable RBAC in the configuration to control users' access to individual services
2019-10-10 09:45:09.690 <ZWED:2717> root INFO (_zsf.install,webapp.js:1101) installing root service proxy at /unixfile
2019-10-10 09:45:09.690 <ZWED:2717> root INFO (_zsf.install,webapp.js:1101) installing root service proxy at /datasetContents
2019-10-10 09:45:09.706 <ZWED:2717> root INFO (_zsf.install,webapp.js:1101) installing root service proxy at /VSAMdatasetContents
2019-10-10 09:45:09.706 <ZWED:2717> root INFO (_zsf.install,webapp.js:1101) installing root service proxy at /datasetMetadata
2019-10-10 09:45:09.707 <ZWED:2717> root INFO (_zsf.install,webapp.js:1101) installing root service proxy at /omvs
2019-10-10 09:45:09.712 <ZWED:2717> root INFO (_zsf.install,webapp.js:1101) installing root service proxy at /ras
2019-10-10 09:45:09.712 <ZWED:2717> root INFO (_zsf.install,webapp.js:1101) installing root service proxy at /security-mgmt
2019-10-10 09:45:09.712 <ZWED:2717> root INFO (_zsf.install,webapp.js:1101) installing root service proxy at /saf-auth
2019-10-10 09:45:09.714 <ZWED:2717> root INFO (_zsf.install,webapp.js:1093) installing root service at /auth
2019-10-10 09:45:09.715 <ZWED:2717> root INFO (_zsf.install,webapp.js:1093) installing root service at /auth
2019-10-10 09:45:09.715 <ZWED:2717> root INFO (_zsf.install,webapp.js:1093) installing root service at /auth-refresh
2019-10-10 09:45:09.716 <ZWED:2717> root INFO (_zsf.install,webapp.js:1093) installing root service at /auth-logout
2019-10-10 09:45:09.716 <ZWED:2717> root INFO (_zsf.install,webapp.js:1093) installing root service at /auth-logout
2019-10-10 09:45:09.717 <ZWED:2717> root INFO (_zsf.install,webapp.js:1093) installing root service at /plugins
2019-10-10 09:45:09.717 <ZWED:2717> root INFO (_zsf.install,webapp.js:1093) installing root service at /plugins
2019-10-10 09:45:09.722 <ZWED:2717> root INFO (_zsf.install,webapp.js:1093) installing root service at /server/proxies
2019-10-10 09:45:09.741 <ZWED:2717> root INFO (_zsf.install,webapp.js:1093) installing root service at /server
2019-10-10 09:45:09.742 <ZWED:2717> root INFO (_zsf.install,webapp.js:1093) installing root service at /echo/*
2019-10-10 09:45:09.743 <ZWED:2717> root INFO (_zsf.install,webapp.js:1093) installing root service at /apiManagement
2019-10-10 09:45:09.751 <ZWED:2717> root INFO (_zsf.network,webserver.js:237) (HTTPS)  About to start listening on 0.0.0.0:8544
2019-10-10 09:45:09.786 <ZWED:2717> root INFO (_zsf.bootstrap,plugin-loader.js:609) Reading plugins dir /root/zowe/1.5.0/zlux-app-server/deploy/instance/ZLUX/plugins
2019-10-10 09:45:09.814 <ZWED:2712> root INFO (_zsf.network,webserver.js:144) HTTPS config valid, will listen on: 0.0.0.0
2019-10-10 09:45:09.832 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: org.zowe.api.catalog.json -> /root/zowe/1.5.0/zlux-app-server/deploy/instance/ZLUX/plugins/org.zowe.api.catalog.json
2019-10-10 09:45:09.837 <ZWED:2717> root INFO (_zsf.bootstrap,plugin-loader.js:572) Processing plugin reference /root/zowe/1.5.0/zlux-app-server/deploy/instance/ZLUX/plugins/org.zowe.api.catalog.json...
2019-10-10 09:45:09.838 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: ../../api_catalog -> /root/zowe/1.5.0/api_catalog
2019-10-10 09:45:09.836 <ZWED:2712> root INFO (_zsf.bootstrap,webserver.js:64) Using Certificate: /root/zowe/1.5.0/api-mediation/keystore/localhost/localhost.keystore.cer
2019-10-10 09:45:09.855 <ZWED:2717> root INFO (_zsf.bootstrap,plugin-loader.js:601) Read /root/zowe/1.5.0/api_catalog: found plugin id = org.zowe.api.catalog, type = application
2019-10-10 09:45:09.855 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: org.zowe.configjs.json -> /root/zowe/1.5.0/zlux-app-server/deploy/instance/ZLUX/plugins/org.zowe.configjs.json
2019-10-10 09:45:09.866 <ZWED:2712> root INFO (_zsf.child,process.js:50) [Path=/root/zowe/1.5.0/zlux-app-server/bin/zssServer.sh stdout]: pwd = /root/zowe/1.5.0/zlux-app-server/lib
Script dir = /root/zowe/1.5.0/zlux-app-server/bin
2019-10-10 09:45:09.856 <ZWED:2717> root INFO (_zsf.bootstrap,plugin-loader.js:572) Processing plugin reference /root/zowe/1.5.0/zlux-app-server/deploy/instance/ZLUX/plugins/org.zowe.configjs.json...
2019-10-10 09:45:09.868 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: ../../zlux-server-framework/plugins/config -> /root/zowe/1.5.0/zlux-server-framework/plugins/config
2019-10-10 09:45:09.871 <ZWED:2717> root INFO (_zsf.bootstrap,plugin-loader.js:601) Read /root/zowe/1.5.0/zlux-server-framework/plugins/config: found plugin id = org.zowe.configjs, type = application
2019-10-10 09:45:09.872 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: org.zowe.editor.json -> /root/zowe/1.5.0/zlux-app-server/deploy/instance/ZLUX/plugins/org.zowe.editor.json
2019-10-10 09:45:09.873 <ZWED:2717> root INFO (_zsf.bootstrap,plugin-loader.js:572) Processing plugin reference /root/zowe/1.5.0/zlux-app-server/deploy/instance/ZLUX/plugins/org.zowe.editor.json...
2019-10-10 09:45:09.874 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: ../../zlux-editor -> /root/zowe/1.5.0/zlux-editor
2019-10-10 09:45:09.882 <ZWED:2717> root INFO (_zsf.bootstrap,plugin-loader.js:601) Read /root/zowe/1.5.0/zlux-editor: found plugin id = org.zowe.editor, type = application
2019-10-10 09:45:09.883 <ZWED:2717> root INFO (_zsf.utils,util.js:280) Resolved path: org.zowe.explorer-jes.json -> /root/zowe/1.5.0/zlux-app-server/deploy/instance/ZLUX/plugins/org.zowe.explorer-jes.json
2019-10-10 09:45:09.889 <ZWED:2717> root INFO (_zsf.bootstrap,plugin-loader.js:572) Processing plugin reference /root/zowe/1.5.0/zlux-app-server/deploy/instance/ZLUX/plugins/org.zowe.explorer-jes.json...
```

## Test it
Open browser and test it
 - API Mediation Layer: https://mf.acme.net:60004
 - ZAF: https://mf.acme.net:60014
