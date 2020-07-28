#!/bin/bash

curl -k -L -o /tmp/azcopy_linux.tar.gz 'https://aka.ms/downloadazcopy-v10-linux'
tar xzf /tmp/azcopy_linux.tar.gz -C /tmp/
mv /tmp/azcopy_linux*/azcopy /usr/local/bin/azcopy
chmod a+x /usr/local/bin/azcopy
rm -rf /tmp/azcopy_linux*

