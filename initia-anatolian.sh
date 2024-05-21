#!/bin/bash

# 
#  █████╗ ███╗   ██╗ █████╗ ████████╗ ██████╗ ██╗     ██╗ █████╗ ███╗   ██╗    ████████╗███████╗ █████╗ ███╗   ███╗
# ██╔══██╗████╗  ██║██╔══██╗╚══██╔══╝██╔═══██╗██║     ██║██╔══██╗████╗  ██║    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
# ███████║██╔██╗ ██║███████║   ██║   ██║   ██║██║     ██║███████║██╔██╗ ██║       ██║   █████╗  ███████║██╔████╔██║
# ██╔══██║██║╚██╗██║██╔══██║   ██║   ██║   ██║██║     ██║██╔══██║██║╚██╗██║       ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║
# ██║  ██║██║ ╚████║██║  ██║   ██║   ╚██████╔╝███████╗██║██║  ██║██║ ╚████║       ██║   ███████╗██║  ██║██║ ╚═╝ ██║
# ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚══════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝       ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
#

echo "Choose an option:"
echo "1- Node Installation"
echo "2- Snapshot"
echo "3- State-Sync"
echo "4- Delete Node"
read -p "Enter your choice (1, 2, 3, or 4): " choice

case $choice in
  1)
    # Node Installation
    read -p "Enter your validator name: " INITIA_NODENAME
    read -p "Enter your wallet name: " INITIA_WALLET
    read -p "Enter the port number (example: 26 etc.): " INITIA_PORT

    # Setting Variables
    echo "Setting variables..."
    echo "export INITIA_NODENAME=$INITIA_NODENAME" >> $HOME/.bash_profile
    echo "export INITIA_WALLET=$INITIA_WALLET" >> $HOME/.bash_profile
    echo "export INITIA_PORT=$INITIA_PORT" >> $HOME/.bash_profile
    echo "export INITIA_CHAIN_ID=initiation-1" >> $HOME/.bash_profile
    source $HOME/.bash_profile

    # Updating the System
    echo "Updating the system..."
    sudo apt update && apt upgrade -y

    # Installing the Necessary Libraries
    echo "Installing necessary libraries..."
    sudo apt install make clang pkg-config libssl-dev libclang-dev build-essential git curl ntp jq llvm tmux htop screen gcc lz4 -y < "/dev/null"

    # Installing Go
    echo "Installing Go..."
    ver="1.22.2"
    arch=$(uname -m)
    if [ "$arch" == "x86_64" ]; then
        wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
        tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
        rm -rf "go$ver.linux-amd64.tar.gz"
    else
        wget "https://golang.org/dl/go$ver.linux-arm64.tar.gz"
        tar -C /usr/local -xzf "go$ver.linux-arm64.tar.gz"
        rm -rf "go$ver.linux-arm64.tar.gz"
    fi
    rm -rf /usr/local/go
    echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
    echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
    echo 'export GO111MODULE=on' >> $HOME/.bash_profile
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
    source $HOME/.bash_profile
    go version

    # Installing Initia
    echo "Installing Initia..."
    cd $HOME
    git clone https://github.com/initia-labs/initia.git
    cd initia
    git checkout v0.2.15
    make install

    # Configuring and Launching the Node
    echo "Configuring and launching the node..."
    initiad config set client chain-id $INITIA_CHAIN_ID
    initiad config set client keyring-backend test
    initiad init --chain-id $INITIA_CHAIN_ID $INITIA_NODENAME

    # Copying the Genesis and addrbook Files
    echo "Copying the Genesis and addrbook files..."
    wget https://testnet.anatolianteam.com/initia/genesis.json -O $HOME/.initia/config/genesis.json
    wget https://testnet.anatolianteam.com/initia/addrbook.json -O $HOME/.initia/config/addrbook.json

    # Set up the minimum gas price
    echo "Setting up the minimum gas price..."
    sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.15uinit,0.01uusdc"|g' $HOME/.initia/config/app.toml

    # Closing Indexer-Optional
    indexer="null"
    sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.initia/config/config.toml

    # Set up SEED and PEERS
    SEEDS="2eaa272622d1ba6796100ab39f58c75d458b9dbc@34.142.181.82:26656,c28827cb96c14c905b127b92065a3fb4cd77d7f6@testnet-seeds.whispernode.com:25756"
    PEERS="aee7083ab11910ba3f1b8126d1b3728f13f54943@initia-testnet-peer.itrocket.net:11656,d17d2d48b4741b21b16cba7aa5a0496151dec2e3@65.109.37.125:26656,767fdcfdb0998209834b929c59a2b57d474cc496@207.148.114.112:26656,72b8b9f0e826fa9be3f5ab55f56e67d409f0cef8@185.197.250.199:51656,9f0ae0790fae9a2d327d8d6fe767b73eb8aa5c48@176.126.87.65:22656,e43ce5800e48df7917942191c95276cb88bdd699@212.90.121.127:51656,7317b8c930c52a8183590166a7b5c3599f40d4db@185.187.170.186:26656,b79874ca9607e5d4a3fd730617cca863ff9f590e@5.78.116.66:26656,b8fcc8886246b3bd6058583a8017a7f987d7437e@185.182.186.46:26656,a45314423c15f024ff850fad7bd031168d937931@162.62.219.188:26656,00bf6d94bc8bae9d75c29a9bb198eaa401d34f4d@95.216.216.74:15656"
    sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.initia/config/config.toml
    sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 150/g' $HOME/.initia/config/config.toml
    sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 150/g' $HOME/.initia/config/config.toml

    # Enabling Prometheus
    echo "Enabling Prometheus..."
    sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.initia/config/config.toml

    # Set up Pruning 
    echo "Setting up pruning..."
    pruning="custom"
    pruning_keep_recent="100"
    pruning_keep_every="0"
    pruning_interval="50"
    sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.initia/config/app.toml
    sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.initia/config/app.toml
    sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.initia/config/app.toml
    sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.initia/config/app.toml

    # Set up Ports
    echo "Setting up ports..."
    sed -i.bak -e "
    s%:26658%:${INITIA_PORT}658%g;
    s%:26657%:${INITIA_PORT}657%g;
    s%:6060%:${INITIA_PORT}060%g;
    s%:26656%:${INITIA_PORT}656%g;
    s%:26660%:${INITIA_PORT}660%g
    " $HOME/.initia/config/config.toml
    sed -i.bak -e "
    s%:1317%:${INITIA_PORT}317%g; 
    s%:8080%:${INITIA_PORT}080%g; 
    s%:9090%:${INITIA_PORT}090%g; 
    s%:9091%:${INITIA_PORT}091%g
    " $HOME/.initia/config/app.toml
    sed -i.bak -e "s%:26657%:${INITIA_PORT}657%g" $HOME/.initia/config/client.toml

    # Adding External Address
    PUB_IP=$(curl -s -4 icanhazip.com)
    sed -e "s|external_address = \".*\"|external_address = \"$PUB_IP:${INITIA_PORT}656\"|g" ~/.initia/config/config.toml > ~/.initia/config/config.toml.tmp
    mv ~/.initia/config/config.toml.tmp  ~/.initia/config/config.toml

    # Creating the Service File
    echo "Creating the service file..."
    tee /etc/systemd/system/initiad.service > /dev/null << EOF
    [Unit]
    Description=Initia Node
    After=network-online.target

    [Service]
    User=$USER
    ExecStart=$(which initiad) start
    Restart=on-failure
    RestartSec=3
    LimitNOFILE=65535

    [Install]
    WantedBy=multi-user.target
    EOF

    # Enabling and Starting the Service
    echo "Enabling and starting the service..."
    systemctl daemon-reload
    systemctl enable initiad
    systemctl start initiad

    # Checking the Logs
    echo "Checking the logs..."
    journalctl -u initiad -f -o cat

    echo "Node installation is complete."
    ;;

  2)
    # Snapshot
    sudo apt install lz4 -y

    systemctl stop initiad

    cp $HOME/.initia/data/priv_validator_state.json $HOME/.initia/priv_validator_state.json.backup 

    initiad tendermint unsafe-reset-all --home $HOME/.initia --keep-addr-book
    SNAP_NAME=$(curl -s https://testnet.anatolianteam.com/initia/ | egrep -o ">initiation-1.*\.tar.lz4" | tr -d ">")
    curl -L https://testnet.anatolianteam.com/initia/${SNAP_NAME} | tar -I lz4 -xf - -C $HOME/.initia

    mv $HOME/.initia/priv_validator_state.json.backup $HOME/.initia/data/priv_validator_state.json 

    systemctl restart initiad && journalctl -u initiad -f -o cat

    echo "Snapshot is complete."
    ;;

  3)
    # State-Sync
    echo "State-Sync option is selected."
    systemctl stop initiad

    cp $HOME/.initia/data/priv_validator_state.json $HOME/.initia/priv_validator_state.json.backup
    initiad tendermint unsafe-reset-all --home $HOME/.initia --keep-addr-book

    SNAP_RPC="https://rpc-t-initia.anatolianteam.com:443"

    LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
    BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000))
    TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

    echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

    sed -i 's|^enable *=.*|enable = true|' $HOME/.initia/config/config.toml
    sed -i 's|^rpc_servers *=.*|rpc_servers = "'$SNAP_RPC,$SNAP_RPC'"|' $HOME/.initia/config/config.toml
    sed -i 's|^trust_height *=.*|trust_height = '$BLOCK_HEIGHT'|' $HOME/.initia/config/config.toml
    sed -i 's|^trust_hash *=.*|trust_hash = "'$TRUST_HASH'"|' $HOME/.initia/config/config.toml

    mv $HOME/.initia/priv_validator_state.json.backup $HOME/.initia/data/priv_validator_state.json

    systemctl restart initiad && journalctl -u initiad -f -o cat

    echo "State-Sync is complete."
    ;;

4)
    # Delete Node Completely
    echo "Delete Node option is selected."
    systemctl stop initiad && \
    systemctl disable initiad && \
    rm /etc/systemd/system/initiad.service && \
    systemctl daemon-reload && \
    cd $HOME && \
    rm -rf .initia initia && \
    rm -rf $(which initiad)
    sed -i '/INITIA_/d' ~/.bash_profile

    echo "Node removal is complete."
    ;;

*)
    echo "Invalid option. Please select a valid option (1, 2, 3, or 4)."
    ;;

esac

exit 0
