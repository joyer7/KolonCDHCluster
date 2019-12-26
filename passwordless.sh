#!/bin/bash
for target_host in `cat hosts`
do
        sshpass -p '$password' ssh -o StrictHostKeyChecking=no ${target_host} 'mkdir -p ~/.ssh' && cat ~/.ssh/id_rsa.pub | sshpass -p 'hadoop' ssh ${target_host} "cat > ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 0644 ~/.ssh/authorized_keys"
        echo "---------------------------------------------------"
done
