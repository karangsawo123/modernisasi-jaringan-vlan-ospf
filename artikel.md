# [WORKING TITLE] Modernisasi Infrastruktur Jaringan Multi-Cabang melalui Integrasi VLAN, Router-on-a-Stick, OSPF, dan Partial Mesh

> **Catatan kerja (bukan bagian dari artikel):**
> - Judul di atas bersifat sementara (working title) dan belum dikunci.
> - Seluruh isi artikel ditulis dalam **Bahasa Indonesia** untuk keperluan review. Terjemahan ke Bahasa Inggris dilakukan setelah isi final.
> - **Gambar 1** (topologi) adalah placeholder — gambar asli dari GNS3 akan disisipkan saat konversi ke .docx.
> - Referensi saat ini: 5 referensi inti. Akan ditambah bertahap seiring kebutuhan klaim.

---

## Abstrak

Jaringan multi-cabang berbasis arsitektur hub-and-spoke dengan static routing menghadapi dua keterbatasan mendasar: tidak adanya segmentasi traffic antar kelompok pengguna dan kerentanan terhadap single point of failure (SPOF) pada router pusat. Penelitian ini mendokumentasikan modernisasi infrastruktur jaringan PT Nusantara Retail Digital melalui simulasi GNS3 menggunakan MikroTik Cloud Hosted Router (RouterOS v7). Modernisasi mengintegrasikan empat komponen: (1) segmentasi VLAN dengan Bridge VLAN Filtering, (2) Inter-VLAN Routing menggunakan Router-on-a-Stick, (3) migrasi dari static routing ke OSPF, dan (4) revisi topologi menjadi partial mesh melalui penambahan link backup langsung antara Data Center dan masing-masing cabang. Keberhasilan diverifikasi melalui 19 skenario pengujian terstruktur. Seluruh router membentuk adjacency OSPF dengan status Full. Pengujian failover yang diulang tiga kali menunjukkan rata-rata waktu re-konvergensi 36,73 detik — lebih cepat dari satu dead interval penuh (40 detik) — tanpa intervensi administrator. Topologi partial mesh terbukti mengeliminasi SPOF pada router HQ, sehingga akses cabang ke layanan Data Center tetap terjaga selama kondisi failover.

**Kata Kunci:** VLAN, OSPF, Router-on-a-Stick, Partial Mesh, Failover, MikroTik RouterOS

---

## 1. Pendahuluan

Jaringan multi-cabang pada perusahaan berkembang umumnya dimulai dengan arsitektur hub-and-spoke karena kesederhanaannya dalam konfigurasi dan manajemen. Pada arsitektur ini, seluruh cabang (spoke) mengarahkan komunikasinya melalui satu titik pusat (hub), dan jalur routing dikonfigurasi secara manual menggunakan static routing. Meskipun pendekatan ini efektif pada skala kecil, dua keterbatasan mendasar muncul seiring pertumbuhan jaringan.

Keterbatasan pertama adalah ketiadaan segmentasi jaringan di tingkat cabang. Seluruh perangkat dalam satu lokasi cabang berada dalam satu domain broadcast yang sama, sehingga traffic karyawan staf dan traffic tamu bercampur tanpa pemisahan logis. Tanpa segmentasi, perangkat tamu secara teoritis berada dalam subnet yang sama dengan perangkat staf, sehingga potensi akses langsung antar segmen tidak dapat dicegah pada lapisan jaringan [2].

Keterbatasan kedua adalah kerentanan terhadap single point of failure. Pada topologi hub-and-spoke murni, apabila router hub mengalami gangguan, seluruh jalur komunikasi dari cabang menuju sumber daya terpusat seperti Data Center terputus total. Static routing tidak memiliki mekanisme deteksi kegagalan maupun pemulihan otomatis, sehingga restorasi layanan sepenuhnya bergantung pada intervensi administrator [3].

