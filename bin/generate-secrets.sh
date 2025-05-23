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

# peers=("admin" "user1" "user2" "user3" "user4")
# start_ip=10
# for ((i=0; i<${#peers[@]}; i++)); do
#   read privkey pubkey < <(bash -c 'priv=$(wg genkey); pub=$(echo $priv | wg pubkey); printf "$priv $pub\n"')

#   cat <<-EOT >> $ONEPATH/vpn-secrets.yaml
#   - name: ${peers[i]}
#     addr: 172.16.16.$(expr $start_ip + $i)
#     privkey: $privkey
#     pubkey: $pubkey

# EOT
# done

peers=("admin" "user1" "user2" "user3")
tech_bu=("bnl" "cee" "dach" "france" "italy" "nordics" "spain" "uk" "other" "pgo")
start_ip=10

for ((i=0; i<${#tech_bu[@]}; i++)); do
  for ((j=0; j<${#peers[@]}; j++)); do
    read privkey pubkey < <(bash -c 'priv=$(wg genkey); pub=$(echo $priv | wg pubkey); printf "$priv $pub\n"')

    cat <<-EOT >> $ONEPATH/vpn-secrets.yaml
    - name: ${tech_bu[i]}_${peers[j]}
      addr: 172.16.16.$(expr $i \* 10 + $j + $start_ip)
      privkey: $privkey
      pubkey: $pubkey

EOT
  done
done
