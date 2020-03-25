#! /bin/sh

secrets_file=.secrets_password_file

[[ -f $secrets_file ]] || pass SysAdmin/Infrastructure-Secrets-Key | tee $secrets_file

function enc_dec() {
    openssl aes-256-cbc -iter 100000 -pbkdf2 -pass file:$secrets_file $@
}

if [[ "$1" == "update" ]]; then
    tar cv secrets | enc_dec > secrets.tar.enc
elif [[ "$1" == "extract" ]]; then
    enc_dec -d -in secrets.tar.enc | tar xv
else
    echo "Invalid parameters. Must specify 'update' or 'extract'."
    exit 1
fi
