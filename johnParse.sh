#!/bin/bash

# Synopsis: This is a short script to take 1+ files of hashes, determine the hash type, then execute John the Ripper against each similar profile. Once complete, all cracked passwords are saved to a file, crackedHashes.txt
# Info: Default wordlist set in this file is /usr/share/wordlists/rockyou.txt
# Author: Tony Habeger (github.com/selectfromt @TonyHabeger)

# read in file path(s) which contain hash(es)
# single file: hashes.txt
# multiple files: hash\_* 
	# represents the files hash_1.txt, hash_2.txt, hash_3.txt, hash_n.txt
echo "Enter the path(s) filename(s) which contain the hash"
echo "Example: "
echo "Single file: hashes.txt"
echo "multiple files: hash\_* for files hash_1.txt hash_2.txt hash_n.txt"

read hashFilePath


for f in $(ls $hashFilePath);
do
for hash in $(cat $f);
do
hashType=$(echo $hash | hash-identifier 2>/dev/null | grep -i '[+]' -m 1 | awk '{ print $2 }')
for formatType in $(sudo john --list=formats);
do
matchFormatType=$(echo $formatType | awk -F, '{ print $1 }' | grep -i $hashType)
lenMatch=$(echo $matchFormatType | wc -c)
if [ $lenMatch -gt 1 ];
then
sudo john --format=$matchFormatType --wordlist=/usr/share/wordlists/rockyou.txt $f | grep -v -i "No password" 
crackedHash=$(sudo john --show --format=$matchFormatType $f | grep -v -i '0 password hashes cracked' | head -n 1 | awk -F: '{print $2 }')
lenCrackedHash=$(echo $crackedHash | wc -c)
if [ $lenCrackedHash -gt 1 ];
then
echo $hash >> crackedHashes.txt
echo $crackedHash >> crackedHashes.txt
fi
fi
done
done
done
