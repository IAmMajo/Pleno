#!/bin/bash

if [[ $# -eq 0 ]]; then
    cd $(echo $BASH_SOURCE | sed "s#$(basename $BASH_SOURCE)##")
    mkdir -p ./android/dtos
    SOURCE=$(realpath ./DTOs/Sources)
    DEST=$(realpath ./android/app/src/main/java/net/ipv64/kivop/dtos)
elif [[ $# -eq 2 ]]; then
    if [[ ! -d $1 ]]; then
        echo "First argument (source) must be a directory!"
        exit 1
    fi

    if [[ -f $2 ]]; then
        echo "Second argument (destination) must NOT be a file!"
        exit 1
    fi
    mkdir -p "$2"
    SOURCE=$(realpath "$1")
    DEST=$(realpath "$2")
else
    echo "Unsupported number of arguments! Requires 2 (source and destination) or 0."
    exit 1
fi

# Remove dest dir and its contents and copy all swift files from source to dest preserving structure
rm -r "$DEST"
cd "$SOURCE"
find . -type f -name '*.swift' | cpio -pd "$DEST"

# Basic data type translation declaration
declare -A basicdatatypes=( [Bool]=Boolean [Int8]=Byte [Int16]=Short [Int32]=Int [Int64]=Long [UInt8]=UByte [UInt16]=UShort [UInt32]=UInt [UInt64]=ULong [UUID]=UUID [Date]=LocalDateTime [Data]=ByteArray )
### Translations
find "$DEST" -type f -name '*.swift' | while read -r file; do
    # Remove inits
    perl -i -0777pe 's/public init.*?\}//gs' $file
    # struct -> data class
    perl -pi -e 's/^public struct ([A-Za-z0-9_]+): Codable ?\{$/data class \1 (/g' $file
    # Basic data type translations
    for key in "${!basicdatatypes[@]}"; do
        perl -pi -e "s/(?<=: )$key|(?<=\[)$key/${basicdatatypes[$key]}/g" $file
    done
    # Array -> List
    perl -pi -e 's/\[([A-Za-z0-9_]+\??)\]/List<\1>/g' $file
    # Dict -> Map
    perl -pi -e 's/\[([A-Za-z0-9_]+\??): ([A-Za-z0-9_]+\??)\]/Map<\1, \2>/g' $file
    # Add space before colon
    perl -pi -e 's/(?<=public var [A-Za-z0-9_]{1,244}):/ :/g' $file
    # Add comma after each variable
    perl -pi -e 's/(?<=public var [A-Za-z0-9_]{1,117} : (?:List<[A-Za-z0-9_]{1,117}>|[A-Za-z0-9_]{1,123})\??)(?=\s)/,/g' $file
    # Remove imports and empty lines
    perl -pi -e 's/^(from \w+ )?import \w+(\r?\n)//g' $file
    perl -pi -e 's/^\s*\r?\n//g' $file
    # enum -> enum class
    perl -pi -e 's/^public enum ([A-Za-z0-9_]+): String, Codable \{$/public enum class \1 {/g' $file
    # Remove case in enums / enum classes
    perl -pi -e 's/^(\s*)case (\w+),?/\1\2,/g' $file
    # Remove public keyword from vars and enums
    perl -pi -e 's/public (?=var|enum)//g' $file
    # Swap `}` of data classes with `)`
    perl -i -0777pe 's/(data class.*?)\}/\1)/gs' $file
    # Add package declaration and necessary imports
    perl -i -0777pe "s/^/package net.ipv64.kivop.dtos.$(echo "$file"| perl -nle 'print $1 if /\/(\w+)(?=\/[^\/]+$)/')\n\nimport java.util.UUID\nimport java.time.LocalDateTime\n\n/gs" $file
    ### Change .swift to .kt
    mv "$file" "`echo $file | sed "s/swift$/kt/g"`"
done
