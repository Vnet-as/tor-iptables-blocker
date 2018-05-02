# Tor Iptables Blocker

This is simple bash script that creates set of IP addresses of Tor Exit Nodes and blocks them completely.

# Dependencies

To run this script you need to have installed these utilities:

* wget
* ipset
* iptables

This script must have root privileges to run!

# Example Run

To block IP addresses that can access IP address 192.0.2.10, run `tor-iptables-blocker.sh 192.0.2.10`.

To dynamically update ip address set every day at 6:00 for IP address 192.0.2.10, you can add line as this to crontab:

```cron
0 6 * * * root /usr/local/bin/ipset-block-tor.sh 109.74.144.181
```