PT Nusantara Retail Digital memiliki empat lokasi: Head Office (HQ), Data Center (DC), Cabang Jawa Barat, dan Cabang Jawa Timur. Jaringan sebelumnya menggunakan arsitektur hub-and-spoke dengan router HQ sebagai satu-satunya jalur transit dan static routing sebagai protokol routing. Evaluasi terhadap arsitektur tersebut mengidentifikasi kedua keterbatasan di atas: (1) kebutuhan segmentasi traffic staf dan tamu, serta (2) eliminasi SPOF pada router HQ.

Penelitian ini menjawab permasalahan tersebut melalui modernisasi yang mengintegrasikan Virtual LAN dengan metode Bridge VLAN Filtering [2], Inter-VLAN Routing menggunakan teknik Router-on-a-Stick [3], migrasi ke protokol routing OSPF (Open Shortest Path First) [1], dan revisi topologi menjadi partial mesh dengan penambahan link backup langsung dari Data Center ke masing-masing cabang. Keberhasilan modernisasi diukur melalui pengujian failover OSPF yang memvalidasi kemampuan jaringan untuk melakukan re-konvergensi secara otomatis ketika router HQ mengalami kegagalan.

---

## 2. Metode Penelitian

### 2.1 Lingkungan Simulasi

Seluruh implementasi dilaksanakan dalam lingkungan simulasi GNS3 menggunakan perangkat virtual MikroTik Cloud Hosted Router (CHR) yang menjalankan RouterOS versi 7. Pendekatan simulasi dipilih karena memungkinkan pengujian skenario failover yang sulit dan berisiko apabila dilaksanakan pada jaringan produksi aktif.

### 2.2 Topologi Jaringan

Topologi jaringan final hasil modernisasi ditampilkan pada Gambar 1. Topologi ini terdiri dari empat router MikroTik CHR, dua managed switch MikroTik CHR, satu server DNS dan Web (server.dc), dan empat perangkat klien. Dibandingkan dengan topologi hub-and-spoke awal, topologi ini menambahkan dua link fisik baru — dari DC-Dicky-Rista langsung ke CAB1-Galih dan CAB2-Marist — sehingga membentuk arsitektur partial mesh.

**[Gambar 1. Topologi Jaringan Final PT Nusantara Retail Digital — OSPF Partial Mesh]**

Spesifikasi seluruh komponen topologi dirangkum pada Tabel 1, sedangkan pengalamatan IP seluruh tautan dirangkum pada Tabel 2. Seluruh router berada dalam satu OSPF Area 0 (backbone area) dengan Router-ID yang ditetapkan secara manual.

**Tabel 1.** Komponen Topologi Jaringan

| Komponen | Nama Perangkat | Fungsi | OSPF Router-ID |
|---|---|---|---|
| Router HQ | HQ-Dika | Jalur transit primer, hub utama | 1.1.1.1 |
| Router DC | DC-Dicky-Rista | Gateway LAN Data Center | 2.2.2.2 |
| Router Cab. Jabar | CAB1-Galih | Inter-VLAN Routing, Jawa Barat | 3.3.3.3 |
| Router Cab. Jatim | CAB2-Marist | Inter-VLAN Routing, Jawa Timur | 4.4.4.4 |
| Switch Jabar | SW-Jabar | Managed switch, Bridge VLAN Filtering | — |
| Switch Jatim | SW-Jatim | Managed switch, Bridge VLAN Filtering | — |
| Server DC | server.dc | DNS (Bind9) + Web Server (Apache2) | — |

**Tabel 2.** Pengalamatan IP Tautan Backbone dan LAN

