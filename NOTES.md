Inspired by https://github.com/jensgertsen/sparkkiosk

After upgrading docker, might have to...
```
docker buildx create --use
```

```sh
docker buildx build --platform linux/arm64,linux/amd64 --tag horologger/albyhub:v0.4.2 --output "type=registry" .


docker buildx build --platform linux/arm64 --tag horologger/albyhub:v0.4.2 --load .
docker buildx build --platform linux/amd64 --tag horologger/albyhub:v0.4.2 --load .

docker buildx build --platform linux/arm64 --tag horologger/albyhub-startos:v0.4.2 --load .

```

On UmbrelPi
```sh
ssh umbrelpi

export sparkkioskid=$(docker container list | grep sparkkiosk_web_1 | cut -d ' ' -f 1)

docker exec -it $sparkkioskid /bin/bash

set

APP_PASSWORD=5587e4a23eec8a783c88cac48c1ca8f5fdf5ca3b3b2ad0ea4c8596e8e1c5f901
APP_HIDDEN_SERVICE=http://mc3irxqk3ygz6vtrq3xbjbtk5f6mzyqdi6y7gl5j24zh2ibjtdoeujqd.onion

LND_GRPC_CERT=/lnd/tls.cert
LND_GRPC_ENDPOINT=10.21.21.9
LND_GRPC_MACAROON=/lnd/data/chain/bitcoin/mainnet/admin.macaroon
LND_GRPC_PORT=10009

sudo ./umbrel/scripts/repo checkout https://github.com/horologger/umbrelappstore.git
sudo ./umbrel/scripts/app install isviable-timeintocrypto
sudo ./umbrel/scripts/app start isviable-timeintocrypto
sudo ./umbrel/scripts/app restart isviable-timeintocrypto

```
On Zilla
```sh
su - alunde
docker pull horologger/albyhub:v0.4.2
mkdir -p ~/.timeintocrypto/data
```
First run
```
docker run \
-e PORT=21284 \
-v data:/data \
-p 21284:21284 \
--name timeintocrypto \
-it horologger/albyhub:v0.4.2
```

On Ragnar
```sh
su - alunde
docker pull horologger/albyhub:v0.4.2
mkdir -p ~/.timeintocrypto/data
```
First run
```
docker run \
-e LN_BACKEND_TYPE="LND" \
-e LND_ADDRESS=$APP_LIGHTNING_NODE_IP:$APP_LIGHTNING_NODE_GRPC_PORT \
-e LND_CERT_FILE="/lnd/tls.cert" \
-e LND_MACAROON_FILE="/lnd/data/chain/bitcoin/$APP_BITCOIN_NETWORK/admin.macaroon" \
-e WORK_DIR="/data/albyhub" \
-e COOKIE_SECRET="666" \
-v /home/alunde/albyhub/data:/data \
-v /t4/lnd:/lnd:ro \
-p 8080:8080 \
--name nwc \
-it horologger/albyhub:v0.4.2
```
Subsequent runs
```sh
docker run \
-e LN_BACKEND_TYPE="LND" \
-e LND_ADDRESS=ragnar:10009 \
-e LND_CERT_FILE="/lnd/tls.cert" \
-e LND_MACAROON_FILE="/lnd/data/chain/bitcoin/bitcoin/admin.macaroon" \
-e WORK_DIR="/data/albyhub" \
-e COOKIE_SECRET="666" \
-v /data:/data \
-v /lnd-data:/lnd:ro \
-p 8080:8080 \
--name nwc \
-it horologger/albyhub:v0.4.2

docker run \
-e LN_BACKEND_TYPE="LND" \
-e LND_ADDRESS=ragnar:10009 \
-e LND_CERT_FILE="/lnd/tls.cert" \
-e LND_MACAROON_FILE="/lnd/data/chain/bitcoin/mainnet/admin.macaroon" \
-e WORK_DIR="/data/albyhub" \
-e COOKIE_SECRET="666" \
-v data:/data \
-v lnd-data:/lnd:ro \
-p 8080:8080 \
--name nwc \
-it horologger/albyhub:v0.4.2

```
Inspect
```sh
docker exec -it nwc /bin/bash
```
Clean up
```sh
docker stop nwc
docker rm nwc
```
