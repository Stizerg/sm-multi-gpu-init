# sm-multi-gpu-init<br />
<br />
For Ubuntu<br />
<br />
The script creates files sequentially, each file created by one provider, using all available providers until all files being created.
If one of the providers finishing the job before others, it will start to create a new files without waiting.<br />

When the job is done you will get a folders with files. You need to merge all .bin files into one folder.
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
<br />
Happy smeshing!
