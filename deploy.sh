#!/bin/bash
set -e

SOURCE_DIR="/root/site/rmorgado.com"
TARGET_DIR="/var/www/html"
BACKUP_DIR="/root/backup"
BACKUP_FILE="$BACKUP_DIR/$(date +%F_%T)"

prompt_yn()
{
    local MSG="$1"
    if [ -z "$MSG" ]; then
        MSG="Do you want to proceed?"
    fi

    echo "$MSG"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) return 0;;
            No ) return 1;;
        esac
    done
}

backup()
{
    printf "Backing up: "
    mkdir -p "$BACKUP_DIR"
    cp -R "$TARGET_DIR" "$BACKUP_FILE"
    echo "OK"
}

deploy()
{
    echo "Starting deployment"
    rsync -av --exclude='*.git*' --exclude='*.txt' --exclude '*.md' --exclude='deploy.sh' $SOURCE_DIR/* $TARGET_DIR
    find $TARGET_DIR -type d -exec chmod 755 {} \;
    find $TARGET_DIR -type f -exec chmod 644 {} \;
    chown -R www-data:www-data $TARGET_DIR
    echo "Deployment completed successfully"
}

nginx_restart()
{
    sudo systemctl restart nginx
}

prompt_yn "Do you wish to create a backup?" && backup
prompt_yn "Do you wish to proceed with deployment?" && deploy
prompt_yn "Do you wish to restart nginx?" && nginx_restart
