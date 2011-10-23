#!/bin/bash
echo "check RAID..."
dmraid -s
dmraid -r
echo -e "\n"

echo "check storage..."
df 
echo -e "\n"

echo "check S.M.A.R.T.T..."
smartctl -a /dev/sda
smartctl -a /dev/sdb
echo "..start selftest..."
smartctl -t short /dev/sda
smartctl -t short /dev/sdb
echo "..waiting 3 min..."
sleep 180
smartctl --log=selftest /dev/sda
smartctl --log=selftest /dev/sdb
echo -e "\n"