| Tautan | Subnet | Perangkat & Alamat IP | Status |
|---|---|---|---|
| HQ ↔ DC | 10.10.10.0/30 | HQ ether1: .1 / DC ether1: .2 | Primer |
| HQ ↔ CAB1 | 10.10.10.4/30 | HQ ether2: .5 / CAB1 ether1: .6 | Primer |
| HQ ↔ CAB2 | 10.10.10.8/30 | HQ ether3: .9 / CAB2 ether1: .10 | Primer |
| DC ↔ CAB1 | 10.10.10.12/30 | DC ether3: .13 / CAB1 ether3: .14 | Backup |
| DC ↔ CAB2 | 10.10.10.16/30 | DC ether4: .17 / CAB2 ether3: .18 | Backup |
| LAN Data Center | 172.16.10.0/26 | DC ether2: .1 (server.dc: .3) | LAN DC |
| VLAN 10 CAB1 | 192.168.10.0/26 | Gateway: 192.168.10.1 | Staf Jawa Barat |
| VLAN 20 CAB1 | 192.168.10.64/26 | Gateway: 192.168.10.65 | Tamu Jawa Barat |
| VLAN 10 CAB2 | 192.168.20.0/26 | Gateway: 192.168.20.1 | Staf Jawa Timur |
| VLAN 20 CAB2 | 192.168.20.64/26 | Gateway: 192.168.20.65 | Tamu Jawa Timur |

### 2.3 Tahapan Implementasi

Modernisasi dilaksanakan dalam empat tahap berurutan.

**Tahap 1 — Bridge VLAN Filtering.** Pada SW-Jabar dan SW-Jatim, fitur Bridge VLAN Filtering diaktifkan sesuai standar IEEE 802.1Q [2]. Interface ether1 pada kedua switch dikonfigurasi sebagai trunk port dengan VLAN 10 dan 20 berstatus tagged, sedangkan ether2–ether5 dikonfigurasi sebagai access port VLAN 10 (PVID 10) dan ether6–ether8 sebagai access port VLAN 20 (PVID 20).

**Tahap 2 — Router-on-a-Stick.** Pada CAB1-Galih dan CAB2-Marist, IP address pada interface fisik ether2 dihapus dan digantikan dengan dua sub-interface logical: `vlan10-staff` sebagai gateway VLAN 10 dan `vlan20-guest` sebagai gateway VLAN 20. Interface fisik ether2 berfungsi sebagai trunk port yang meneruskan frame bertag IEEE 802.1Q dari kedua VLAN tanpa memiliki IP address langsung [3].

**Tahap 3 — Migrasi ke OSPF.** Static route pada seluruh router dinonaktifkan untuk mencegah konflik administrative distance. Instance OSPF dengan Area 0 (backbone) dan Router-ID masing-masing dikonfigurasi pada keempat router. Seluruh interface yang relevan didaftarkan ke dalam OSPF area backbone. Parameter Hello interval (10 detik) dan Dead interval (40 detik) menggunakan nilai default MikroTik RouterOS v7 [1][4].

**Tahap 4 — Partial Mesh dan Konfigurasi Cost.** Dua link fisik baru ditambahkan: DC ether3 ke CAB1 ether3 (subnet 10.10.10.12/30) dan DC ether4 ke CAB2 ether3 (subnet 10.10.10.16/30). Kedua interface baru didaftarkan ke OSPF. Untuk mengarahkan pemilihan jalur, OSPF cost pada interface backup (ether3) dinaikkan secara manual menjadi 100 di CAB1-Galih dan CAB2-Marist, sehingga accumulated cost jalur backup menjadi lebih tinggi dibandingkan jalur via HQ yang menggunakan cost default sebesar 1 [1].

Konfigurasi lengkap seluruh perangkat tersedia pada repositori GitHub: **[URL repositori — akan diisi sebelum submission]**.

### 2.4 Skenario Pengujian

Pengujian dilaksanakan dalam dua kondisi: kondisi normal (HQ-Dika aktif) dan kondisi failover (HQ-Dika dimatikan sepenuhnya). Total terdapat 19 skenario pengujian yang mencakup: verifikasi OSPF neighbor state, verifikasi routing table dan primary path, konektivitas ping dari keempat klien VLAN, traceroute, pengukuran waktu failover (diulang tiga kali untuk mendapatkan data representatif), resolusi DNS, akses web server, dan ping antar-cabang.

