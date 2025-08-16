#!/bin/sh
sudo systemctl start nfs-server
sudo systemctl start rpcbind
sudo systemctl start nfs-mountd

systemctl status nfs-server
