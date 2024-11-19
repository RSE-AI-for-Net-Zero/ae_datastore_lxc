How to get ``dnsmasq`` to assign static IPs for LXC
-----------------------------------------------------

Containers resolve hostnames using `dnsmasq`'s DHCP leasefile.  To ensure that ``my-container`` is always assigned same IP address after destroying and re-creating:

1. Create the file ``/etc/lxc/dnsmasq-hosts.conf`` and add this line to ``/etc/lxc/dnsmasq.conf``::

     dhcp-hostsfile=/etc/lxc/dnsmasq-hosts.conf

2. Add this line to ``/etc/default/lxc``::

     LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf

3. Delete line containing ``my-container`` from ``/var/lib/misc/dnsmasq.lxcbr0.leases``

4. Restart service ::

     sudo systemctl restart lxc-net
