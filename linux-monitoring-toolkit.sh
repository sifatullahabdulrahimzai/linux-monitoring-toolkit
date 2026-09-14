
echo "Check Server Health, Services, Disk, and System Status"

show_sys_info(){

        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
        ram_usage=$(free | awk '/Mem:/ {printf "%.1f",$3/$2 * 100}')
        disk_usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
        clear
        . /etc/os-release
        echo "=========   SYSTEM INFORMATION ============="
        echo "Hostname: $(hostname)"
        echo "OS :$PRETTY_NAME"
        echo "Kernel: $(uname -r)"
        echo "Architicture: $(uname -m)"
        echo "Date: $(date)"
        echo "CPU Usage : ${cpu_usage}%"
        if (( $(echo "$cpu_usage <=80" | bc -l)))
        then
        echo  "Status:OK"
        else
         echo -e "Status: \e[31mWARNING\e[0m"
        fi
        echo "RAM Usage: ${ram_usage}%"
        if (( $(echo "$ram_usage <=80" | bc -l )))
        then
        echo "Status: OK"
        else
        echo -e "Status: \e[31mWARNING\e[0m"
        fi
        echo "Disk Usage: ${disk_usage}%"
        if (( disk_usage <=80 ))
        then
        echo "Status: OK"
        else
        echo -e "Status: \e[31mWARNING\e[0m"
        fi
}

show_sys_info

show_service_info(){

        echo " ==========   Check critical Service Status   ==========="

        ssh_svc=$(systemctl is-active ssh)
        cron_svc=$(systemctl is-active cron)
        nginx_svc=$(systemctl is-active nginx)

        if [[ "$ssh_svc" == "active" ]]
        then
        echo "SSH Service : Running"
        else
        echo "SSH Service:Not RUning"
        fi
        if [[ $cron_svc == "active" ]] ; then
        echo "Cron Service: Running"
        else
        echo -e "Cron Service: \e[31mNOT RUNNING\e[0m"
        fi
        if [[ $nginx_svc == "active" ]]; then
        echo "Nginx Service: Running"
        else
        echo -e "Nginx Service : \e[31mNOT RUNNING\e[0m"
        fi
}

show_service_info

show_network_info(){
    echo "========== NETWORK INFORMATION =========="

    echo "Hostname: $(hostname)"
    echo "IP Address:"

    ip -br addr

    echo "Default Gateway:"
    ip route | awk '/default/ {print $3}'

    echo "DNS:"
    resolvectl status | awk '/DNS Servers/ {print}'
}

show_network_info

show_security_audit(){

    echo "========== SECURITY AUDIT =========="

    # 1. SSH Security
    echo "--- SSH Security ---"

    root_login=$(sudo sshd -T | awk '/^permitrootlogin / {print $2}')
    password_auth=$(sudo sshd -T | awk '/^passwordauthentication / {print $2}')

    echo "Root SSH Login: $root_login"
    echo "Password Authentication: $password_auth"


    # 2. Firewall
    echo "--- Firewall ---"

    firewall_status=$(sudo ufw status | awk 'NR==1 {print $2}')

    echo "Firewall: $firewall_status"


    # 5. Listening Ports
    echo "--- Listening Ports ---"

    sudo ss -tuln
}

show_security_audit