---

## 3. Hasil dan Pembahasan

### 3.1 Implementasi VLAN dan Inter-VLAN Routing

Konfigurasi Bridge VLAN Filtering pada SW-Jabar dan SW-Jatim berhasil memisahkan traffic VLAN 10 (Staf) dan VLAN 20 (Tamu) ke dalam domain broadcast yang berbeda di setiap cabang. Pengujian ping dari klien VLAN 10 (pc1.cab1, 192.168.10.2) ke gateway VLAN 10 (192.168.10.1) menghasilkan reply, demikian pula dari klien VLAN 20 (pc2.cab1, 192.168.10.66) ke gateway VLAN 20 (192.168.10.65). Hasil yang identik diperoleh di Cabang Jawa Timur.

Teknik Router-on-a-Stick pada CAB1-Galih dan CAB2-Marist berfungsi sebagaimana dirancang. Interface fisik ether2 yang tidak memiliki IP address langsung berhasil meneruskan frame dari dua VLAN berbeda secara bersamaan melalui satu kabel fisik, dengan routing antar VLAN dilaksanakan oleh dua sub-interface logical. Seluruh klien dari kedua VLAN berhasil mencapai server.dc di Data Center, membuktikan bahwa Inter-VLAN Routing dan OSPF bekerja secara terintegrasi.

### 3.2 OSPF Adjacency dan Routing Table

Seluruh router berhasil membentuk adjacency OSPF dengan status **Full** — status tertinggi dalam proses pembentukan neighbor OSPF yang menandakan bahwa pertukaran Link State Advertisement (LSA) telah selesai dan database topologi tersinkronisasi antar router [1]. Pada topologi partial mesh final, DC-Dicky-Rista memiliki tiga OSPF neighbor (HQ-Dika, CAB1-Galih, CAB2-Marist), sedangkan CAB1-Galih dan CAB2-Marist masing-masing memiliki dua neighbor (HQ-Dika dan DC-Dicky-Rista).

Routing table pada seluruh router terisi dengan rute dinamis bertanda flag **DAo** (Dynamic, Active, OSPF) dengan administrative distance 110. Tidak ada rute manual yang aktif — seluruh distribusi informasi routing berlangsung otomatis melalui OSPF.

Verifikasi primary path pada CAB1-Galih menunjukkan bahwa rute menuju 172.16.10.0/26 (LAN Data Center) menggunakan next-hop **10.10.10.5** (ether2 HQ-Dika via ether1 CAB1), bukan 10.10.10.13 (jalur backup DC langsung). Hal ini mengonfirmasi bahwa konfigurasi cost manual (cost=100) pada interface backup berhasil mengarahkan OSPF untuk memilih jalur via HQ sebagai primary path saat kondisi normal, sesuai tujuan implementasi [1][4].

### 3.3 Pengujian Failover OSPF

Pengujian failover dilaksanakan dengan mematikan router HQ-Dika sepenuhnya dan mengamati durasi timeout ping dari pc1.cab1 ke server.dc hingga konektivitas kembali pulih. Pengujian diulang tiga kali untuk mendapatkan data yang representatif. Hasil selengkapnya disajikan pada Tabel 3.

**Tabel 3.** Hasil Pengukuran Waktu Failover OSPF (n = 3)

| Percobaan | Waktu Failover | Catatan |
|---|---|---|
| 1 | 37,92 detik | Ping timeout → reply kembali |
| 2 | 36,61 detik | Ping timeout → reply kembali |
| 3 | 35,65 detik | Ping timeout → reply kembali |
| **Rata-rata** | **36,73 detik** | — |

Perbandingan antara nilai teoritis dan hasil aktual disajikan pada Tabel 4.

