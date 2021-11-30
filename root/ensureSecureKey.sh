#!/usr/bin/env bash

KEY_FILE="$HOME/.ssh/id_rsa"

ABSENT_KEY=0
INSECURE_KEY=0

#absent key check
if [[ ! -f "$KEY_FILE" ]]; then
	echo "Key is absent!"
	ABSENT_KEY=1
else
	ssh-keygen -y -P "" -f $KEY_FILE >/dev/null 2>&1
	if [[ $? == 0 ]]; then
		echo "Insecure key detected!"
		INSECURE_KEY=1
	fi
fi


while [[ $ABSENT_KEY != 0 || $INSECURE_KEY != 0 ]]; do
	if [[ $INSECURE_KEY != 0 ]]; then
		echo "Discarding the INSECURE key"
		rm -f "$KEY_FILE"
		rm -f "${KEY_FILE}.pub"
	fi
	ABSENT_KEY=0
	INSECURE_KEY=0
	#generate a key
	echo ""
	echo "------------------------------------------"
	echo ""
	echo "Please create a new key WITH a PASSPHRASE!"
	echo ""
	echo "------------------------------------------"
	ssh-keygen -f $KEY_FILE
	#check the key
	ssh-keygen -y -P "" -f $KEY_FILE >/dev/null 2>&1
	if [[ $? == 0 ]]; then
		echo "Insecure key detected!"
		INSECURE_KEY=1
	fi
done

