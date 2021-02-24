#!/system/bin/sh

appid_list=()
proxy_mode="none"
appid_file="/data/00AA_Linux_App/Clash/appid.list"
sdcard_rw_uid="1015"
mark_id="2020"
clash_redir_port="7892"
clash_dns_port="1053"
ip="iptables"
tun_ip="198.18.0.0/16"
intranet=(0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.0.0.0/24 192.0.2.0/24 192.88.99.0/24 192.168.0.0/16 198.18.0.0/15 198.51.100.0/24 203.0.113.0/24 224.0.0.0/4 240.0.0.0/4 255.255.255.255/32)

create_mangle_iptables() {
    ${ip} -t mangle -N CLASH

    if [ "${ip}" = "ip6tables" ] ; then
        intranet=(::/128 ::1/128 ::ffff:0:0/96 100::/64 64:ff9b::/96 2001::/32 2001:10::/28 2001:20::/28 2001:db8::/32 2002::/16 fc00::/7 fe80::/10 ff00::/8)
    fi

    for subnet in ${intranet[@]} ; do
        ${ip} -t mangle -A CLASH -d ${subnet} -j RETURN
    done

    ${ip} -t mangle -A CLASH -p tcp ! --dport 53 -j MARK --set-xmark ${mark_id}
    ${ip} -t mangle -A CLASH -p udp ! --dport 53 -j MARK --set-xmark ${mark_id}

    create_dns_iptables
    create_proxy_iptables
    create_ap_iptables
}

create_ap_iptables() {
    ${ip} -t nat -N AP_PROXY
    for subnet in ${intranet[@]} ; do
        ${ip} -t nat -A AP_PROXY -d ${subnet} -j RETURN
    done
    ${ip} -t nat -A AP_PROXY -i wlan0 -p tcp -j REDIRECT --to-port ${clash_redir_port}
    ${ip} -t nat -I PREROUTING -j AP_PROXY
    ${ip} -t nat -I PREROUTING -j DNS
}

create_proxy_iptables() {
    ${ip} -t mangle -N PROXY
    ${ip} -t nat -N FILTER_DNS

    ${ip} -t mangle -A PROXY -m owner --gid-owner ${sdcard_rw_uid} -j RETURN
    ${ip} -t nat -A FILTER_DNS -m owner --gid-owner ${sdcard_rw_uid} -j RETURN

    probe_proxy_mode

    if [ "${proxy_mode}" = "ALL" ] ; then
        ${ip} -t mangle -A PROXY -j CLASH
        ${ip} -t nat -A FILTER_DNS -j DNS
    elif [ "${proxy_mode}" = "skip" ] ; then
        for appid in ${appid_list[@]} ; do
            ${ip} -t mangle -I PROXY -m owner --uid-owner ${appid} ! -d ${tun_ip} -j RETURN
            ${ip} -t nat -A FILTER_DNS -m owner --uid-owner ${appid} -j RETURN
        done
        ${ip} -t mangle -A PROXY -j CLASH
        ${ip} -t nat -A FILTER_DNS -j DNS
    elif [ "${proxy_mode}" = "pick" ] ; then
        for appid in ${appid_list[@]} ; do
            ${ip} -t mangle -A PROXY -m owner --uid-owner ${appid} -j CLASH
            ${ip} -t nat -A FILTER_DNS -m owner --uid-owner ${appid} -j DNS
        done
    elif [ "${proxy_mode}" = "onlyproxy" ] ; then
        break
    fi

    ${ip} -t mangle -A OUTPUT -j PROXY
    ${ip} -t nat -A OUTPUT -j FILTER_DNS
}

probe_proxy_mode() {
    echo "" >> ${appid_file}
    sed -i '/^$/d' "${appid_file}"
    if [ -f "${appid_file}" ] ; then
        first_line=$(head -1 ${appid_file})
        if [ "${first_line}" = "ALL" ] ; then
            proxy_mode=ALL
        elif [ "${first_line}" = "bypass" ] ; then
            proxy_mode=skip
        elif [ "${first_line}" = "onlyproxy" ] ; then
            proxy_mode=onlyproxy
        else
            proxy_mode=pick
        fi
    fi

    while read appid_line ; do
        appid_text=(`echo ${appid_line}`)
        for appid_word in ${appid_text[*]} ; do
            if [ "${appid_word}" = "bypass" ] ; then
                break
            else
                appid_list=(${appid_list[*]} ${appid_word})
            fi
        done
    done < ${appid_file}
    # echo ${appid_list[*]}
}

create_dns_iptables() {
    ${ip} -t nat -N DNS
    ${ip} -t nat -A DNS -p tcp --dport 53 -j REDIRECT --to-port ${clash_dns_port}
    ${ip} -t nat -A DNS -p udp --dport 53 -j REDIRECT --to-port ${clash_dns_port}
}

flush_iptables() {
    ${ip} -t nat -D PREROUTING -j AP_PROXY
    ${ip} -t nat -D PREROUTING -j DNS

    ${ip} -t mangle -F OUTPUT
    ${ip} -t nat -F OUTPUT
    ${ip} -t mangle -F CLASH
    ${ip} -t mangle -F PROXY
    ${ip} -t nat -F FILTER_DNS
    ${ip} -t nat -F DNS
    ${ip} -t nat -F AP_PROXY

    ${ip} -t mangle -X CLASH
    ${ip} -t mangle -X PROXY
    ${ip} -t nat -X FILTER_DNS
    ${ip} -t nat -X DNS
    ${ip} -t nat -X AP_PROXY
}

disable_proxy() {
    flush_iptables 2> /dev/null
}

enable_proxy() {
    create_mangle_iptables
}

case "$1" in
  enable)
    disable_proxy && ip="ip6tables" && tun_ip="fe80::7a30:9633:73bf:8eab/64" && disable_proxy
    enable_proxy && ip="ip6tables" && tun_ip="fe80::7a30:9633:73bf:8eab/64" && enable_proxy
    ;;
  disable)
    disable_proxy && ip="ip6tables" && tun_ip="fe80::7a30:9633:73bf:8eab/64" && disable_proxy
    ;;
  restart)
    disable_proxy && ip="ip6tables" && tun_ip="fe80::7a30:9633:73bf:8eab/64" && disable_proxy
    sleep 1
    enable_proxy && ip="ip6tables" && tun_ip="fe80::7a30:9633:73bf:8eab/64" && enable_proxy
    ;;
  *)
    echo "$0:  usage:  $0 { enable | disable | restart }"
    ;;
esac