**Tabel 4.** Perbandingan Nilai Teoritis dan Aktual Failover OSPF

| Parameter | Teoritis | Aktual |
|---|---|---|
| Dead interval | 40 detik | 40 detik |
| SPF recalculate | 1–3 detik | < 1 detik |
| Total waktu failover | 40–60 detik | 36,73 detik (rata-rata) |
| Latensi ping setelah failover | ~2 ms | 9,599 ms |

Rata-rata waktu failover sebesar 36,73 detik lebih cepat dari satu dead interval penuh (40 detik). Hal ini diduga disebabkan oleh dua faktor: pertama, HQ-Dika kemungkinan dimatikan pada pertengahan siklus Hello sehingga dead timer router tetangga telah berjalan sebagian sebelum penonaktifan; kedua, proses SPF recalculate berlangsung sangat cepat (< 1 detik) segera setelah dead timer habis [1][4].

Setelah re-konvergensi selesai, routing table CAB1-Galih menunjukkan perubahan next-hop untuk rute 172.16.10.0/26 dari 10.10.10.5 (HQ-Dika) menjadi **10.10.10.13** (DC-Dicky-Rista, via ether3 backup), membuktikan bahwa OSPF berhasil mengaktifkan jalur backup secara otomatis tanpa intervensi administrator.

Verifikasi lanjutan dilakukan melalui traceroute dari pc1.cab1 ke server.dc (172.16.10.3). Pada kondisi normal, traceroute menunjukkan **3 hop**: gateway VLAN 10 (192.168.10.1) → HQ-Dika → server.dc. Setelah failover, traceroute menunjukkan **2 hop**: gateway VLAN 10 (192.168.10.1) → DC-Dicky-Rista (10.10.10.13) → server.dc. Pengurangan satu hop ini konsisten dengan bypass terhadap router HQ-Dika, dan dikonfirmasi oleh peningkatan nilai TTL pada reply ping dari **61** (kondisi normal, 3 hop) menjadi **62** (kondisi failover, 2 hop).

### 3.4 Resolusi DNS dan Akses Web Server saat Failover

Layanan DNS (Bind9) dan Web Server (Apache2) pada server.dc (172.16.10.3) diuji dalam kondisi failover (HQ-Dika down) untuk memverifikasi ketersediaan layanan selama re-konvergensi. Pengujian dari pc1.cab1 (VLAN 10) berhasil melakukan resolusi nama domain `inventory.nusantara.local` menjadi alamat IP 172.16.10.3 melalui jalur backup. Pengujian akses web dari pc2.cab1 (VLAN 20) berhasil memuat halaman dashboard internal PT Nusantara Retail Digital melalui browser, membuktikan konektivitas end-to-end dari klien ke server Data Center tetap terjaga meskipun router HQ tidak aktif.

### 3.5 Ringkasan Hasil Pengujian

Seluruh 19 skenario pengujian berhasil. Ringkasan hasil pengujian utama disajikan pada Tabel 5.

**Tabel 5.** Ringkasan Hasil Pengujian

