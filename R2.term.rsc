# 2025-08-27 01:46:20 by RouterOS 7.16
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
/interface vrrp add interface=ether2 name=vrrp1-ipv4
/interface vlan add interface=ether3 name=vlan10 vlan-id=10
/interface vlan add interface=ether3 name=vlan20 vlan-id=20
/port set 0 name=serial0
/routing ospf instance add disabled=no name=ospf-instance-1 redistribute=connected,static,ospf,bgp,dhcp
/routing ospf area add disabled=no instance=ospf-instance-1 name=ospf-area-1
/ip address add address=10.10.1.2/24 comment=R1 interface=ether1 network=10.10.1.0
/ip address add address=10.10.3.1/24 comment=R3 interface=ether2 network=10.10.3.0
/ip address add address=10.10.10.1/30 comment=VRRP-IPV4 interface=vrrp1-ipv4 network=10.10.10.0
/ip address add address=192.168.10.1/24 comment=VLAN10 interface=vlan10 network=192.168.10.0
/ip address add address=192.168.20.1/24 comment=VLAN20 interface=vlan20 network=192.168.20.0
/ip dhcp-client add disabled=yes interface=ether1
/ip dhcp-server network add address=192.168.10.0/24 gateway=192.168.10.1
/ip dhcp-server network add address=192.168.20.0/24 gateway=192.168.20.1
/ip firewall nat add action=masquerade chain=srcnat out-interface=ether1
/routing ospf interface-template add area=ospf-area-1 disabled=no interfaces=ether1
/routing ospf interface-template add area=ospf-area-1 cost=2 disabled=no interfaces=ether2
/system identity set name=R2
/system note set show-at-login=no
/tool romon set enabled=yes
