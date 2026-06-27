# ═══════════════════════════════════════════════════════════════════
# CAB1-Galih — Router Cabang Jawa Barat
# OSPF Router-ID: 3.3.3.3
# Area: 0.0.0.0 (Backbone)
# Interfaces: ether1 (ke HQ, primary), ether2 (trunk ke SW-Jabar),
#             ether3 (backup ke DC, cost=100),
#             vlan10-staff, vlan20-guest (Router-on-a-Stick)
#
# Sumber: Laporan Praktikum Modul 3, BAB 5 §5.2, §5.8, §5.11, §5.13
# Penelitian: Modernisasi Infrastruktur Jaringan PT Nusantara Retail Digital
# ═══════════════════════════════════════════════════════════════════

# ─── System Identity ───
/system identity set name=CAB1-Galih

# ─── IP Address: Link Backbone ───
# Link ke HQ-Dika (primary path)
/ip address add address=10.10.10.6/30 interface=ether1 comment="Link to HQ-Dika (primary)"
# Link backup ke DC-Dicky-Rista
/ip address add address=10.10.10.14/30 interface=ether3 comment="Link to DC-Dicky-Rista (backup)"

# ─── Inter-VLAN Routing: Router-on-a-Stick ───
# Hapus IP lama di ether2 (jika ada dari konfigurasi ATS)
/ip address remove [find interface=ether2]

# Buat sub-interface VLAN pada ether2 (trunk port)
/interface vlan add interface=ether2 name=vlan10-staff vlan-id=10
/interface vlan add interface=ether2 name=vlan20-guest vlan-id=20

# IP gateway masing-masing VLAN
/ip address add address=192.168.10.1/26 interface=vlan10-staff
/ip address add address=192.168.10.65/26 interface=vlan20-guest

# ─── Nonaktifkan Static Route ───
/ip route set [find static=yes] disabled=yes

# ─── OSPF v7, Router-ID 3.3.3.3 ───
/routing ospf instance add name=ospf-nusantara router-id=3.3.3.3
/routing ospf area add instance=ospf-nusantara name=area-backbone area-id=0.0.0.0

# Interface OSPF
/routing ospf interface-template add area=area-backbone interfaces=ether1
/routing ospf interface-template add area=area-backbone interfaces=vlan10-staff
/routing ospf interface-template add area=area-backbone interfaces=vlan20-guest
/routing ospf interface-template add area=area-backbone interfaces=ether3

# ─── OSPF Cost: Interface Backup ───
# Cost=100 agar jalur via HQ tetap menjadi primary path saat kondisi normal
/routing ospf interface-template set [find interfaces=ether3] cost=100
