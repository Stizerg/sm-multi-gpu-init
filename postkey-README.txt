## Introduction

1. Download from https://github.com/DogeMonster/shibamesh_post_key_generator/releases
1. Run `./postkey <dir>` to generate `key.bin`
1. The program prints public key
   1. the first line is `hex`, can be used with `postcli`
   1. the second line is `base64`, can be used in `postdata_metadata.json`

## Example

```
$ ./postkey .
86ce32dcb99546235a97d95b4c6d55f5f1492b162c5848efa8a290e89ff9036f
hs4y3LmVRiNal9lbTG1V9fFJKxYsWEjvqKKQ6J/5A28=
```
