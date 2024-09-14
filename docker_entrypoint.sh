#!/bin/sh

printf "\n\n [i] Starting Alby Hub ...\n\n"

# Read current LN setup from config
LN_VALUE=$(grep 'lightning:' /data/start9/config.yaml | cut -d ' ' -f 2)

# File to track initial setup (lnd or alby)
SETUP_FILE="/data/start9/initial_setup"
WORK_DIR="/data/albyhub"
BACKUP_DIR="/data/start9/backups"

# Ensure the backup directory exists
mkdir -p "$BACKUP_DIR"

# Determine the initial setup
if [ -f "$SETUP_FILE" ]; then
    INITIAL_SETUP=$(cat "$SETUP_FILE")
else
    INITIAL_SETUP="$LN_VALUE"
    echo "$INITIAL_SETUP" >"$SETUP_FILE" # Store initial setup if it doesn't exist
fi
# Function to create a tar.gz backup of the albyhub directory
backup_dir() {
    suffix="$INITIAL_SETUP"
    tar_file="$BACKUP_DIR/${suffix}_backup.tar.gz"

    # Create a tar.gz file containing the albyhub directory
    tar -czf "$tar_file" -C "/data" albyhub 2>/dev/null
    echo "[i] Created backup: $tar_file"
}
# Function to restore the albyhub directory from a tar.gz backup
restore_dir() {
    suffix="$1" # Either 'lnd' or 'alby'
    tar_file="$BACKUP_DIR/${suffix}_backup.tar.gz"

    if [ -f "$tar_file" ]; then
        rm -rf "$WORK_DIR"
        tar -xzf "$tar_file" -C "/data"
        echo "[i] Restored from backup: $tar_file"
    else
        echo "[i] No $suffix backup found."
    fi
}

# Handling different setups
if [ "$INITIAL_SETUP" != "$LN_VALUE" ]; then
    if [ "$INITIAL_SETUP" = "lnd" ] && [ "$LN_VALUE" = "alby" ]; then
        echo "[i] Switching from LND to Alby/LDK..."

        # Backup current LND directory
        backup_dir

        # Restore Alby backup if it exists, otherwise start fresh
        if [ -f "$BACKUP_DIR/alby_backup.tar.gz" ]; then
            restore_dir "alby"
        else
            echo "[i] No Alby/LDK backup found, starting fresh..."
            rm -rf "$WORK_DIR"
            mkdir -p "$WORK_DIR"
        fi

        # Update the initial setup to 'alby'
        echo "alby" >"$SETUP_FILE"

    elif [ "$INITIAL_SETUP" = "alby" ] && [ "$LN_VALUE" = "lnd" ]; then
        echo "[i] Switching from Alby/LDK to LND..."

        # Backup current Alby directory
        backup_dir

        # Restore LND backup if it exists, otherwise clean up the data directory for initial LND setup
        if [ -f "$BACKUP_DIR/lnd_backup.tar.gz" ]; then
            restore_dir "lnd"
        else
            echo "[i] No LND backup found, cleaning up the data directory for initial LND setup..."
            rm -rf "$WORK_DIR"
            mkdir -p "$WORK_DIR"
        fi

        # Update the initial setup to 'lnd'
        echo "lnd" >"$SETUP_FILE"
    fi
fi

# Set up environment variables based on LN_VALUE
if [ "$LN_VALUE" = "lnd" ]; then
    export LN_BACKEND_TYPE="LND"
    export LND_ADDRESS="lnd.embassy:10009"             # the LND gRPC address
    export LND_CERT_FILE="/mnt/lnd/tls.cert"           # the location where LND's tls.cert file can be found
    export LND_MACAROON_FILE="/mnt/lnd/admin.macaroon" # the location where LND's admin.macaroon file can be found
    export ENABLE_ADVANCED_SETUP=false
else
    # Default to Alby/LDK if lightning value is not "lnd"
    export LN_BACKEND_TYPE="LDK"
    unset LND_ADDRESS
    unset LND_CERT_FILE
    unset LND_MACAROON_FILE
fi

export WORK_DIR="/data/albyhub"
export PORT=8080       #the port on which the app should listen on (default='blah' #8080)
export LOG_EVENTS=true # makes debugging easier

# Output some debug information
echo "LN Backend Type: $LN_BACKEND_TYPE"
if [ "$LN_VALUE" = "lnd" ]; then
    echo "LN Address: $LND_ADDRESS"
    echo "LND Cert: $LND_CERT_FILE"
    echo "LND Macaroon: $LND_MACAROON_FILE"
fi

# Start the Alby Hub app
exec /bin/main
