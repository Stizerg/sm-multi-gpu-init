#!/bin/bash

# Version 1.1.0
# The program initializes files sequentially.
# Each file is initialized by one provider.
# When the provider finishes initializing the file, it is given the next one.
# In this way, all providers will be used until there are no files left in the initialization queue.
# Even if the providers are different in power, this will not lead to downtime for the more powerful ones.
# Initialization will continue from where it was interrupted

# Get postcli: https://github.com/spacemeshos/post/releases
# RTM https://github.com/spacemeshos/post/blob/develop/cmd/postcli/README.md
#
# Based on Samovar's (PlainLazy) Powershell script
# https://github.com/PlainLazy/crypto
# Thank you!

# edit this section
providers=(0 1)  # in this case GPU0 and GPU1 are used (also you can use CPU, its number is 4294967295)
atx="DDDC920DD577749ECF0F2CC8E96D38C3F792C71350780090AD6F63164C519BE6"  # Use latest Highest ATX (Hex)
nodeId="0411201366addcec555ecca5115839706582f896d85521456814e301066886c8"  # Your public nodeId (smehserId)
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
mainLoop=true
expectedFileNum=0
providerCounter=0
providersLength=${#providers[@]}

# Creating an array of existing or missing files
while IFS= read -r line; do
    dirName=$(dirname "$line")
    #dirNum=${dirName##*/}
    
    fileName=$(basename "$line")
    fileNum=${fileName#*_}
    fileNum=${fileNum%.*}
    
    filesArray+=("$dirName:$fileNum")
done < <(find "$dataDir" -type f -name 'postdata_*.bin')

IFS=$'\n' filesArray=($(sort -t ":" -k2n <<<"${filesArray[*]}"))
unset IFS

for i in "${!filesArray[@]}"; do
    currentFileNum=${filesArray[$i]#*:}

    while (( currentFileNum != expectedFileNum )); do
        currentProvider=${providers[$providerCounter]}
        filesArray+=("$dataDir/$currentProvider:$expectedFileNum")
        ((providerCounter=(providerCounter+1)%providersLength))
        ((expectedFileNum++))
    done

    ((expectedFileNum++))
done

IFS=$'\n' filesArray=($(sort -t ":" -k2n <<<"${filesArray[*]}"))
unset IFS

# Checking of already created files, continue initialization if unfinished
amt=${#filesArray[@]}
if [[ $amt -gt 0 ]]; then
	while ((fileCounter < amt)); do
		for p in "${providers[@]}"; do
			postFile=${filesArray[fileCounter]}
			oldIFS=$IFS
	    	IFS=":"
	    	read -ra pFile <<< "$postFile"
	    	IFS=$oldIFS
	    	dirName=${postFile%%:*}

	    	if [ -z "${processes[$p]}" ] || ! kill -0 ${processes[$p]} 2> /dev/null; then
		    	echo "Checking existing file: $dirName/postdata_$fileCounter.bin"
		    	echo "-----------------------------------------------------------------"
		    	nice -n 19 ./postcli -provider $p -commitmentAtxId $atx -id $nodeId -labelsPerUnit 4294967296 -maxFileSize $fileSize -numUnits $numUnits -datadir $dirName -fromFile $fileCounter -toFile $fileCounter & processes[$p]=$!
		    	((fileCounter++))
		    	if [[ "$fileCounter" -eq "$filesTotal" ]]; then
		        	mainLoop=false
		        	break 2
		    	fi
		    	if [[ "$fileCounter" -eq "$amt" ]] ; then # additional check in case if the number of providers changed
		        	break
		    	fi
	    	fi
    	done
    	sleep 0.2
	done
fi

# All previously created files have been done, we continue with the normal procedure
if $mainLoop; then
	while (( fileCounter < filesTotal )); do
    	for p in "${providers[@]}"; do
            if [ -z "${processes[$p]}" ] || ! kill -0 ${processes[$p]} 2> /dev/null; then
                echo " Provider $p starts processing a new file: $dataDir/postdata_$fileCounter.bin (Total files:$filesTotal)"
                echo "-----------------------------------------------------------------"
                nice -n 19 ./postcli -provider $p -commitmentAtxId $atx -id $nodeId -labelsPerUnit 4294967296 -maxFileSize $fileSize -numUnits $numUnits -datadir $dataDir -fromFile $fileCounter -toFile $fileCounter & processes[$p]=$!
                ((fileCounter++))
            fi
    	done
    	sleep 1
	done
fi

echo "Almost there"
echo "Waiting for background processes to finish"
echo "------------------------------------------"
wait
echo "All done!"
read -p "Press enter to continue"
