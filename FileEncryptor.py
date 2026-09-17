#!/usr/bin/env python3
import argparse
import base64
import gzip
import sys

def encrypt(infile, outfile):
    with open(infile, 'rb') as f:
        data = f.read()
    encoded = base64.b64encode(data)
    with gzip.open(outfile, 'wb') as f:
        f.write(encoded)

def decrypt(infile, outfile):
    with gzip.open(infile, 'rb') as f:
        encoded = f.read()
    decoded = base64.b64decode(encoded)
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
