####Table of Contents

4. [Usage - Configuration options and additional functionality](#usage)
    * [Multihome Support](#multihome)

<a name="multihome"></a>
###Multihome Support

There is only limited support of HBase on multiple interfaces (2015-01). Web UI access works fine, but the master and regionserver services listen only on the primary IP address.

It can be worked around. For example using NAT.

**Example NAT**: Have this /etc/hosts file:

    127.0.0.1       localhost
    
    10.2.4.12	hador-c1.ics.muni.cz	hador-c1
    147.251.9.38	hador-c1.ics.muni.cz	hador-c1

In this case the HBase will listen on the interface with 10.2.4.12 IP address. If we want to add access from external network 147.251.9.38 using NAT:

    # master
    iptables -t nat -A PREROUTING -p tcp -m tcp -d 147.251.9.38 --dport 60000 -j DNAT --to-destination 10.2.4.12:60000
    # regionservers
    iptables -t nat -A PREROUTING -p tcp -m tcp -d 147.251.9.38 --dport 60020 -j DNAT --to-destination 10.2.4.12:60020

NAT works OK also with enabled security.
