#!/bin/bash

# The program initializes files sequentially.
# Each file is initialized by one provider.
# When the provider finishes initializing the file, it is given the next one.
# In this way, all providers will be used until there are no files left in the initialization queue.
# Even if the providers are different in power, this will not lead to downtime for the more powerful ones.

# Get postcli: https://github.com/spacemeshos/post/releases
# RTM https://github.com/spacemeshos/post/blob/develop/cmd/postcli/README.md
# After completing the initialization of the subsets, you will need to combine the files into same direcory and merge postmeta_data.json as described in the README.md
#
# Based on Samovar's (PlainLazy) Powershell script
# https://github.com/PlainLazy/crypto
# Thank you!

# edit this section
providers=(0 1)  # in this case GPU0 and GPU1 are used (also you can use CPU, its number is 4294967295)
atx="8B3391AB8C7E3B43D5E941EC81C6A78E91054E11ADA48BDEC5F2CE076F9CA4DA"  # Use latest Highest ATX (Hex)
nodeId="102023cabf7a274ec817d556653bc98b441ba6523b3e56cdcb137ae5a49ab3c"  # Your public nodeId (smehserId)
fileSize=$((2 * 1024 * 1024 * 1024))  # 2 GiB  (For larger volumes, for convenience, you can increase to 4,8,16+ GiB)
startFromFile=0
numUnits=4  # 64 GiB each (mininum 4)
dataDir="/mnt/spacemesh/post" 
# end edit section

filesTotal=$(($numUnits * 64 * 1024 * 1024 * 1024 / $fileSize))
echo "filesTotal $filesTotal"
declare -A processes
fileCounter=$startFromFile

while (( fileCounter < filesTotal )); do
	for p in "${providers[@]}"; do
            if [ -z "${processes[$p]}" ] || ! kill -0 ${processes[$p]} 2> /dev/null; then
                echo " provider $p starts file $fileCounter out of $filesTotal"
                echo "----------------------------------------------"
                ./postcli -provider $p -commitmentAtxId $atx -id $nodeId -labelsPerUnit 4294967296 -maxFileSize $fileSize -numUnits $numUnits -datadir $dataDir/$p -fromFile $fileCounter -toFile $fileCounter & processes[$p]=$!
                ((fileCounter++))
            fi
    done
    sleep 1
done

echo "done"
read -p "Press enter to continue"