| No | Skenario Pengujian | Kondisi | Hasil |
|---|---|---|---|
| 1 | OSPF Neighbor HQ-Dika (ke DC, CAB1, CAB2) | Normal | Full ✓ |
| 2 | OSPF Neighbor DC-Dicky-Rista (ke HQ, CAB1, CAB2) | Normal | Full ✓ |
| 3 | OSPF Neighbor CAB1-Galih (ke HQ dan DC, 2 neighbor) | Normal | Full ✓ |
| 4 | OSPF Neighbor CAB2-Marist (ke HQ dan DC, 2 neighbor) | Normal | Full ✓ |
| 5 | Routing table — flag DAo pada seluruh rute OSPF | Normal | DAo ✓ |
| 6 | Primary path 172.16.10.0/26 via 10.10.10.5 (HQ) | Normal | Terverifikasi ✓ |
| 7 | Ping VLAN 10 → gateway (192.168.10.1) | Normal | Reply ✓ |
| 8 | Ping VLAN 20 → gateway (192.168.10.65) | Normal | Reply ✓ |
| 9 | Ping Staf Jabar (pc1.cab1) → server.dc | Normal | Reply ✓ |
| 10 | Ping Guest Jabar (pc2.cab1) → server.dc | Normal | Reply ✓ |
| 11 | Ping Staf Jatim (pc1.cab2) → server.dc | Normal | Reply ✓ |
| 12 | Ping Guest Jatim (pc2.cab2) → server.dc | Normal | Reply ✓ |
| 13 | Traceroute normal (3 hop via HQ) | Normal | 3 hop ✓ |
| 14 | Ping antar-cabang (pc1.cab1 → 192.168.20.2) | Normal | Reply ✓ |
| 15 | OSPF Neighbor CAB1-Galih setelah HQ down | Failover | DC Full ✓ |
| 16 | Routing table CAB1 setelah HQ down (via 10.10.10.13) | Failover | Terverifikasi ✓ |
| 17 | Ping ke server.dc saat HQ down | Failover | Reply ✓ |
| 18 | Traceroute saat HQ down (2 hop via DC langsung) | Failover | 2 hop ✓ |
| 19 | DNS Resolution dan Akses Web Server saat failover | Failover | Berhasil ✓ |

### 3.6 Pembahasan

**Efektivitas segmentasi VLAN dan Router-on-a-Stick.** Implementasi Bridge VLAN Filtering berhasil memisahkan domain broadcast di setiap cabang menjadi dua segmen logis yang terisolasi. Tanpa router, frame dari VLAN 10 tidak dapat menjangkau VLAN 20 karena keduanya berada dalam domain broadcast yang berbeda [2]. Teknik Router-on-a-Stick memungkinkan Inter-VLAN Routing melalui satu interface fisik, sehingga biaya infrastruktur dapat diminimalkan tanpa mengorbankan pemisahan logis antar segmen jaringan [3].

**Keunggulan OSPF dibandingkan Static Routing.** Migrasi ke OSPF menghasilkan routing table yang bersifat dinamis dan self-healing. Perbandingan antara static routing dan OSPF pada aspek-aspek kritis disajikan pada Tabel 6.

**Tabel 6.** Perbandingan Static Routing dan OSPF

| Aspek | Static Routing | OSPF |
|---|---|---|
| Konfigurasi rute | Manual per router | Otomatis via LSA exchange |
| Respons terhadap link down | Tidak ada — traffic terputus | Re-konvergensi otomatis |
| Penambahan perangkat baru | Update manual di semua router | Cukup aktifkan OSPF di perangkat baru |
| Visibilitas topologi | Terbatas pada konfigurasi lokal | Lengkap — setiap router memiliki peta topologi |
| Self-healing | Tidak ada | Ada — reroute otomatis via SPF recalculate |

**Efektivitas mekanisme cost dalam mengendalikan pemilihan jalur.** Konfigurasi cost manual sebesar 100 pada interface backup (ether3) di CAB1-Galih dan CAB2-Marist berhasil menjaga HQ-Dika sebagai primary path saat kondisi normal. OSPF memilih jalur berdasarkan total accumulated cost terendah; dengan cost default interface utama sebesar 1, jalur via HQ memiliki accumulated cost yang jauh lebih rendah dibandingkan jalur backup [1]. Ketika HQ-Dika down, jalur backup menjadi satu-satunya pilihan yang tersedia dan diaktifkan secara otomatis — membuktikan bahwa mekanisme cost tidak menghalangi fungsi failover.

