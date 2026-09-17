#!/usr/bin/env python3
import argparse
import base64
import gzip
import sys

def encrypt(infile, outfile):
    with open(infile, 'rb') as f:
        data = f.read()
    compressed = gzip.compress(data)
    key = b'thisisfine'
    xored = bytes([compressed[i] ^ key[i % len(key)] for i in range(len(compressed))])
    encoded = base64.b64encode(xored)
    hexed = encoded.hex()
    with open(outfile, 'w') as f:
        f.write(hexed)

def decrypt(infile, outfile):
    with open(infile, 'r') as f:
        hexed = f.read()
    encoded = bytes.fromhex(hexed)
    xored = base64.b64decode(encoded)
    key = b'thisisfine'
    compressed = bytes([xored[i] ^ key[i % len(key)] for i in range(len(xored))])
    decoded = gzip.decompress(compressed)
    with open(outfile, 'wb') as f:
        f.write(decoded)

def main():
    parser = argparse.ArgumentParser(usage='fileencryptor.py -[mode] -Infile <file> -Outfile <file>')
    parser.add_argument('-mode', choices=['encrypt', 'decrypt'], required=True, help='Operation mode')
    parser.add_argument('-Infile', required=True, help='Input file')
    parser.add_argument('-Outfile', required=True, help='Output file')
    
    args = parser.parse_args()
    
    try:
        if args.mode == 'encrypt':
            encrypt(args.Infile, args.Outfile)
        else:
            decrypt(args.Infile, args.Outfile)
    except Exception as e:
        print(f'Error: {e}', file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
