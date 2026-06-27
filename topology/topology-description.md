# Deskripsi Topologi Jaringan

Topologi jaringan final PT Nusantara Retail Digital setelah modernisasi (VLAN + OSPF + Partial Mesh).

Sumber: Laporan Praktikum Modul 3, BAB 3

---

## Diagram Topologi

![Topologi Jaringan Final PT Nusantara Retail Digital](topology.png)

## Gambaran Umum

Topologi terdiri dari **4 router MikroTik CHR**, **2 managed switch MikroTik CHR**, **1 server** (DNS + Web), dan **4 perangkat klien**. Arsitektur menggunakan **partial mesh** di mana HQ-Dika berfungsi sebagai hub utama, dengan dua link backup langsung dari Data Center ke masing-masing cabang.

## Komponen Topologi

| Komponen | Nama Perangkat | Fungsi | OSPF Router-ID |
|----------|----------------|--------|----------------|
| Router HQ | HQ-Dika | Hub utama, jalur transit primer | 1.1.1.1 |
| Router DC | DC-Dicky-Rista | Gateway LAN Data Center | 2.2.2.2 |
| Router Cab. Jabar | CAB1-Galih | Inter-VLAN Routing Cabang Jabar | 3.3.3.3 |
| Router Cab. Jatim | CAB2-Marist | Inter-VLAN Routing Cabang Jatim | 4.4.4.4 |
| Switch Jabar | SW-Jabar | Managed switch, Bridge VLAN Filtering | — |
| Switch Jatim | SW-Jatim | Managed switch, Bridge VLAN Filtering | — |
| Server DC | server.dc | DNS (Bind9) + Web Server (Apache2) | — |
| Backup DC | backup.dc | Server backup Data Center | — |
| Management | Cloud-Management | Akses Winbox out-of-band ke HQ | — |

## Jalur Routing

### Kondisi Normal (HQ Aktif)

Traffic dari cabang ke Data Center melewati HQ-Dika sebagai primary path:

```
pc1.cab1 → CAB1-Galih (vlan10-staff) → HQ-Dika → DC-Dicky-Rista → server.dc
                                        3 hop
```

### Kondisi Failover (HQ Down)

OSPF otomatis mengaktifkan jalur backup langsung via DC:

```
pc1.cab1 → CAB1-Galih (vlan10-staff) → DC-Dicky-Rista → server.dc
                                        2 hop
```

## Perbandingan Topologi Lama vs Revisi

| Aspek | Hub-and-Spoke (Lama) | Partial Mesh (Revisi) |
|-------|----------------------|-----------------------|
| Koneksi DC ke Cabang | Hanya via HQ | Via HQ (primary) + DC langsung (backup) |
| SPOF pada HQ | Ya | Tidak |
| Jalur saat HQ down | Tidak ada | OSPF failover otomatis |
| OSPF Neighbor DC | 1 (HQ) | 3 (HQ, CAB1, CAB2) |
| OSPF Neighbor CAB1/CAB2 | 1 (HQ) | 2 (HQ, DC) |
