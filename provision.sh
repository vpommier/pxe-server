#!/bin/bash

fleetctl submit /home/core/units/*
fleetctl start dhcpd.service tftpd.service httpd.service
