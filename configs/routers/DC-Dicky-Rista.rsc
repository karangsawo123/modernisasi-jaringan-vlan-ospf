# ═══════════════════════════════════════════════════════════════════
# DC-Dicky-Rista — Router Data Center
# OSPF Router-ID: 2.2.2.2
# Area: 0.0.0.0 (Backbone)
# Interfaces: ether1 (ke HQ), ether2 (LAN DC), ether3 (backup ke CAB1),
#             ether4 (backup ke CAB2)
#
# Sumber: Laporan Praktikum Modul 3, BAB 5 §5.7, §5.10
# Penelitian: Modernisasi Infrastruktur Jaringan PT Nusantara Retail Digital
# ═══════════════════════════════════════════════════════════════════

# ─── System Identity ───
/system identity set name=DC-Dicky-Rista

# ─── IP Address ───
# Link ke HQ-Dika
/ip address add address=10.10.10.2/30 interface=ether1 comment="Link to HQ-Dika"
# Gateway LAN Data Center
/ip address add address=172.16.10.1/26 interface=ether2 comment="LAN Server"
# Link backup ke CAB1-Galih
/ip address add address=10.10.10.13/30 interface=ether3 comment="Link to CAB1-Galih (backup)"
# Link backup ke CAB2-Marist
/ip address add address=10.10.10.17/30 interface=ether4 comment="Link to CAB2-Marist (backup)"

# ─── Nonaktifkan Static Route ───
/ip route set [find static=yes] disabled=yes

# ─── OSPF v7, Router-ID 2.2.2.2 ───
/routing ospf instance add name=ospf-nusantara router-id=2.2.2.2
/routing ospf area add instance=ospf-nusantara name=area-backbone area-id=0.0.0.0

# Interface OSPF — termasuk interface backup
/routing ospf interface-template add area=area-backbone interfaces=ether1
/routing ospf interface-template add area=area-backbone interfaces=ether2
/routing ospf interface-template add area=area-backbone interfaces=ether3
/routing ospf interface-template add area=area-backbone interfaces=ether4
