#!/bin/bash
#Author Nguyen Trong Tan

##########################################
#### Set local variable  for scripts #####
##########################################

echocolor "Set local variable for scripts"
sleep 3

# Network model (provider or selfservice)
network_model=selfservice

#  Ipaddress variable and Hostname variable
## Assigning IP for controller node
CTL_EXT_IP=172.16.68.238
CTL_EXT_NETMASK=255.255.255.0
CTL_EXT_IF=ens3
CTL_MGNT_IP=192.168.30.35
CTL_MGNT_NETMASK=255.255.255.0
CTL_MGNT_IF=ens4

## Assigning IP for Compute1 host
COM1_EXT_IP=172.16.68.237
COM1_EXT_NETMASK=255.255.255.0
COM1_EXT_IF=ens3
COM1_MGNT_IP=192.168.30.36
COM1_MGNT_NETMASK=255.255.255.0
COM1_MGNT_IF=ens4


## Gateway for EXT network
GATEWAY_EXT_IP=172.16.68.1
CIDR_EXT=172.16.68.0/24
CIDR_MGNT=192.168.30.0/24

## Hostname variable
HOST_CTL=controller
HOST_COM1=compute1

# Password variable
DEFAULT_PASS="tan124"

ADMIN_PASS=$DEFAULT_PASS
DEMO_PASS=$DEFAULT_PASS
RABBIT_PASS=$DEFAULT_PASS
KEYSTONE_DBPASS=$DEFAULT_PASS
GLANCE_DBPASS=$DEFAULT_PASS
GLANCE_PASS=$DEFAULT_PASS
METADATA_SECRET=$DEFAULT_PASS
NEUTRON_DBPASS=$DEFAULT_PASS
NEUTRON_PASS=$DEFAULT_PASS
NOVA_PASS=$DEFAULT_PASS
NOVA_DBPASS=$DEFAULT_PASS
PLACEMENT_PASS=$DEFAULT_PASS
