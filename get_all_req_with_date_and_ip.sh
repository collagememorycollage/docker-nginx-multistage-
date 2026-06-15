#!/bin/bash
awk '
{
    split(substr($4,2), a, ":")

    ip     = $1
    date   = a[1]
    hour   = a[2]
    status = $9

    key = ip "|" date "|" hour "|" status
    count[key]++
}

END {
    for (k in count) {
        split(k, a, "|")
        printf "%s|%s|%s|%s|%d\n",
               a[1], a[2], a[3], a[4], count[k]
    }
}' access.log |
sort -t'|' -k1,1 -k2,2 -k3,3n -k4,4n |
awk -F'|' '
BEGIN {
    printf "%-15s %-12s %-5s %-5s %-5s\n",
           "IP", "DATE", "HOUR", "CODE", "COUNT"
}
{
    ip   = $1
    date = $2

    if (ip == prev_ip)
        ip_out = "-"
    else
        ip_out = ip

    if (ip == prev_ip && date == prev_date)
        date_out = "-"
    else
        date_out = date

    printf "%-15s %-12s %-5s %-5s %-5s\n",
           ip_out, date_out, $3, $4, $5

    prev_ip = ip
    prev_date = date
}'
