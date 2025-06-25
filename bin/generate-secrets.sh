#!/usr/bin/env bash

cat <<-EOT > $ONEPATH/vpn-secrets.yaml 
wg_server:
EOT

read privkey pubkey < <(bash -c 'priv=$(wg genkey); pub=$(echo $priv | wg pubkey); printf "$priv $pub\n"')

cat <<-EOT >> $ONEPATH/vpn-secrets.yaml 
  privkey: $privkey
  pubkey: $pubkey

wg_peers:
EOT

start_ip=10

admins=(admin 5 0)
pgos=(pgo_admin 1 1)
users=(user 60 2)
matrix=(admins pgos users)

for row in "${matrix[@]}"; do
  eval "r=(\"\${$row[@]}\")"
  for ((j=0; j<r[1]; j++)); do
    read privkey pubkey < <(bash -c 'priv=$(wg genkey); pub=$(echo $priv | wg pubkey); printf "$priv $pub\n"')

    if [ "${r[2]}" == 1 ]; then
      cat <<-EOT >> $ONEPATH/vpn-secrets.yaml
      - name: ${r[0]}
        addr: 172.16.16.$(expr ${r[2]} \* 10 + $j + $start_ip)
        privkey: $privkey
        pubkey: $pubkey

EOT
    else
      cat <<-EOT >> $ONEPATH/vpn-secrets.yaml
      - name: ${r[0]}_$j
        addr: 172.16.16.$(expr ${r[2]} \* 10 + $j + $start_ip)
        privkey: $privkey
        pubkey: $pubkey

EOT
    fi
  done
done
