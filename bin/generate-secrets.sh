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

peers=("admin" "user1" "user2" "user3")
start_ip=10
for ((i=0; i<${#peers[@]}; i++)); do
  read privkey pubkey < <(bash -c 'priv=$(wg genkey); pub=$(echo $priv | wg pubkey); printf "$priv $pub\n"')

  cat <<-EOT >> $ONEPATH/vpn-secrets.yaml
  - name: ${peers[i]}
    addr: 172.16.16.$(expr $start_ip + $i)
    privkey: $privkey
    pubkey: $pubkey

EOT
done
