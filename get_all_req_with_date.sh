#!/bin/bash
echo "ДАТА        ЧАС   КОД   КОЛ-ВО"
awk '
{

  split(substr($4, 2), a, ":")
  date = a[1]
  hour = a[2]
  status = $9

  key = date "|" hour "|" status
  count[key]++
}

END {
  
  for (k in count) {
    split(k, a, "|")
      printf "%-12s %-4s %-5s %-5d\n",
      	     a[1], a[2], a[3], count[k]
  }
}' access.log | sort
