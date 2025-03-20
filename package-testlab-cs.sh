#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

datestr=$(date '+%Y%m%d')
package_name=/tmp/package-testlab-cs-${datestr}

rm -rf ${package_name}
mkdir -p ${package_name}

echo "${bold}Copy VPN configs${normal}"
cp -r vpn-peers ${package_name}
rm -f ${package_name}/vpn-peers/admin.conf

echo "${bold}Copy RDP configs${normal}"
cp -r vpn-rdps ${package_name}

echo "${bold}Creating Network Information${normal}"
pgo --output network > ${package_name}/network.txt

echo "${bold}Creating Testlab Information${normal}"
pgo --output testlab-cs > ${package_name}/testlab-cs.txt

echo "${bold}Copy Instance Private Key${normal}"
cp $(terraform -chdir=${ONEPATH}/awsone/2-network output -raw private_key_path) ${package_name}

ls -lR ${package_name}

rm -f ${package_name}.tgz
tar cfvz ${package_name}.tgz ${package_name}

cp ${package_name}.tgz ${ONEPATH}
