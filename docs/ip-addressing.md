# Pengalamatan IP — PT Nusantara Retail Digital

Dokumen ini merangkum seluruh pengalamatan IP yang digunakan pada topologi jaringan
hasil modernisasi. Seluruh data diekstrak dari BAB 4 laporan praktikum.

---

## Backbone Antar Router (/30)

| Link | Network | IP Router A | IP Router B | Keterangan |
|------|---------|-------------|-------------|------------|
| HQ ↔ DC | 10.10.10.0/30 | 10.10.10.1 (HQ ether1) | 10.10.10.2 (DC ether1) | Primary link |
| HQ ↔ CAB1 | 10.10.10.4/30 | 10.10.10.5 (HQ ether2) | 10.10.10.6 (CAB1 ether1) | Primary link |
| HQ ↔ CAB2 | 10.10.10.8/30 | 10.10.10.9 (HQ ether3) | 10.10.10.10 (CAB2 ether1) | Primary link |
| DC ↔ CAB1 | 10.10.10.12/30 | 10.10.10.13 (DC ether3) | 10.10.10.14 (CAB1 ether3) | **Backup path** |
| DC ↔ CAB2 | 10.10.10.16/30 | 10.10.10.17 (DC ether4) | 10.10.10.18 (CAB2 ether3) | **Backup path** |

## LAN Data Center (/26)

| Network | Device | Interface | IP Address | Fungsi |
|---------|--------|-----------|------------|--------|
| 172.16.10.0/26 | DC-Dicky-Rista | ether2 | 172.16.10.1 | Gateway LAN DC |
| 172.16.10.0/26 | backup.dc | eth0 | 172.16.10.2 | Backup Server |
| 172.16.10.0/26 | server.dc | ens3 | 172.16.10.3 | DNS (Bind9) + Web (Apache2) |

## VLAN Cabang Jawa Barat (/26)

| VLAN ID | Nama | Network | Gateway (CAB1-Galih) | Range Host | Broadcast |
|---------|------|---------|----------------------|------------|-----------|
| 10 | Staf-Jabar | 192.168.10.0/26 | 192.168.10.1 | .2 – .62 | 192.168.10.63 |
| 20 | Guest-Jabar | 192.168.10.64/26 | 192.168.10.65 | .66 – .126 | 192.168.10.127 |

## VLAN Cabang Jawa Timur (/26)

| VLAN ID | Nama | Network | Gateway (CAB2-Marist) | Range Host | Broadcast |
|---------|------|---------|----------------------|------------|-----------|
| 10 | Staf-Jatim | 192.168.20.0/26 | 192.168.20.1 | .2 – .62 | 192.168.20.63 |
| 20 | Guest-Jatim | 192.168.20.64/26 | 192.168.20.65 | .66 – .126 | 192.168.20.127 |

## Management Network

| Network | Device | Interface | IP Address | Keterangan |
|---------|--------|-----------|------------|------------|
| 192.168.56.0/24 | HQ-Dika | ether4 | 192.168.56.2 | Out-of-band management (Cloud) |

## Seluruh IP Address per Device

| Device | Interface | IP Address | Network | Keterangan |
|--------|-----------|------------|---------|------------|
| HQ-Dika | ether1 | 10.10.10.1/30 | 10.10.10.0/30 | Link ke DC |
| HQ-Dika | ether2 | 10.10.10.5/30 | 10.10.10.4/30 | Link ke CAB1 |
| HQ-Dika | ether3 | 10.10.10.9/30 | 10.10.10.8/30 | Link ke CAB2 |
| HQ-Dika | ether4 | 192.168.56.2/24 | 192.168.56.0/24 | Management |
| DC-Dicky-Rista | ether1 | 10.10.10.2/30 | 10.10.10.0/30 | Link ke HQ |
| DC-Dicky-Rista | ether2 | 172.16.10.1/26 | 172.16.10.0/26 | Gateway LAN DC |
| DC-Dicky-Rista | ether3 | 10.10.10.13/30 | 10.10.10.12/30 | Backup ke CAB1 |
| DC-Dicky-Rista | ether4 | 10.10.10.17/30 | 10.10.10.16/30 | Backup ke CAB2 |
| CAB1-Galih | ether1 | 10.10.10.6/30 | 10.10.10.4/30 | Link ke HQ (primary) |
| CAB1-Galih | ether3 | 10.10.10.14/30 | 10.10.10.12/30 | Backup ke DC |
| CAB1-Galih | vlan10-staff | 192.168.10.1/26 | 192.168.10.0/26 | Gateway VLAN 10 Jabar |
| CAB1-Galih | vlan20-guest | 192.168.10.65/26 | 192.168.10.64/26 | Gateway VLAN 20 Jabar |
| CAB2-Marist | ether1 | 10.10.10.10/30 | 10.10.10.8/30 | Link ke HQ (primary) |
| CAB2-Marist | ether3 | 10.10.10.18/30 | 10.10.10.16/30 | Backup ke DC |
| CAB2-Marist | vlan10-staff | 192.168.20.1/26 | 192.168.20.0/26 | Gateway VLAN 10 Jatim |
| CAB2-Marist | vlan20-guest | 192.168.20.65/26 | 192.168.20.64/26 | Gateway VLAN 20 Jatim |
| server.dc | ens3 | 172.16.10.3/26 | 172.16.10.0/26 | DNS + Web Server |
| backup.dc | eth0 | 172.16.10.2/26 | 172.16.10.0/26 | Backup Server |
| pc1.cab1 | eth0 | 192.168.10.2/26 | 192.168.10.0/26 | VPCS Staf Jabar |
| pc2.cab1 | LAN | 192.168.10.66/26 | 192.168.10.64/26 | Win7 Guest Jabar |
| pc1.cab2 | eth0 | 192.168.20.2/26 | 192.168.20.0/26 | VPCS Staf Jatim |
| pc2.cab2 | eth0 | 192.168.20.66/26 | 192.168.20.64/26 | VPCS Guest Jatim |

## OSPF Configuration Summary

| Router | Router-ID | Area | Interfaces OSPF | Cost Khusus |
|--------|-----------|------|-----------------|-------------|
| HQ-Dika | 1.1.1.1 | 0.0.0.0 | ether1, ether2, ether3 | — |
| DC-Dicky-Rista | 2.2.2.2 | 0.0.0.0 | ether1, ether2, ether3, ether4 | — |
| CAB1-Galih | 3.3.3.3 | 0.0.0.0 | ether1, ether3, vlan10-staff, vlan20-guest | ether3: cost=100 |
| CAB2-Marist | 4.4.4.4 | 0.0.0.0 | ether1, ether3, vlan10-staff, vlan20-guest | ether3: cost=100 |
