# ═══════════════════════════════════════════════════════════════════
# HQ-Dika — Router Head Office
# OSPF Router-ID: 1.1.1.1
# Area: 0.0.0.0 (Backbone)
# Interfaces: ether1 (ke DC), ether2 (ke CAB1), ether3 (ke CAB2)
#
# Sumber: Laporan Praktikum Modul 3, BAB 5 §5.6
# Penelitian: Modernisasi Infrastruktur Jaringan PT Nusantara Retail Digital
# ═══════════════════════════════════════════════════════════════════

# ─── System Identity ───
/system identity set name=HQ-Dika

# ─── IP Address ───
# Link ke DC-Dicky-Rista
/ip address add address=10.10.10.1/30 interface=ether1 comment="Link to DC-Dicky-Rista"
# Link ke CAB1-Galih
/ip address add address=10.10.10.5/30 interface=ether2 comment="Link to CAB1-Galih"
# Link ke CAB2-Marist
/ip address add address=10.10.10.9/30 interface=ether3 comment="Link to CAB2-Marist"
# Management (Cloud — out-of-band, tidak masuk OSPF)
/ip address add address=192.168.56.2/24 interface=ether4 comment="Management (Cloud)"

# ─── Nonaktifkan Static Route ───
/ip route set [find static=yes] disabled=yes

# ─── OSPF v7, Router-ID 1.1.1.1 ───
/routing ospf instance add name=ospf-nusantara router-id=1.1.1.1
/routing ospf area add instance=ospf-nusantara name=area-backbone area-id=0.0.0.0

# Iklankan ketiga interface backbone
/routing ospf interface-template add area=area-backbone interfaces=ether1
/routing ospf interface-template add area=area-backbone interfaces=ether2
/routing ospf interface-template add area=area-backbone interfaces=ether3
