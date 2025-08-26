# 2025-08-27 01:43:45 by RouterOS 7.16
# software id =
#
/interface ethernet set [ find default-name=ether1 ] disable-running-check=no
/interface ethernet set [ find default-name=ether2 ] disable-running-check=no
/interface ethernet set [ find default-name=ether3 ] disable-running-check=no
/interface ethernet set [ find default-name=ether4 ] disable-running-check=no
/interface ethernet set [ find default-name=ether5 ] disable-running-check=no
/interface ethernet set [ find default-name=ether6 ] disable-running-check=no
/interface ethernet set [ find default-name=ether7 ] disable-running-check=no
/interface ethernet set [ find default-name=ether8 ] disable-running-check=no
/port set 0 name=serial0
/routing ospf instance add disabled=no name=ospf-instance-1 originate-default=always redistribute=connected,static,ospf,bgp,dhcp
/routing ospf area add disabled=no instance=ospf-instance-1 name=ospf-area-1
/ip address add address=10.10.1.1/24 comment=R2 interface=ether4 network=10.10.1.0
/ip address add address=10.10.2.1/24 comment=R3 interface=ether5 network=10.10.2.0
/ip address add address=172.166.10.100/24 comment=ISP2 interface=ether3 network=172.166.10.0
/ip address add address=171.99.10.100/24 comment=ISP1 interface=ether1 network=171.99.10.0
/ip dhcp-client add interface=ether1
/ip dhcp-client add disabled=yes interface=ether8
/ip firewall nat add action=masquerade chain=srcnat out-interface=ether1 priority=100
/ip firewall nat add action=masquerade chain=srcnat out-interface=ether3 priority=110
/ip route add disabled=no distance=1 dst-address=0.0.0.0/0 gateway=172.166.10.1 routing-table=main scope=30 suppress-hw-offload=no target-scope=10
/ip route add disabled=no distance=1 dst-address=0.0.0.0/0 gateway=171.99.10.1 routing-table=main scope=30 suppress-hw-offload=no target-scope=10
/routing bgp connection add address-families=ip as=2250 disabled=no local.role=ibgp name=BGP-ISP2 output.redistribute=connected,static,ospf,bgp,dhcp remote.address=172.166.10.1/32 .as=2250 router-id=172.166.10.100 routing-table=main
/routing bgp connection add address-families=ip as=5555 disabled=no local.role=ibgp name=BGP-ISP1 output.redistribute=connected,static,ospf,bgp,dhcp remote.address=171.99.10.1/32 .as=5555 router-id=171.99.10.100 routing-table=main
/routing ospf interface-template add area=ospf-area-1 disabled=no interfaces=ether4
/routing ospf interface-template add area=ospf-area-1 disabled=no interfaces=ether5
/routing rule add action=lookup-only-in-table disabled=no interface=ether1 table=main
/system identity set name=R1
/system note set show-at-login=no
/tool romon set enabled=yes id=00:00:00:00:00:01
