#!/bin/sh

export CN="$2"
envsubst < "$1"
gen() {
    echo "<$1>"
    cat "$2"
    echo "</$1>"
}
gen ca "$CA".crt
gen cert "$CN".crt
gen key "$CN".key
gen tls-crypt "$CA".secret
gen dh dh.pem
