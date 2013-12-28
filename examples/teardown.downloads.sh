# get downloads
echo "[secfox] getting downloads..."
mkdir -p $SECFOX_CONFIG_DIR/downloads
scp $SECFOX_SSH_ARGS -P $SECFOX_PORT $SECFOX_USER@$SECFOX_HOST:Downloads/'*' $SECFOX_CONFIG_DIR/downloads/
