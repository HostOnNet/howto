================================================================
ONE TIME SETUP
================================================================
Run Following on DOS Prompt (Only Needed First Time)

netsh ipsec static add policy name="Packet Filters - HOSTHAT" description="Server Hardening Policy" assign=no
netsh ipsec static add filterlist name="Banned IPS" description="Server Hardening"
netsh ipsec static add filteraction name=SecPermit description="Allows Traffic to Pass" action=permit
netsh ipsec static add filteraction name=Block description="Blocks Traffic" action=block
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=100.100.100.100 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add rule name="Banned IP Rule" policy="Packet Filters - HOSTHAT" filterlist="Banned IPS" kerberos=yes filteraction=Block


================================================================
After doing this, you need to 

Assign

The rule in

Administrative Tools > Local Seciruity Policy > IP Security

Policy Assigned = YES

================================================================
BAN AN IP
================================================================

This will create an ipsec policy and add a list of blocked ip addresses. You will need to open an mmc and add the "IP Security Policies" snapin to assign the policy to your server. From that point you can run the command:

netsh ipsec static add filter filterlist="Banned IPS" srcaddr=PUT.BANNED.IP.HERE dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0



netsh ipsec static add filter filterlist="Banned IPS" srcaddr=67.19.14.138 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=213.254.147.53 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=196.219.39.141 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=66.98.150.85 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=85.88.25.39 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=212.175.16.211 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=211.148.168.172 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=201.29.218.119 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=65.17.219.240 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=66.8.202.41 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=211.202.3.176 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=70.105.173.9 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=209.0.103.253 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=67.47.114.67 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=203.109.75.111 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
netsh ipsec static add filter filterlist="Banned IPS" srcaddr=216.134.212.92 dstaddr=me description="Banned IPS" protocol=any srcport=0 dstport=0
