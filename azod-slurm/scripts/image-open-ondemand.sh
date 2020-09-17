#!/bin/bash

yum -y install centos-release-scl
yum -y install https://yum.osc.edu/ondemand/1.8/ondemand-release-web-1.8-1.noarch.rpm
yum -y install ondemand
#yum -y install ondemand-dex
yum -y install mod_authnz_pam
