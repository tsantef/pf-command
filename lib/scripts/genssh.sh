#!/bin/bash

# Set variable to be used later  
# echo -n "Enter the email address for this account: " 
read email_address
email_address=$(echo "$email_address" | sed 's/[^A-Za-z0-9-]/-/g')

# SSH key name and path
ssh_path=~/.ssh
ssh_config_path="$ssh_path/config"
ssh_key_name="$ssh_path/$email_address"

# Checking and adding ~/.ssh directory as needed
if [ ! -d $ssh_path ]; then 
    mkdir -p $ssh_path
fi

# Checking for pre-existing key by the same name exists, if so, gen new name
if [ -f $ssh_key_name ]; then
    echo "A key already exists for this email address, please choose a different email address! This tool will now close."
      exit
fi

echo "To clone your repo use: $email_address:(repo name)"
ssh-keygen -q -t rsa -b 2048 -f $ssh_key_name

# Paste new config to ssh config
echo "# PHPFog App (brought to you by Rich, Support Engineer, AppFog)"  >> $ssh_config_path
echo "Host $email_address" >> $ssh_config_path
echo "    HostName git01.phpfog.com" >> $ssh_config_path
echo "    User git" >> $ssh_config_path
echo "    IdentityFile $ssh_key_name" >> $ssh_config_path

ssh-add $ssh_key_name
echo "Done! Remember to clone your git repo use: git clone $email_address:(your repo name)"
echo "Copy the below ssh public key to your phpfog account."
cat $ssh_key_name".pub"

exit
