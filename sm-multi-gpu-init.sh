#!/bin/bash

# Version 1.0.4 
# The program initializes files sequentially.
# Each file is initialized by one provider.
# When the provider finishes initializing the file, it is given the next one.
# In this way, all providers will be used until there are no files left in the initialization queue.
# Even if the providers are different in power, this will not lead to downtime for the more powerful ones.
# Initialization will continue from where it was interrupted

# Get postcli: https://github.com/spacemeshos/post/releases
# RTM https://github.com/spacemeshos/post/blob/develop/cmd/postcli/README.md
# After completing the initialization of the subsets, you will need to combine the files into same direcory and merge postmeta_data.json as described in the README.md
#
# Based on Samovar's (PlainLazy) Powershell script
# https://github.com/PlainLazy/crypto
# Thank you!

# edit this section
providers=(0 1)  # in this case GPU0 and GPU1 are used (also you can use CPU, its number is 4294967295)
atx="DDDC920DD577749ECF0F2CC8E96D38C3F792C71350780090AD6F63164C519BE6"  # Use latest Highest ATX (Hex)
nodeId="3110232cabf7a274ec817d524723bc44b441ba6592b3e12cdcb137ae5a49ab3c"  # Your public nodeId (smehserId)
fileSize=$((2 * 1024 * 1024 * 1024))  # 2 GiB  (For larger volumes, for convenience, you can increase to 4,8,16+ GiB)
startFromFile=0
numUnits=4  # 64 GiB each (mininum 4)
dataDir="/mnt/node/post"
# end edit section

filesTotal=$(($numUnits * 64 * 1024 * 1024 * 1024 / $fileSize))
echo "Total files $filesTotal"
declare -A processes
declare -a filesArray
fileCounter=$startFromFile

# Creating an array of existing files
while IFS= read -r line; do
    dirName=$(dirname "$line")
    dirNum=${dirName##*/}
    
    fileName=$(basename "$line")
    fileNum=${fileName#*_}
    fileNum=${fileNum%.*}
    
    filesArray+=("$dirNum:$fileNum")
done < <(find "$dataDir" -type f -name 'postdata_*.bin')

IFS=$'\n' filesArray=($(sort -t ":" -k2n <<<"${filesArray[*]}"))
unset IFS

# Checking of already created files, continue if unfinished
amt=${#filesArray[@]}
while ((fileCounter < amt)); do
	for p in "${providers[@]}"; do
		postfile=${filesArray[fileCounter]}
		oldIFS=$IFS
	    IFS=":"
	    read -ra pFile <<< "$postfile"
	    IFS=$oldIFS
	    dirNum=${pFile[0]}

	    if [ -z "${processes[$p]}" ] || ! kill -0 ${processes[$p]} 2> /dev/null; then
		    echo "Checking file postdata_$fileCounter.bin in $dataDir/$dirNum"
		    echo "-------------------------------------------------"
		    nice -n 19 ./postcli -provider $p -commitmentAtxId $atx -id $nodeId -labelsPerUnit 4294967296 -maxFileSize $fileSize -numUnits $numUnits -datadir $dataDir/$dirNum -fromFile $fileCounter -toFile $fileCounter & processes[$p]=$!
		    ((fileCounter++))
		    if [[ "$fileCounter" -eq "$amt" ]] ; then # additional check in case if the number of providers is different
		        break
		    fi
	    fi
    done
    sleep 1
done

# All previously created files have been done, continue normal procedure
if [[ $fileCounter -gt 0 ]]; then
echo "We will continue a normal initialization starting from file $fileCounter"
echo "-----------------------------------------------------------------"
fi

while (( fileCounter < filesTotal )); do
    for p in "${providers[@]}"; do
            if [ -z "${processes[$p]}" ] || ! kill -0 ${processes[$p]} 2> /dev/null; then
                echo " provider $p starts file $fileCounter out of $filesTotal"
                echo "-------------------------------------------------"
                nice -n 19 ./postcli -provider $p -commitmentAtxId $atx -id $nodeId -labelsPerUnit 4294967296 -maxFileSize $fileSize -numUnits $numUnits -datadir $dataDir/$p -fromFile $fileCounter -toFile $fileCounter & processes[$p]=$!
                ((fileCounter++))
            fi
    done
    sleep 1
done

echo "Done!"
read -p "Press enter to continue"