**Analisis waktu re-konvergensi.** Rata-rata waktu failover 36,73 detik berada di bawah batas satu dead interval (40 detik), yang merupakan batas teoritis minimum sebelum neighbor dinyatakan down. Variasi antar pengujian (±1,14 detik dari rata-rata) diduga mencerminkan ketidakpastian timing antara saat penonaktifan HQ dan posisi siklus Hello yang sedang berjalan. Nilai ini berada dalam batas toleransi operasional [1][3].

**Keterbatasan penelitian.** Seluruh pengujian dilaksanakan dalam lingkungan simulasi GNS3 menggunakan perangkat virtual. Waktu re-konvergensi aktual pada implementasi perangkat keras fisik dapat berbeda karena perbedaan karakteristik CPU, media transmisi fisik, dan beban traffic nyata. Selain itu, pengujian failover hanya dilaksanakan dari satu titik pengamatan (CAB1-Galih) dan tidak mencakup skenario kegagalan ganda. Validasi pada jaringan fisik nyata diperlukan untuk mengkonfirmasi performa dalam kondisi produksi.

---

## 4. Kesimpulan

Modernisasi infrastruktur jaringan PT Nusantara Retail Digital melalui integrasi VLAN, Router-on-a-Stick, OSPF, dan partial mesh topology berhasil menjawab dua permasalahan utama yang diidentifikasi pada fase sebelumnya.

Pertama, implementasi VLAN dengan metode Bridge VLAN Filtering pada managed switch MikroTik CHR berhasil memisahkan traffic staf (VLAN 10) dan tamu (VLAN 20) ke dalam domain broadcast yang berbeda di setiap cabang. Inter-VLAN Routing melalui teknik Router-on-a-Stick memastikan bahwa komunikasi antar VLAN hanya dapat terjadi melalui router, sehingga mendukung penerapan kebijakan akses yang lebih granular tanpa penambahan infrastruktur fisik.

Kedua, migrasi ke OSPF menghasilkan routing table yang bersifat dinamis: seluruh router berhasil membentuk adjacency dengan status Full dan mendistribusikan informasi routing secara otomatis tanpa konfigurasi rute manual. Revisi topologi menjadi partial mesh dengan penambahan dua link backup antara Data Center dan masing-masing cabang berhasil mengeliminasi SPOF pada router HQ-Dika. Pengujian failover yang dilaksanakan tiga kali menghasilkan rata-rata waktu re-konvergensi sebesar **36,73 detik** — lebih cepat dari satu dead interval (40 detik) — tanpa memerlukan intervensi administrator. Konfigurasi cost manual (cost=100) pada interface backup memastikan HQ-Dika tetap berfungsi sebagai primary path saat kondisi jaringan normal.

Seluruh 19 skenario pengujian berhasil, termasuk verifikasi DNS resolution dan akses web server yang tetap berfungsi selama kondisi failover berlangsung.

Penelitian lanjutan disarankan untuk melakukan validasi pada perangkat keras fisik dan mengeksplorasi pengembangan arsitektur seperti penerapan multi-area OSPF untuk mendukung skalabilitas jaringan yang lebih tinggi.

---

## Referensi

[1] J. Moy, "OSPF Version 2," RFC 2328, Internet Engineering Task Force (IETF), Apr. 1998.

[2] IEEE, "IEEE Standard for Local and Metropolitan Area Networks—Bridges and Bridged Networks," IEEE Std 802.1Q-2018, IEEE, 2018.

[3] A. S. Tanenbaum and D. J. Wetherall, *Computer Networks*, 5th ed. Upper Saddle River, NJ: Prentice Hall, 2011.

[4] MikroTik, "OSPF - RouterOS Documentation," MikroTik Ltd., Riga, Latvia, 2024. [Online]. Available: https://help.mikrotik.com/docs/display/ROS/OSPF

[5] MikroTik, "Bridge - RouterOS Documentation," MikroTik Ltd., Riga, Latvia, 2024. [Online]. Available: https://help.mikrotik.com/docs/display/ROS/Bridge
