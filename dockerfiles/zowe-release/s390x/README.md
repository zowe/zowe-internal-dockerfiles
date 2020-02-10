# Zowe on LinuxONE / zCX for 

Cryptic how to run Zowe in IBM LinuxONE environment. LinuxONE environment has s390x architecture.

1) How to get LinuxONE environment follow [Getting Started with Linux on Mainframe](https://levelup.gitconnected.com/getting-started-with-linux-on-mainframe-fcd4b19d147d) by Petr Plavjanik.
   * obtain an instance of [LinuxONE](https://linuxone.cloud.marist.edu/cloud/#/index)
1) obtain a domain and map it to LinuxONE IP address
1) obtain [Let's Encrypt](https://letsencrypt.org/) certificate
   1) install certbot
      ```sh
      sudo yum install python3 python3-devel libffi-devel openssl-devel
      sudo pip3 install certbot
      ```
   1) open port 80 for cert bot
      ```sh
      sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT 
      ```
   1) obtain certificate (i did it for `zowe.vvvlcek.info`)
      ```sh
      sudo /usr/local/bin/certbot certonly --standalone
      ```
1) prepare certificates for Zowe
    ```sh
    mkdir -p /home/linux1/zowe/cert/
    sudo openssl pkcs12 -export -in /etc/letsencrypt/live/zowe.vvvlcek.info/fullchain.pem -inkey /etc/letsencrypt/live/zowe.vvvlcek.info/privkey.pem -name apiml  -passout pass:password > /home/linux1/zowe/cert/server.p12
    sudo openssl x509 -outform der -in /etc/letsencrypt/live/zowe.vvvlcek.info/chain.pem -out /home/linux1/zowe/cert/letsencrypt.cer
    sudo openssl x509 -outform der -in /etc/letsencrypt/live/zowe.vvvlcek.info/cert.pem -out /home/linux1/zowe/cert/server.cer
    cd /home/linux1/zowe/cert/
    sudo chown linux1:linux1 *
    ```
1) install docker 
1) build zowe docker image 
    ```sh
    cd docker-slim-java-node
    docker build . 
    cd ../zowe-1.7.1
    docker build . 
    ```
1) open ports for Zowe
    ```sh
    sudo iptables -I INPUT -p tcp --dport 8544 -j ACCEPT 
    sudo iptables -I INPUT -p tcp --dport 7552 -j ACCEPT 
    sudo iptables -I INPUT -p tcp --dport 7553 -j ACCEPT 
    sudo iptables -I INPUT -p tcp --dport 7554 -j ACCEPT 
    sudo iptables -I INPUT -p tcp --dport 8545 -j ACCEPT 
    sudo iptables -I INPUT -p tcp --dport 8547 -j ACCEPT 
    sudo iptables -I INPUT -p tcp --dport 1443 -j ACCEPT 
    ```
1) run Zowe docker container
    ```sh
    sudo docker run -it  -h "zowe.vvvlcek.info" \
        -p 8544:8544 -p 7552:7552 -p 7553:7553 \
        -p 7554:7554 -p 8545:8545 -p 8547:8547 \
        -p 1443:1443 --env "LAUNCH_COMPONENT_GROUPS=GATEWAY,DESKTOP" \
        -v "/home/linux1/zowe/cert/:/root/zowe/certs" --name "zowe" --rm \
        vvvlc/zowe:latest
    ```
    For details see [/dockerfiles/zowe-release/s390x/zowe-1.7.1/README.md](/dockerfiles/zowe-release/s390x/zowe-1.7.1/README.md)
1) test it
    * gateway url: https://zowe.vvvlcek.info:7554/
    * uss explorer: https://zowe.vvvlcek.info:7554/ui/v1/explorer-uss/#/
    * jse explorer: https://zowe.vvvlcek.info:7554/ui/v1/explorer-jes/#/