# ═══════════════════════════════════════════════════════════════════
# SW-Jatim — Managed Switch Cabang Jawa Timur
# Fungsi: Bridge VLAN Filtering (IEEE 802.1Q)
# Trunk: ether1 (ke CAB2-Marist ether2)
# Access VLAN 10 (Staf): ether2–ether5 (PVID 10)
# Access VLAN 20 (Guest): ether6–ether8 (PVID 20)
#
# Catatan: Konfigurasi identik dengan SW-Jabar, hanya berbeda identity.
#
# Sumber: Laporan Praktikum Modul 3, BAB 5 §5.1
# Penelitian: Modernisasi Infrastruktur Jaringan PT Nusantara Retail Digital
# ═══════════════════════════════════════════════════════════════════

# ─── System Identity ───
/system identity set name=SW-Jatim

# ─── 1. Buat bridge dengan VLAN filtering aktif ───
/interface bridge add name=br-vlan vlan-filtering=yes

# ─── 2. Daftarkan interface ke bridge ───
#    ether1    = trunk ke CAB2-Marist
#    ether2–5  = access port VLAN 10 (Staf)
#    ether6–8  = access port VLAN 20 (Guest)
/interface bridge port add bridge=br-vlan interface=ether1
/interface bridge port add bridge=br-vlan interface=ether2 pvid=10
/interface bridge port add bridge=br-vlan interface=ether3 pvid=10
/interface bridge port add bridge=br-vlan interface=ether4 pvid=10
/interface bridge port add bridge=br-vlan interface=ether5 pvid=10
/interface bridge port add bridge=br-vlan interface=ether6 pvid=20
/interface bridge port add bridge=br-vlan interface=ether7 pvid=20
/interface bridge port add bridge=br-vlan interface=ether8 pvid=20

# ─── 3. Konfigurasi tagged trunk port ───
# ether1 membawa VLAN 10 dan 20 secara tagged
/interface bridge vlan add bridge=br-vlan tagged=ether1 vlan-ids=10
/interface bridge vlan add bridge=br-vlan tagged=ether1 vlan-ids=20
