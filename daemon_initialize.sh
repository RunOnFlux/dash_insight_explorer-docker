#!/bin/bash
#color codes
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE="\\033[38;5;27m"
SEA="\\033[38;5;49m"
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

#emoji codes
CHECK_MARK="${GREEN}\xE2\x9C\x94${NC}"
X_MARK="${RED}\xE2\x9C\x96${NC}"
PIN="${RED}\xF0\x9F\x93\x8C${NC}"
CLOCK="${GREEN}\xE2\x8C\x9B${NC}"
ARROW="${SEA}\xE2\x96\xB6${NC}"
BOOK="${RED}\xF0\x9F\x93\x8B${NC}"
HOT="${ORANGE}\xF0\x9F\x94\xA5${NC}"
WORNING="${RED}\xF0\x9F\x9A\xA8${NC}"

PATH_BIN="root"
PROJ_NAME="dashpay/dash"
PACKAGE="x86_64-linux-gnu.tar.gz$"
COIN="dashcore"
COIN_NAME="dash"
ARCHIVE_REGEX="dashcore-[0-9]*"
INSIGHT_API="@dashevo/insight-api"
INSIGHT_UI="@dashevo/insight-ui"
DAEMON_BIN="dashd"
CORE_NODE_URL="https://github.com/dashevo/dashcore-node"
RPC_PORT="9988"

DOWN_URL=$(curl --silent "https://api.github.com/repos/$PROJ_NAME/releases/latest" | jq -r '.assets[] | .browser_download_url' | grep -e "$PACKAGE")
VERSION=$(curl --silent "https://api.github.com/repos/$PROJ_NAME/releases/latest" | jq -r .tag_name)

export PATH=/usr/bin:$PATH

function extract_file() {
    local extraction_dir="./"
    if [ -n "$2" ]; then
        extraction_dir="$2"
    fi

    if [[ $1 =~ .*zip$ ]]; then
        unzip $1 -d ${extraction_dir} > /dev/null 2>&1 || return 1
    elif [[ $1 =~ .*tar.gz$ ]]; then
        tar zxf $1 -C ${extraction_dir} > /dev/null 2>&1 || return 1
    fi
    return 0
}

