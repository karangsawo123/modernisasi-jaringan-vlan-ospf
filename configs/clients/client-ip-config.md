# Konfigurasi IP Client

Konfigurasi IP address untuk keempat perangkat klien pada simulasi GNS3.

Sumber: Laporan Praktikum Modul 3, BAB 5 §5.4

---

## pc1.cab1 — VPCS Staf Jawa Barat (VLAN 10)

- **Terhubung ke:** SW-Jabar ether2 (Access VLAN 10)
- **VLAN:** 10 (Staf)

```
ip 192.168.10.2/26 192.168.10.1
ip dns 172.16.10.3
```

## pc2.cab1 — Windows 7 Guest Jawa Barat (VLAN 20)

- **Terhubung ke:** SW-Jabar ether6 (Access VLAN 20)
- **VLAN:** 20 (Guest)
- **Konfigurasi via:** Control Panel → Network Connections

| Parameter | Nilai |
|-----------|-------|
| IP Address | 192.168.10.66 |
| Subnet Mask | 255.255.255.192 (/26) |
| Default Gateway | 192.168.10.65 |
| DNS Server | 172.16.10.3 |

## pc1.cab2 — VPCS Staf Jawa Timur (VLAN 10)

- **Terhubung ke:** SW-Jatim ether2 (Access VLAN 10)
- **VLAN:** 10 (Staf)

```
ip 192.168.20.2/26 192.168.20.1
ip dns 172.16.10.3
```

## pc2.cab2 — VPCS Guest Jawa Timur (VLAN 20)

- **Terhubung ke:** SW-Jatim ether6 (Access VLAN 20)
- **VLAN:** 20 (Guest)

```
ip 192.168.20.66/26 192.168.20.65
ip dns 172.16.10.3
```
