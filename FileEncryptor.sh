!/bin/bash

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

xor_data() {
    local input="$1"
    local key="thisisfine"
    local keylen=${#key}
    local i=0
    local c=""
    
    while IFS= read -r -n1 c; do
        if [ -n "$c" ]; then
            printf "\\x$(printf '%02x' "'$c")"
        else
            printf '\n'
        fi
        i=$((i + 1))
    done < "$input" | xxd -p | while read -r hex; do
        for ((j=0; j<${#hex}; j+=2)); do
            byte=$((16#${hex:j:2}))
            keychar="${key:$((i % keylen)):1}"
            keybyte=$(printf '%d' "'$keychar")
            echo -n "$(printf '%02x' $((byte ^ keybyte)))"
        done
        i=$((i + 1))
    done
}

if [ "$MODE" = "encrypt" ]; then
    xor_data "$INFILE" | base64 | gzip > "$OUTFILE"
elif [ "$MODE" = "decrypt" ]; then
    gunzip -c "$OUTFILE" | base64 -d | xxd -r -p | xor_data > "$INFILE"
else
    echo "Error: Mode must be 'encrypt' or 'decrypt'"
    usage
fi