function update_daemon(){
if [[ ! -f /$PATH_BIN/.$COIN/$COIN-node/daemon/version.json ]]; then
  echo -e "${ARROW} ${YELLOW}Installing $COIN daemon...${NC}"
  mkdir -p /$PATH_BIN/.$COIN/$COIN-node/daemon/tmp > /dev/null 2>&1
  wget --tries=5 $DOWN_URL -P /$PATH_BIN/.$COIN/$COIN-node/daemon/tmp > /dev/null 2>&1
  jq -n --arg version $VERSION  '{"version":"\($version)"}' > /$PATH_BIN/.$COIN/$COIN-node/daemon/version.json
  cd /$PATH_BIN/.$COIN/$COIN-node/daemon/tmp
  targz_file=$(find ./"$COIN"* -type f -name '*.tar.gz' 2>/dev/null)
  extract_file ${targz_file}
  mv -f $(find . -type d -name "$ARCHIVE_REGEX" 2>/dev/null)/bin/* /$PATH_BIN/.$COIN/$COIN-node/daemon/
  chmod +x /$PATH_BIN/.$COIN/$COIN-node/daemon/* > /dev/null 2>&1
  rm -rf /$PATH_BIN/.$COIN/$COIN-node/daemon/tmp > /dev/null 2>&1
else
  echo -e "${ARROW} ${YELLOW}Checking daemon update...${NC}"
  local_version=$(jq -r .version /$PATH_BIN/.$COIN/$COIN-node/daemon/version.json)
  echo -e "${ARROW} ${YELLOW}Local: ${GREEN}$local_version${YELLOW}, Remote: ${GREEN}$VERSION ${NC}"
  if [[ "$VERSION" != "" && "$local_version" != "$VERSION" ]]; then
    echo -e "${ARROW} ${YELLOW}New version detected: ${GREEN}$VERSION ${NC}"
    wget --tries=5 $DOWN_URL -P /$PATH_BIN/.$COIN/$COIN-node/daemon/tmp > /dev/null 2>&1
    rm /$PATH_BIN/.$COIN/$COIN-node/daemon/version.json > /dev/null 2>&1
    jq -n --arg version $VERSION  '{"version":"\($version)"}' > /$PATH_BIN/.$COIN/$COIN-node/daemon/version.json
    cd /$PATH_BIN/.$COIN/$COIN-node/daemon/bin/tmp
    targz_file=$(find ./"$COIN"* -type f -name '*.tar.gz' 2>/dev/null)
    extract_file ${targz_file}
    mv -f $(find . -type d -name "$ARCHIVE_REGEX" 2>/dev/null)/bin/* /$PATH_BIN/.$COIN/$COIN-node/daemon/
    chmod +x /$PATH_BIN/.$COIN/$COIN-node/daemon/* > /dev/null 2>&1
    rm -rf /$PATH_BIN/.$COIN/$COIN-node/daemon/tmp > /dev/null 2>&1
  fi
fi
}

cd /$PATH_BIN/
DDIR="/$PATH_BIN/.$COIN/$COIN-node/bin"
if [ -d $DDIR ]; then
  echo -e "${ARROW} ${YELLOW}Core node already installed...${NC}"
else
  #core-node
  apt update -y && apt install -y build-essential python3 g++ make > /dev/null 2>&1
  mkdir -p /$PATH_BIN/.$COIN > /dev/null 2>&1
  cd /$PATH_BIN/.$COIN
  echo -e "${ARROW} ${YELLOW}Installing $COIN-node...${NC}"
  git clone $CORE_NODE_URL > /dev/null 2>&1
  cd $COIN-node
  sed -i "s|var npm = spawn('npm', \['install'\], {cwd: absConfigDir});|var npm = spawn('npm', ['install', '--build-from-source', '--loglevel', 'verbose'], { cwd: absConfigDir, env: Object.assign({}, process.env, { npm_config_build_from_source: 'true', npm_config_loglevel: 'verbose' }) });|" lib/scaffold/create.js
  npm install
  ./bin/$COIN-node create mynode
  cd mynode
  rm $COIN-node.json > /dev/null 2>&1
  echo -e "${ARROW} ${YELLOW}Creating ${COIN} config file...${NC}"
  if [[ "$DB_COMPONENT_NAME" == "" ]]; then
    echo -e "${ARROW} ${CYAN}Set default value of DB_COMPONENT_NAME${NC}"
    DB_COMPONENT_NAME="fluxmongodb_dash_insight_explorer"
  else
    echo -e "${ARROW} ${CYAN}DB_COMPONENT_NAME as host is ${GREEN}${DB_COMPONENT_NAME}${NC}"
  fi
  rm /$PATH_BIN/.$COIN/$COIN-node/$COIN-node.json > /dev/null 2>&1

cat << EOF > /$PATH_BIN/.$COIN/$COIN-node/$COIN-node.json
{
  "network": "livenet",
  "port": 3001,
  "services": [
    "${DAEMON_BIN}",
    "web",
    "${INSIGHT_API}",
    "${INSIGHT_UI}"
  ],
  "messageLog": "",
  "servicesConfig": {
    "web": {
      "disablePolling": false,
      "enableSocketRPC": true,
      "disableCors": true
    },
    "${INSIGHT_UI}": {
      "routePrefix": "",
      "apiPrefix": "api"
    },
    "${INSIGHT_API}": {
      "routePrefix": "api",
      "db": {
        "host": "${DB_COMPONENT_NAME}",
        "port": "27017",
        "database": "$COIN_NAME-api-livenet",
        "user": "",
        "password": ""
      }
    },
    "${DAEMON_BIN}": {
      "sendTxLog": "./data/pushtx.log",
      "spawn": {
        "datadir": "./data",
        "exec": "/$PATH_BIN/.$COIN/$COIN-node/daemon/$DAEMON_BIN"
      }
    }
  }
}
EOF
rm -rf /$PATH_BIN/.$COIN/$COIN-node/data/$COIN_NAME.conf > /dev/null 2>&1
mkdir -p /$PATH_BIN/.$COIN/$COIN-node/daemon > /dev/null 2>&1
mkdir -p /$PATH_BIN/.$COIN/$COIN-node/data > /dev/null 2>&1
echo -e "${ARROW} ${YELLOW}Creating $COIN_NAME daemon config file...${NC}"
RPCUSER=$(pwgen -1 8 -n)
PASSWORD=$(pwgen -1 20 -n)
cat << EOF > /$PATH_BIN/.$COIN/$COIN-node/data/$COIN_NAME.conf
server=1
whitelist=127.0.0.1
txindex=1
addressindex=1
timestampindex=1
spentindex=1
zmqpubrawtx=tcp://127.0.0.1:28332
zmqpubhashblock=tcp://127.0.0.1:28332
zmqpubrawtxlock=tcp://127.0.0.1:28332
rpcport=$RPC_PORT
rpcallowip=127.0.0.1
rpcuser=$RPCUSER
rpcpassword=$PASSWORD
rpcworkqueue=1000
EOF
../bin/dashcore-node install "$INSIGHT_API"
../bin/dashcore-node install "$INSIGHT_UI"
fi
update_daemon
cd /$PATH_BIN/.$COIN/$COIN-node/mynode
while true; do
echo -e "${ARROW} ${YELLOW}Starting $COIN_NAME insight explorer...${NC}"
echo -e ""
bash -i -c "../bin/$COIN-node start"
sleep 60
done
