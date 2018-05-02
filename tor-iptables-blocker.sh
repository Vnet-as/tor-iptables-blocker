#!/bin/bash

set -e
set -u
set -o pipefail

IPSET_SETNAME="tor"
EXIT_LIST_URL="https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip="
TOR_LIST_FILE="/tmp/tor-exit-nodes.txt"
LOG_FILE="/tmp/ipset-tor-exit-nodes.log"
SERVER_IP="$1"

if ! command -v ipset > /dev/null; then
    echo "ERROR: ipset is not installed" | tee "${LOG_FILE}"
    exit 1
elif ! command -v wget > /dev/null; then
    echo "ERROR: wget is not installed" | tee "${LOG_FILE}"
    exit 1
elif ! command -v iptables > /dev/null; then
    echo "ERROR: iptables is not installed" | tee "${LOG_FILE}"
    exit 1
fi


rm -f "${TOR_LIST_FILE}"
if ! wget -q "${EXIT_LIST_URL}${SERVER_IP}" -O "${TOR_LIST_FILE}"; then
    echo "ERROR: wget of URL ${EXIT_LIST_URL}${SERVER_IP} failed" | tee "${LOG_FILE}"
    exit 2
else
    sed -i "/^#.*/d" "${TOR_LIST_FILE}"
fi

if [ ! -f "${TOR_LIST_FILE}" ]; then
    echo "ERROR: file ${TOR_LIST_FILE} doesn't exist" | tee "${LOG_FILE}"
    exit 2
fi

if ! ipset -q -name list ${IPSET_SETNAME} > /dev/null; then
    ipset -q create ${IPSET_SETNAME} hash:ip
fi

ipset -q flush ${IPSET_SETNAME}
while read -r IP; do
    ipset add -q ${IPSET_SETNAME} "$IP"
done < "${TOR_LIST_FILE}"

if ! iptables -nL | grep -q "DROP.*match-set.*${IPSET_SETNAME}.*src"; then
    iptables -I INPUT 1 -m set --match-set ${IPSET_SETNAME} src -j DROP
fi

exit 0
