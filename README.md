# sm-multi-gpu-init
<br />
For Ubuntu<br />
<br />
The script creates files sequentially, each file created by one provider, using all available providers until all files are created.
If one of the providers finishes the job before others, it will start to create the next file without waiting.<br />
Initialization will continue from where it was interrupted.<br />
<br />
To start you need to download postcli to the same folder<br />
https://github.com/spacemeshos/post/releases<br />
<br />
To generate the key.bin I'm using postkey created by Doge Monster<br />
https://github.com/DogeMonster/shibamesh_post_key_generator/releases<br />
The program will generate key.bin and display the node ID you will need to insert into the script (hex)<br />
<br />
Also you need to make sure you are using the latest Highest ATX<br />
<br />
<br />
The section below about the nonce is obsolete, starting from version 1.1.0 the script doesn't create subfolders and you don't need to merge files manually<be />
If you updating the script in the middle of creating the files you still need to check for lowest nonce.
--------------------------------------------------------<br />
When the job is done you will get the folders with files. You need to merge all .bin files into one folder.<br />
You also need to copy postdata_metadata.json with lowest "NonceValue".<br />
To make it easy you can use any HEX calculator.<br />
For example this one: https://www.calculator.net/hex-calculator.html<br />

Lets say in your postdata_metadata.json files you have values:<br />
"NonceValue": "000000000b53681ee56a5966681182e4" (file in 0)<br />
and<br />
"NonceValue": "0000000002d053f72a322196f61849e5" (file in 1)<br />

Using simple substruction 000000000b53681ee56a5966681182e4 – 0000000002d053f72a322196f61849e5<br />
you will get this result:<br />

Hex value:<br />
000000000b53681ee56a5966681182e4 – 0000000002d053f72a322196f61849e5 = BB38380000000000<br />

Decimal value:<br />
3.5051676471105E+27 – 8.7082310592693E+26 = 2.6343445411835E+27<br />

Positive result means the second value is smaller, negative result means the first value is smaller.
In this case the second nonce value is smaller and we need to copy the json file from folder 1.<br />
If you copy this values manually don't forget to copy "Nonce" too.<br />
<br />
Happy smeshing!
