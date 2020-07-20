# Zowe Docker file

## Requirements
 - docker
 - z/OSMF up and running
 - ZSS and ZSS Cross memory server up and running

**TL;DR**:
```sh
docker pull rsqa/zowe-v1-lts:s390x
docker run -it \
    -p 7553:7553 \
    -p 7554:7554 \
    -p 8544:8544 \
    -h myhost.acme.net \
    --env ZOWE_IP_ADDRESS=your.non.loopback.ip \
    --env LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY \
    --env ZOSMF_HOST=your.zosmainframe.com \
    --env ZWED_agent_host=your.zosmainframe.com \
    --env ZOSMF_PORT=11443 \
    --env ZWED_agent_http_port=8542 \
    --mount type=bind,source=c:\temp\certs,target=/root/zowe/certs vvvlc/ \
    rsqa/zowe-v1-lts:s390x
```
Open browser and test it
 - API Mediation Layer: https://myhost.acme.net:60004
 - ZAF: https://myhost.acme.net:60014

## Building docker image
### Building docker image on Linux
Navigate to any subfolder of zowe-release for your computer architecture, such as s390x for zlinux or s390x for intel linux.
For example, with a zlinux machine, to build v1 LTS you can execute:
```sh
cd dockerfiles/zowe-release/s390x/zowe-v1-lts
docker build -t zowe/docker:latest .
```

## Executing Zowe Docker Container 
 - prepare folder with certificates, you should have it from previous step.
 - adjust `docker start` command
   - `-h <hostname>` - hostname of docker host (hostname of your laptop eg: myhost.acme.net)
   - `ZOWE_IP_ADDRESS=<ip>` - The IP which the servers should bind to. Should not be a loopback address.
   - `ZOSMF_HOST=<zosmf_hostname>` - z/OSMF hostname (eg mf.acme.net)
   - `ZOSMF_PORT=<zosmf_port>` - z/OSMF port eg (1443)
   - `ZWED_agent_host=<zss_hostname>` - ZSS host (eg mf.acme.net)
   - `ZWED_agent_http_port=<zss_port>` - ZSS port z/OSMF port eg (60012)
   - `source=<folder with certs>` - folder where you have your certs
   - `LAUNCH_COMPONENT_GROUPS=<DESKTOP or GATEWAY>` - what do you want to start
     - DESKTOP - only desktop
     - GATEWAY - only GATEWAY + explorers
     - GATEWAY,DESKTOP - both 

For example:

```cmd
docker run -it -p 60004:60004 -p 60014:8544 -h <hostname> --env ZOWE_ZOSMF_HOST=<zosmf_hostname> --env ZOWE_ZOSMF_PORT=<zosmf_port> --env ZWED_agent_host=<zss_hostname> --env ZWED_agent_http_port=<zss_port> --env LAUNCH_COMPONENT_GROUPS=<DESKTOP or GATEWAY> --mount type=bind,source=<folder with certs>,target=/root/zowe/certs zowe/docker:latest
```

If you want to 
 - use it with different z/OSMF and ZSS change `ZOWE_ZOSMF_xxx` and `ZOWE_ZSS_xxx`
 - start only a component change `LAUNCH_COMPONENT_GROUPS`
 - run it on differen machine
    - move image to different machine
    -  execute `docker start` with updated `-h <hostname>`

### Linux
```cmd
docker run -it \
    -p 60003:7553 \
    -p 60004:7554 \
    -p 60014:8544 \
    -h myhost.acme.net \
    --env ZOWE_IP_ADDRESS=your.non.loopback.ip \
    --env LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY \
    --env ZOSMF_HOST=your.zosmainframe.com \
    --env ZWED_agent_host=your.zosmainframe.com \
    --env ZOSMF_PORT=11443 \
    --env ZWED_agent_http_port=8542 \
    --mount type=bind,source=/home/john/certs,target=/root/zowe/certs \
    rsqa/zowe-v1-lts:s390x
```

#### Expected output
When running, the output will be very similar to what would be seen on a z/OS install, such as:

```
put something here
```

## Test it
Open browser and test it
 - API Mediation Layer: https://mf.acme.net:60004
 - API ML Discovery Service: https://mf.acme.net:60003/
 - ZAF: https://mf.acme.net:60014

## Using Zowe's Docker with Zowe products & plugins
To use Zowe-based software with the docker container, you must make that software visible to the Zowe that is within Docker by mapping a folder on your host machine to a folder visible within the docker container.
This concept is known as Docker volumes. After sharing a volume, standard Zowe utilities for installing & using plugins will apply.

To share a host directory *HOST_DIR* into the docker container destination directory *CONTAINER_DIR* with read-write access, simply add this line to your docker run command: `-v [HOST_DIR]:[CONTAINER_DIR]:rw`
You can have multiple such volumes, but for Zowe Application Framework plugins, the value of *CONTAINER_DIR* should be `/root/zowe/apps`

An example is to add Apps to the Zowe Docker by sharing the host directory `~/apps`, which full of Application Framework plugins.

```cmd
docker run -it \
    -p 7554:7554 \
    -p 8544:8544 \
	-p 7553:7553 \
    -h myhost.acme.net \
    --env ZOWE_IP_ADDRESS=your.non.loopback.ip \
    --env LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY \
    --env ZOSMF_HOST=your.zosmainframe.com \
    --env ZWED_agent_host=your.zosmainframe.com \
    --env ZOSMF_PORT=11443 \
    --env ZWED_agent_http_port=8542 \
	-v ~/apps:/root/zowe/apps:rw \
    rsqa/zowe-v1-lts:s390x
```

Afterward, these plugins must be installed to the app server. Simply ssh into the docker container to run the install-app.sh script, like so:
```docker exec -it [CONTAINER_ID] /root/zowe/instance/bin/install-app.sh ../../apps/[APPLICATION]```
If the script returns with rc=0, then the plugin install succeded and the plugin can be used by refreshing the app server via either clicking "Refresh Applications" in the launchbar menu of the Zowe Desktop, or by doing an HTTP GET call to /plugins?refresh=true to the app server.
