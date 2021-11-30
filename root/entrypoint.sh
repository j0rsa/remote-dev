#!/usr/bin/env bash

USER_NAME=${USER_NAME:-user}
PUID=${PUID:-911}
PGID=${PGID:-911}

useradd -m -s /bin/bash "$USER_NAME"
groupmod -o -g "$PGID" "$USER_NAME"
usermod -o -u "$PUID" "$USER_NAME"

echo "
-------------------------------------
User uid:    $(id -u "$USER_NAME")
User gid:    $(id -g "$USER_NAME")
-------------------------------------
"

H="/home/$USER_NAME/"

# create folders
mkdir -p \
    "$H"{.ssh,ssh_host_keys}
mkdir /app

chown "$USER_NAME":"$USER_NAME" /app

echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# symlink out ssh config directory
if [ ! -L /etc/ssh ];then
    if [ ! -f "$H"/ssh_host_keys/sshd_config ]; then
        sed -i '/#PidFile/c\PidFile \/config\/sshd.pid' /etc/ssh/sshd_config
        cp -a /etc/ssh/sshd_config "$H"/ssh_host_keys/
    fi
    rm -Rf /etc/ssh
    ln -s "$H"/ssh_host_keys /etc/ssh
    ssh-keygen -A
fi

chown root:root \
		/etc/shadow
echo "User/password ssh access is disabled."

# set umask for sftp
UMASK=${UMASK:-022}
sed -i "s|/usr/lib/ssh/sftp-server$|/usr/lib/ssh/sftp-server -u ${UMASK}|g" /etc/ssh/sshd_config

# set key auth in file
if [ ! -f "$H"/.ssh/authorized_keys ];then
    touch "$H"/.ssh/authorized_keys
fi

[[ -n "$PUBLIC_KEY" ]] && \
    [[ ! $(grep "$PUBLIC_KEY" "$H"/.ssh/authorized_keys) ]] && \
    echo "$PUBLIC_KEY" >> "$H"/.ssh/authorized_keys && \
    echo "Public key from env variable added"

[[ -n "$EXTRA_PACKAGES" ]] && \
	apt install $EXTRA_PACKAGES

echo "/ensureSecureKey.sh" >> "$H"/.bashrc

echo 'echo "Welcome to Remote Develop Container"' >> "$H"/.bashrc
echo 'echo ""' >> "$H"/.bashrc
echo 'echo "To authorize this container please use the PUB ssh key"' >> "$H"/.bashrc
echo 'echo "-------------------------------------"' >> "$H"/.bashrc
echo 'cat $HOME/.ssh/id_rsa.pub' >> "$H"/.bashrc
echo 'echo "-------------------------------------"' >> "$H"/.bashrc

# permissions
chown -R "${USER_NAME}":"${USER_NAME}" \
    "$H"
chmod go-w \
    "$H"
chmod 700 \
    "$H"/.ssh
chmod 600 \
    "$H"/.ssh/authorized_keys

echo "Starting server"
/etc/init.d/ssh start
echo "Ready for connections!"

tail -f /dev/null
