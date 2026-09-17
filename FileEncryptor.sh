#!/bin/bash

usage() {
    echo "Usage: fileencryptor.sh -[mode] -Infile <file> -Outfile <file>"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -mode)
            MODE="$2"
            shift 2
            ;;
        -Infile)
            INFILE="$2"
            shift 2
            ;;
        -Outfile)
            OUTFILE="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown option $1"
            usage
            ;;
    esac
done

if [ -z "$MODE" ] || [ -z "$INFILE" ] || [ -z "$OUTFILE" ]; then
    usage
fi

if [ "$MODE" = "encrypt" ]; then
    xxd -p "$INFILE" | tr -d '\n' | base64 | gzip > "$OUTFILE"
elif [ "$MODE" = "decrypt" ]; then
    gunzip -c "$OUTFILE" | base64 -d | xxd -r -p > "$INFILE"
else
    echo "Error: Mode must be 'encrypt' or 'decrypt'"
    usage
fi
