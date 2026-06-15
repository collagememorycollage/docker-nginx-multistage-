#!/bin/bash
awk '{count[$9]++} END {for (c in count) print count[c], c}' access.log | sort -nr

