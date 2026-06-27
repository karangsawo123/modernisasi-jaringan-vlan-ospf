<!--
CATATAN KONVERSI (bukan bagian dari isi laporan asli):
File ini adalah hasil konversi setia (tanpa peringkasan, penghapusan, atau penambahan teori)
dari dokumen Word "MODERNISASI_INFRASTRUKTUR_JARINGAN_IMPLEMENTASI_VLAN_DAN_DYNAMIC_ROUTING_OSPF_PADA_PT_NUSANTARA_RETAIL_DIGITAL_2_.docx"
ke format Markdown. Setiap gambar pada dokumen asli digantikan dengan blok deskripsi kontekstual
bertanda "🖼️ DESKRIPSI GAMBAR" agar AI lain dapat memahami isi gambar tanpa membuka file Word
maupun gambar aslinya. Seluruh struktur BAB, sub-BAB, tabel, daftar, konfigurasi CLI, analisis,
dan kesimpulan dipertahankan sesuai urutan dan isi dokumen asli.
-->

# MODERNISASI INFRASTRUKTUR JARINGAN: IMPLEMENTASI VLAN DAN DYNAMIC ROUTING OSPF DENGAN MEKANISME FAILOVER PADA PT NUSANTARA RETAIL DIGITAL

**Disusun Untuk Memenuhi Tugas Pada Mata Kuliah Desain Manajemen Jaringan**

**Dosen Pengampu:**
*Andy Muhammad Teguh, S.Kom., M.Kom*

**Oleh:**
- M. Dicky Andrean (230602070)
- Rista Ifanka (230602065)
- Marist Zaimah (230602024)
- Suprobo Galih S (230602060)
- Alvian Ramandika (230602069)

**PROGRAM STUDI TEKNIK INFORMATIKA**
**FAKULTAS TEKNIK**
**2026**

> 🖼️ **DESKRIPSI GAMBAR — Logo pada Halaman Sampul (tidak memiliki nomor Gambar resmi pada dokumen asli)**
>
> **Apa yang terlihat:** Logo lembaga berbentuk lambang bulat (seal) berwarna dasar biru tua dengan garis tepi kuning bergelombang (bentuk bintang/seal khas logo perguruan tinggi). Di bagian tengah terdapat simbol matahari/bintang bersinar berwarna kuning dengan tulisan Arab kecil di tengahnya, diapit oleh untaian padi (kuning) di sisi kiri dan untaian bunga/melati (putih-hijau) di sisi kanan, serta dua bintang kecil di bagian bawah. Teks melingkar pada tepi logo bertuliskan "UNIVERSITAS MUHAMMADIYAH" pada bagian atas dan "GRESIK" pada bagian bawah.
> **Tujuan gambar:** Logo resmi identitas lembaga (Universitas Muhammadiyah Gresik) yang ditampilkan pada halaman sampul laporan, menandakan institusi asal penyusun laporan.
> **Informasi penting:** Mengonfirmasi bahwa laporan ini disusun di lingkungan akademik Universitas Muhammadiyah Gresik, Program Studi Teknik Informatika, Fakultas Teknik.

---

## KATA PENGANTAR

Puji syukur kehadirat Tuhan Yang Maha Esa atas segala rahmat dan karunia-Nya sehingga penulis dapat menyelesaikan laporan Praktikum Modul 3 pada mata kuliah Desain Manajemen Jaringan dengan baik dan tepat waktu.

Laporan ini merupakan kelanjutan dari proyek jaringan yang diselesaikan pada Asesmen Tengah Semester (ATS) sebelumnya. Sebagai realisasi dari saran pengembangan pada laporan ATS, modul ini mendokumentasikan modernisasi infrastruktur jaringan PT Nusantara Retail Digital melalui dua implementasi utama: segmentasi departemen menggunakan VLAN dan migrasi protokol routing dari Static Routing menuju OSPF (Open Shortest Path First). Laporan ini juga mencakup revisi topologi yang dilakukan berdasarkan evaluasi dosen untuk menghilangkan single point of failure pada Router HQ-Dika.

Penulis mengucapkan terima kasih kepada Bapak Andy Muhammad Teguh, S.Kom., M.Kom., selaku dosen pengampu mata kuliah Desain Manajemen Jaringan, seluruh anggota kelompok yang telah bekerja sama, serta semua pihak yang telah memberikan dukungan dalam penyusunan laporan ini.

Gresik, 17 Juni 2026

Penulis

---

## BAB 1. PENDAHULUAN

### 1.1 Latar Belakang

Pada fase pertama pengembangan infrastruktur jaringan PT Nusantara Retail Digital, telah berhasil diimplementasikan backbone berbasis arsitektur hub-and-spoke menggunakan static routing. Jaringan tersebut menghubungkan Head Office (HQ), Data Center (DC), Cabang Jawa Barat, dan Cabang Jawa Timur secara terintegrasi dengan layanan DNS dan Web Server yang berjalan di Debian Server pada Data Center.

Seiring pertumbuhan perusahaan, dua kebutuhan mendasar muncul yang tidak dapat dipenuhi oleh konfigurasi sebelumnya. Pertama, kebutuhan segmentasi jaringan di setiap cabang untuk memisahkan traffic karyawan staf dari traffic tamu (guest) demi keamanan. Kedua, kebutuhan protokol routing yang lebih adaptif dan mampu melakukan pemulihan otomatis (self-healing) apabila terjadi gangguan pada jalur komunikasi.

Selain itu, berdasarkan evaluasi dosen, topologi awal memiliki kelemahan berupa single point of failure pada Router HQ-Dika. Apabila HQ-Dika mengalami gangguan, seluruh komunikasi dari cabang menuju Data Center akan terputus karena tidak ada jalur alternatif. Oleh karena itu, dilakukan revisi topologi dengan menambahkan link langsung antara DC-Dicky-Rista dengan CAB1-Galih dan CAB2-Marist, sehingga terbentuk topologi partial mesh yang mendukung failover otomatis berbasis OSPF.

Laporan ini mendokumentasikan modernisasi infrastruktur jaringan PT Nusantara Retail Digital beserta revisi topologi tersebut.

### 1.2 Rumusan Masalah

- Bagaimana mengimplementasikan segmentasi jaringan menggunakan VLAN 10 (Staf) dan VLAN 20 (Guest) di Cabang Jabar dan Cabang Jatim?
- Bagaimana mengonfigurasi managed switch berbasis MikroTik CHR dengan metode Bridge VLAN Filtering?
- Bagaimana mengimplementasikan Inter-VLAN Routing menggunakan teknik Router-on-a-Stick pada Router CAB1-Galih dan CAB2-Marist?
- Bagaimana memigrasi protokol routing dari Static Routing ke OSPF pada seluruh router?
- Bagaimana menghilangkan single point of failure pada Router HQ-Dika agar cabang tetap dapat mengakses Data Center apabila HQ down?
- Bagaimana memverifikasi failover OSPF otomatis melalui pengujian konektivitas saat HQ down?

### 1.3 Tujuan

- Mengimplementasikan segmentasi VLAN di Cabang Jabar dan Jatim menggunakan managed switch MikroTik CHR dengan Bridge VLAN Filtering.
- Mengonfigurasi Inter-VLAN Routing (Router-on-a-Stick) agar komunikasi antar VLAN dapat terjadi melalui router.
- Memigrasi protokol routing ke OSPF untuk mendapatkan kemampuan routing dinamis, self-healing, dan skalabilitas yang lebih baik.
- Merevisi topologi menjadi partial mesh dengan menambahkan jalur backup DC ↔ CAB1 dan DC ↔ CAB2 untuk menghilangkan single point of failure pada HQ-Dika.
- Mengonfigurasi OSPF cost manual pada jalur backup agar HQ-Dika tetap menjadi jalur utama (primary path) saat kondisi normal.
- Memverifikasi failover OSPF otomatis melalui pengujian traceroute dan ping saat HQ down.

---

## BAB 2. LANDASAN TEORI

### 2.1 VLAN (Virtual Local Area Network)

VLAN adalah teknologi yang memungkinkan pemisahan jaringan secara logis pada perangkat switch fisik yang sama. Dengan VLAN, perangkat yang terhubung ke switch yang sama dapat dikelompokkan ke dalam segmen jaringan berbeda tanpa memerlukan perangkat fisik terpisah. Setiap VLAN memiliki domain broadcast tersendiri sehingga traffic dari satu VLAN tidak dapat langsung mencapai VLAN lain tanpa melewati router. Pada proyek ini, VLAN 10 digunakan untuk traffic karyawan staf dan VLAN 20 untuk traffic tamu (guest) di setiap cabang.

### 2.2 Bridge VLAN Filtering

MikroTik RouterOS mengimplementasikan fungsionalitas managed switch menggunakan fitur Bridge dengan opsi vlan-filtering=yes. Ketika VLAN filtering diaktifkan, bridge memproses tag IEEE 802.1Q pada setiap frame yang melintas. Setiap bridge port dikonfigurasi dengan PVID (Port VLAN ID) yang menentukan VLAN yang akan di-assign pada frame untagged. Port trunk dikonfigurasi untuk meneruskan frame bertag dari beberapa VLAN secara bersamaan menggunakan tagged interface.

### 2.3 Inter-VLAN Routing dan Router-on-a-Stick

Inter-VLAN Routing adalah proses mengarahkan traffic antar VLAN yang berbeda melalui router. Tanpa router, perangkat di VLAN 10 tidak dapat berkomunikasi dengan perangkat di VLAN 20.

Router-on-a-Stick (RoaS) adalah teknik Inter-VLAN Routing yang menggunakan satu interface fisik router dengan beberapa sub-interface logical. Setiap sub-interface dikonfigurasi untuk menangani satu VLAN tertentu dengan encapsulasi 802.1Q. Interface fisik yang berfungsi sebagai trunk tidak diberi IP address langsung — IP berada di sub-interface, masing-masing sebagai gateway untuk VLAN yang bersangkutan.

### 2.4 OSPF (Open Shortest Path First)

OSPF adalah protokol routing dinamis berbasis algoritma Link-State yang dikembangkan oleh IETF. Setiap router OSPF membangun peta lengkap topologi jaringan menggunakan mekanisme pertukaran LSA (Link State Advertisement), kemudian menghitung jalur terpendek secara mandiri menggunakan algoritma Dijkstra (SPF).

OSPF menggunakan Hello packet untuk memastikan neighbor masih hidup. Pada MikroTik RouterOS v7, Hello interval default adalah 10 detik dan Dead interval 40 detik. Ketika sebuah router tidak menerima Hello packet dari neighbor selama 40 detik, router tersebut dinyatakan down dan OSPF melakukan recalculate SPF untuk menemukan jalur alternatif secara otomatis.

### 2.5 OSPF Cost dan Pemilihan Jalur

OSPF memilih jalur berdasarkan total cost terendah dari sumber menuju tujuan. Pada MikroTik RouterOS, cost dihitung otomatis berdasarkan bandwidth interface. Namun cost juga dapat dikonfigurasi secara manual untuk mengontrol preferensi jalur.

Dalam implementasi revisi topologi ini, cost manual dinaikkan pada interface backup (ether3) di CAB1-Galih dan CAB2-Marist menjadi 100 agar jalur via HQ-Dika tetap dipilih sebagai primary path saat kondisi normal. Ketika HQ-Dika down, OSPF secara otomatis berpindah ke jalur backup dengan cost lebih tinggi tersebut.

### 2.6 Partial Mesh Topology dan Fault Tolerance

Partial mesh topology adalah desain jaringan di mana sebagian namun tidak semua node saling terhubung langsung. Berbeda dengan topologi hub-and-spoke (star) yang seluruh komunikasinya melewati satu titik pusat, partial mesh menyediakan jalur alternatif sehingga kegagalan satu node tidak memutus seluruh komunikasi.

Dalam konteks jaringan ini, penambahan link langsung DC ↔ CAB1 dan DC ↔ CAB2 mengubah topologi dari pure hub-and-spoke menjadi partial mesh/hybrid. Hasilnya, jaringan bersifat fault-tolerant terhadap kegagalan HQ-Dika.

### 2.7 Out-of-Band Management Network

Management network adalah jaringan terpisah yang digunakan khusus untuk keperluan administrasi perangkat jaringan. Pada topologi ini, Cloud-Management terhubung ke Router HQ-Dika melalui jalur out-of-band yang terpisah dari jalur routing utama. Jalur ini memungkinkan akses Winbox ke router untuk keperluan monitoring dan konfigurasi tanpa mengganggu alur komunikasi data antar jaringan. Jalur Cloud-Management tidak terlibat dalam proses routing OSPF maupun VLAN.

---

## BAB 3. TOPOLOGI JARINGAN

### 3.1 Gambaran Umum

Topologi jaringan Modul 3 merupakan pengembangan dari topologi ATS yang telah direvisi berdasarkan evaluasi dosen. Evaluasi tersebut menekankan bahwa apabila Router HQ-Dika mati, cabang harus tetap dapat mengakses Data Center (DC). Oleh karena itu, topologi mengalami dua tahap evolusi.

Pada tahap pertama (sebelum revisi), topologi berbentuk hub-and-spoke murni: HQ-Dika sebagai hub, DC, CAB1-Galih, dan CAB2-Marist sebagai spoke. Semua komunikasi cabang menuju DC harus melewati HQ-Dika. Kondisi ini menjadikan HQ-Dika sebagai single point of failure — apabila HQ down, tidak ada jalur fisik alternatif yang dapat digunakan OSPF untuk menghitung ulang rute, sehingga traffic dari cabang ke DC terputus total.

Pada tahap kedua (topologi final revisi), ditambahkan dua link langsung: DC-Dicky-Rista ↔ CAB1-Galih (subnet 10.10.10.12/30) dan DC-Dicky-Rista ↔ CAB2-Marist (subnet 10.10.10.16/30). Penambahan ini mengubah topologi menjadi partial mesh / hybrid topology. HQ-Dika tetap berfungsi sebagai jalur utama (primary path) melalui konfigurasi OSPF cost manual, sementara link DC langsung berfungsi sebagai jalur backup yang diaktifkan secara otomatis oleh OSPF ketika HQ-Dika down.

**Gambar 3.1. Topologi Jaringan Final PT Nusantara Retail Digital (VLAN + OSPF + Partial Mesh Backup Path)**

> 🖼️ **DESKRIPSI GAMBAR 3.1 (untuk AI/pembaca tanpa akses gambar):**
>
> **Jenis gambar:** Diagram topologi jaringan logis bergaya GNS3, berjudul "TOPOLOGI JARINGAN PT NUSANTARA" dengan subjudul "Modul 3 — Modernisasi Infrastruktur: VLAN + OSPF Dynamic Routing" dan keterangan kecil "Desain Manajemen Jaringan | GNS3 Simulation | 2026".
>
> **Struktur dan hubungan antar perangkat (dari atas ke bawah):**
> 1. **Kotak hijau "MANAGEMENT NETWORK"** di bagian paling atas berisi ikon cloud bertuliskan "Cloud-Management", dengan catatan teks: "Winbox Access", "Backup Retrieval (.rsc)", dan "(No Internet Access)". Kotak ini terhubung dengan satu garis vertikal lurus turun ke router HQ-Dika — ini adalah jalur out-of-band management yang terpisah dari jalur data/routing OSPF (sesuai BAB 2.7).
> 2. **Kotak biru "CORE NETWORK (HQ)"** berisi satu router bernama **HQ-Dika** dengan label teks: `OSPF Router-ID: 1.1.1.1`, `Area: 0.0.0.0 (Backbone)`, `Interfaces: ether1, ether2, ether3`. Dari router HQ-Dika terdapat tiga garis yang menyebar ke bawah, masing-masing diberi label subnet backbone: **"OSPF Area 0 | 10.10.10.0/30"** (ke arah Data Center), **"OSPF Area 0 | 10.10.10.4/30"** (ke arah Branch Jabar/CAB1), dan **"OSPF Area 0 | 10.10.10.8/30"** (ke arah Branch Jatim/CAB2). Ketiga garis ini merepresentasikan jalur primer (hub-and-spoke) yang sudah ada sejak topologi ATS.
> 3. **Tiga kotak berwarna berdampingan di baris bawah**, masing-masing merepresentasikan satu site/lokasi:
>    - **Kotak merah muda "BRANCH JABAR"** (paling kiri): berisi router **CAB1-Galih** (`OSPF Router-ID: 3.3.3.3`, `Area: 0.0.0.0 (Backbone)`, `Interfaces: ether1, vlan10-staff, vlan20-guest`). Router ini terhubung ke bawah melalui label **"TRUNK LINK (IEEE 802.1Q)"** menuju switch **SW-Jabar**. Dari SW-Jabar, dua garis turun ke dua perangkat klien: **pc1.cab1** (ikon VPCS, berlabel "VLAN 10 - STAFF, eth 2 - 5", dengan rentang IP "192.168.10.2 – 62") di sisi kiri, dan **pc2.cab1** (ikon laptop/VM, berlabel "VLAN 20 - GUEST, eth 6 - 8", dengan rentang IP "192.168.10.66 – 126") di sisi kanan.
>    - **Kotak ungu "DATA CENTER (DC)"** (tengah): berisi router **DC-Dicky-Rista** (`OSPF Router-ID: 2.2.2.2`, `Area: 0.0.0.0 (Backbone)`, `Interfaces: ether1, ether2`). Di bawahnya tertulis label subnet **"172.16.10.0/26"** menuju switch **SW-DC**, yang kemudian bercabang ke dua server: **backup.dc** (ikon server dengan titik merah) dan **server.dc (DNS+WEB)** (ikon server biru).
>    - **Kotak kuning "BRANCH JATIM"** (paling kanan): berisi router **CAB2-Marist** (`OSPF Router-ID: 4.4.4.4`, `Area: 0.0.0.0 (Backbone)`, `Interfaces: ether1, vlan10-staff, vlan20-guest`), terhubung via **"TRUNK LINK (IEEE 802.1Q)"** ke switch **SW-Jatim**, yang bercabang ke **pc1.cab2** (VLAN 10 - STAFF, eth 2-5, IP 192.168.20.2–62) dan **pc2.cab2** (VLAN 20 - GUEST, eth 6-8, IP 192.168.20.66–126).
> 4. **Link backup partial-mesh (bagian terpenting dari revisi topologi):** Pada gambar terlihat dua garis horizontal tambahan yang menghubungkan langsung **CAB1-Galih ↔ DC-Dicky-Rista** dan **DC-Dicky-Rista ↔ CAB2-Marist**, masing-masing diberi label **"OSPF Area 0 | 10.10.10.12/30"** (CAB1↔DC) dan **"OSPF Area 0 | 10.10.10.16/30"** (DC↔CAB2). Garis-garis horizontal inilah yang merepresentasikan jalur backup baru hasil revisi topologi, yang membuat jaringan menjadi partial mesh — DC kini memiliki koneksi langsung ke kedua cabang selain melalui HQ.
>
> **Tujuan gambar:** Memvisualisasikan topologi jaringan final pasca-revisi, menunjukkan bahwa selain jalur utama melalui HQ-Dika (hub-and-spoke), kini tersedia dua jalur backup langsung dari Data Center ke masing-masing cabang, sehingga HQ-Dika tidak lagi menjadi single point of failure.
>
> **Informasi penting yang terkandung:** Seluruh OSPF Router-ID per perangkat, seluruh subnet backbone /30 beserta perangkat yang dihubungkannya, pembagian VLAN 10 (Staf) dan VLAN 20 (Guest) beserta rentang IP-nya di tiap cabang, posisi trunk link IEEE 802.1Q antara router cabang dan switch-nya, serta posisi jalur out-of-band management yang terpisah dari jalur data.

### 3.2 Perbandingan Topologi Lama dan Topologi Revisi

| **Aspek** | **Topologi Lama (Hub-and-Spoke)** | **Topologi Revisi (Partial Mesh)** |
| --- | --- | --- |
| Koneksi DC ke Cabang | Hanya via HQ-Dika | Via HQ-Dika (primary) + link langsung DC↔CAB1 dan DC↔CAB2 (backup) |
| Single Point of Failure | HQ-Dika adalah SPOF | HQ-Dika bukan SPOF untuk akses DC |
| Jalur saat HQ down | Tidak ada — traffic terputus total | OSPF failover otomatis ke jalur DC langsung |
| OSPF Neighbor DC | 1 neighbor (HQ-Dika) | 3 neighbor (HQ-Dika, CAB1-Galih, CAB2-Marist) |
| OSPF Neighbor CAB1/CAB2 | 1 neighbor (HQ-Dika) | 2 neighbor (HQ-Dika, DC-Dicky-Rista) |
| Fault Tolerance | Tidak ada | Fault-tolerant terhadap kegagalan HQ |

*Tabel 3.2. Perbandingan Topologi Lama dan Topologi Revisi*

### 3.3 Komponen Topologi

| **Komponen** | **Device Name** | **Fungsi** | **Status** |
| --- | --- | --- | --- |
| Router HQ | HQ-Dika | Core network — hub seluruh komunikasi, OSPF RID 1.1.1.1 | Dipertahankan + OSPF |
| Router DC | DC-Dicky-Rista | Mengelola LAN DC 172.16.10.0/26, OSPF RID 2.2.2.2 | Dipertahankan + OSPF + 2 interface baru |
| Router Cab1 | CAB1-Galih | Mengelola VLAN Cabang Jabar, Inter-VLAN, OSPF RID 3.3.3.3 | Dimodifikasi + VLAN + OSPF + backup path |
| Router Cab2 | CAB2-Marist | Mengelola VLAN Cabang Jatim, Inter-VLAN, OSPF RID 4.4.4.4 | Dimodifikasi + VLAN + OSPF + backup path |
| Switch Jabar | SW-Jabar | Managed switch Bridge VLAN Filtering, Cabang Jawa Barat | BARU — MikroTik CHR |
| Switch Jatim | SW-Jatim | Managed switch Bridge VLAN Filtering, Cabang Jawa Timur | BARU — MikroTik CHR |
| Server DC | server.dc | Layanan DNS (Bind9) + Web Server (Apache2) | Dipertahankan |
| Backup DC | backup.dc | Server backup di Data Center | Dipertahankan |
| Management | Cloud-Management | Akses Winbox out-of-band ke HQ-Dika | Dipertahankan |

*Tabel 3.3. Komponen Topologi Jaringan*

### 3.4 Konfigurasi OSPF per Router (Topologi Final)

| **Router** | **OSPF Router-ID** | **Area** | **Interfaces Diiklankan** |
| --- | --- | --- | --- |
| HQ-Dika | 1.1.1.1 | 0.0.0.0 (Backbone) | ether1, ether2, ether3 |
| DC-Dicky-Rista | 2.2.2.2 | 0.0.0.0 (Backbone) | ether1, ether2, ether3, ether4 |
| CAB1-Galih | 3.3.3.3 | 0.0.0.0 (Backbone) | ether1, ether3, vlan10-staff, vlan20-guest |
| CAB2-Marist | 4.4.4.4 | 0.0.0.0 (Backbone) | ether1, ether3, vlan10-staff, vlan20-guest |

*Tabel 3.4. Konfigurasi OSPF per Router (Topologi Final)*

### 3.5 Konfigurasi Port SW-Jabar dan SW-Jatim

| **Switch** | **Interface** | **Mode** | **PVID / VLAN** | **Terhubung ke** |
| --- | --- | --- | --- | --- |
| SW-Jabar | ether1 | Trunk | Tagged VLAN 10 & 20 | CAB1-Galih (ether2) — Trunk Link IEEE 802.1Q |
| SW-Jabar | ether2–5 | Access VLAN 10 | PVID 10 | VPCS/client Staf (pc1.cab1 di ether2) |
| SW-Jabar | ether6–8 | Access VLAN 20 | PVID 20 | VPCS/client Guest (pc2.cab1 di ether6) |
| SW-Jatim | ether1 | Trunk | Tagged VLAN 10 & 20 | CAB2-Marist (ether2) — Trunk Link IEEE 802.1Q |
| SW-Jatim | ether2–5 | Access VLAN 10 | PVID 10 | VPCS/client Staf (pc1.cab2 di ether2) |
| SW-Jatim | ether6–8 | Access VLAN 20 | PVID 20 | VPCS/client Guest (pc2.cab2 di ether6) |

*Tabel 3.5. Konfigurasi Port Switch-Jabar dan Switch-Jatim*

### 3.6 Perubahan dari Topologi ATS

Perbedaan utama topologi Modul 3 (revisi final) dibandingkan topologi ATS:

- Dua managed switch baru (SW-Jabar dan SW-Jatim) berbasis MikroTik CHR ditambahkan di bawah Router CAB1-Galih dan CAB2-Marist.
- LAN flat di setiap cabang digantikan dua VLAN terpisah — VLAN 10 (Staf, port ether2–ether5) dan VLAN 20 (Guest, port ether6–ether8).
- Interface ether2 Router CAB1-Galih dan CAB2-Marist tidak lagi memiliki IP address langsung; IP berpindah ke sub-interface vlan10-staff dan vlan20-guest (Router-on-a-Stick).
- Koneksi Router Cabang ↔ Switch menggunakan Trunk Link IEEE 802.1Q yang membawa VLAN 10 dan VLAN 20 secara bersamaan.
- Static routing di semua router dinonaktifkan dan digantikan oleh OSPF v7 pada area backbone 0.0.0.0.
- Ditambahkan dua link backup langsung: DC-Dicky-Rista ↔ CAB1-Galih (10.10.10.12/30) dan DC-Dicky-Rista ↔ CAB2-Marist (10.10.10.16/30), mengubah topologi dari hub-and-spoke menjadi partial mesh.
- OSPF cost manual dikonfigurasi pada interface ether3 di CAB1-Galih dan CAB2-Marist (cost=100) agar HQ-Dika tetap menjadi primary path saat kondisi normal.

---

## BAB 4. PERENCANAAN VLAN DAN IP ADDRESS

### 4.1 Dasar Penentuan Subnet

Perencanaan IP Address pada Modul 3 melanjutkan konvensi ATS. Prefix /26 dipertahankan untuk segmen LAN (digit terakhir NIM ketua 0 = genap = /26). Setiap cabang memiliki dua VLAN dengan alokasi subnet /26 masing-masing. Jaringan backbone antar router tetap menggunakan prefix /30. Subnet backbone baru untuk link backup dilanjutkan dari 10.10.10.12/30.

### 4.2 IP Address Backbone Antar Router

| **Link** | **Network** | **IP HQ/DC** | **IP Router Lawan** | **Broadcast** | **Keterangan** |
| --- | --- | --- | --- | --- | --- |
| HQ ↔ DC | 10.10.10.0/30 | 10.10.10.1 (HQ) | 10.10.10.2 (DC-Dicky-Rista) | 10.10.10.3 | Primary link — tidak berubah |
| HQ ↔ Cab1 | 10.10.10.4/30 | 10.10.10.5 (HQ) | 10.10.10.6 (CAB1-Galih) | 10.10.10.7 | Primary link — tidak berubah |
| HQ ↔ Cab2 | 10.10.10.8/30 | 10.10.10.9 (HQ) | 10.10.10.10 (CAB2-Marist) | 10.10.10.11 | Primary link — tidak berubah |
| DC ↔ CAB1 | 10.10.10.12/30 | 10.10.10.13 (DC ether3) | 10.10.10.14 (CAB1 ether3) | 10.10.10.15 | BARU — Backup path DC-Cab1 |
| DC ↔ CAB2 | 10.10.10.16/30 | 10.10.10.17 (DC ether4) | 10.10.10.18 (CAB2 ether3) | 10.10.10.19 | BARU — Backup path DC-Cab2 |

*Tabel 4.2. IP Address Backbone (/30) — Termasuk Subnet Backup Baru*

### 4.3 VLAN dan IP Address — Cabang Jawa Barat

| **VLAN ID** | **Nama VLAN** | **Network** | **Gateway (CAB1-Galih)** | **Range Host** | **Broadcast** |
| --- | --- | --- | --- | --- | --- |
| 10 | Staf-Jabar | 192.168.10.0/26 | 192.168.10.1 | 192.168.10.2 – .62 | 192.168.10.63 |
| 20 | Guest-Jabar | 192.168.10.64/26 | 192.168.10.65 | 192.168.10.66 – .126 | 192.168.10.127 |

*Tabel 4.3. VLAN dan IP Address Cabang Jawa Barat*

### 4.4 VLAN dan IP Address — Cabang Jawa Timur

| **VLAN ID** | **Nama VLAN** | **Network** | **Gateway (CAB2-Marist)** | **Range Host** | **Broadcast** |
| --- | --- | --- | --- | --- | --- |
| 10 | Staf-Jatim | 192.168.20.0/26 | 192.168.20.1 | 192.168.20.2 – .62 | 192.168.20.63 |
| 20 | Guest-Jatim | 192.168.20.64/26 | 192.168.20.65 | 192.168.20.66 – .126 | 192.168.20.127 |

*Tabel 4.4. VLAN dan IP Address Cabang Jawa Timur*

### 4.5 IP Address Seluruh Device (Termasuk Interface Backup)

| **Device** | **Interface** | **IP Address** | **Network** | **Keterangan** |
| --- | --- | --- | --- | --- |
| HQ-Dika | ether1 | 10.10.10.1/30 | 10.10.10.0/30 | Link ke DC-Dicky-Rista |
| HQ-Dika | ether2 | 10.10.10.5/30 | 10.10.10.4/30 | Link ke CAB1-Galih |
| HQ-Dika | ether3 | 10.10.10.9/30 | 10.10.10.8/30 | Link ke CAB2-Marist |
| HQ-Dika | ether4 | 192.168.56.2/24 | 192.168.56.0/24 | Management (Cloud) |
| DC-Dicky-Rista | ether1 | 10.10.10.2/30 | 10.10.10.0/30 | Link ke HQ-Dika |
| DC-Dicky-Rista | ether2 | 172.16.10.1/26 | 172.16.10.0/26 | Gateway LAN Data Center |
| DC-Dicky-Rista | ether3 | 10.10.10.13/30 | 10.10.10.12/30 | BARU — Link backup ke CAB1-Galih |
| DC-Dicky-Rista | ether4 | 10.10.10.17/30 | 10.10.10.16/30 | BARU — Link backup ke CAB2-Marist |
| server.dc | ens3 | 172.16.10.3/26 | 172.16.10.0/26 | DNS + Web Server |
| backup.dc | eth0 | 172.16.10.2/26 | 172.16.10.0/26 | Backup Server |
| CAB1-Galih | ether1 | 10.10.10.6/30 | 10.10.10.4/30 | Link ke HQ-Dika (primary) |
| CAB1-Galih | ether3 | 10.10.10.14/30 | 10.10.10.12/30 | BARU — Link backup ke DC-Dicky-Rista |
| CAB1-Galih | vlan10-staff | 192.168.10.1/26 | 192.168.10.0/26 | Gateway VLAN 10 Staf Jabar |
| CAB1-Galih | vlan20-guest | 192.168.10.65/26 | 192.168.10.64/26 | Gateway VLAN 20 Guest Jabar |
| CAB2-Marist | ether1 | 10.10.10.10/30 | 10.10.10.8/30 | Link ke HQ-Dika (primary) |
| CAB2-Marist | ether3 | 10.10.10.18/30 | 10.10.10.16/30 | BARU — Link backup ke DC-Dicky-Rista |
| CAB2-Marist | vlan10-staff | 192.168.20.1/26 | 192.168.20.0/26 | Gateway VLAN 10 Staf Jatim |
| CAB2-Marist | vlan20-guest | 192.168.20.65/26 | 192.168.20.64/26 | Gateway VLAN 20 Guest Jatim |
| pc1.cab1 | eth0 | 192.168.10.2/26 | 192.168.10.0/26 | VPCS Staf Jabar — VLAN 10 |
| pc2.cab1 | LAN | 192.168.10.66/26 | 192.168.10.64/26 | Win7 Guest Jabar — VLAN 20 |
| pc1.cab2 | eth0 | 192.168.20.2/26 | 192.168.20.0/26 | VPCS Staf Jatim — VLAN 10 |
| pc2.cab2 | eth0 | 192.168.20.66/26 | 192.168.20.64/26 | VPCS Guest Jatim — VLAN 20 |

*Tabel 4.5. IP Address Seluruh Perangkat (Termasuk Interface Backup Baru)*

---

## BAB 5. KONFIGURASI JARINGAN

Konfigurasi dilakukan secara bertahap: (1) managed switch VLAN, (2) Inter-VLAN Routing pada router cabang, (3) konfigurasi client, (4) nonaktifkan static route, (5) konfigurasi OSPF seluruh router, (6) tambah interface dan IP backup pada DC, CAB1, CAB2, (7) konfigurasi OSPF cost pada interface backup.

### 5.1 Konfigurasi SW-Jabar (Bridge VLAN Filtering)

SW-Jabar adalah MikroTik CHR baru yang difungsikan sebagai managed switch. VLAN 10 dialokasikan untuk port ether2–ether5 (Staf) dan VLAN 20 untuk ether6–ether8 (Guest). Port ether1 adalah trunk ke Router CAB1-Galih.

```
# ─── SW-Jabar: Bridge VLAN Filtering ───

# 1. Buat bridge dengan VLAN filtering aktif
/interface bridge add name=br-vlan vlan-filtering=yes

# 2. Daftarkan interface ke bridge
#    ether1    = trunk ke CAB1-Galih
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

# 3. Konfigurasi tagged trunk port (ether1 membawa VLAN 10 dan 20)
/interface bridge vlan add bridge=br-vlan tagged=ether1 vlan-ids=10
/interface bridge vlan add bridge=br-vlan tagged=ether1 vlan-ids=20

# 4. System identity
/system identity set name=SW-Jabar
```

Konfigurasi SW-Jatim identik dengan SW-Jabar. Perbedaan hanya pada identity (`/system identity set name=SW-Jatim`).

**Gambar 5.1.1. interface bridge vlan print pada SW-Jabar — menampilkan VLAN 10 dan VLAN 20 dengan tagged=ether1**

> 🖼️ **DESKRIPSI GAMBAR 5.1.1:**
>
> **Apa yang terlihat:** Tangkapan layar terminal MikroTik (prompt `[admin@Switch-Jabar] >`) menjalankan perintah `/interface bridge vlan print`. Output menampilkan flag `D - DYNAMIC` dan kolom: `#`, `BRIDGE`, `VLAN-IDS`, `CURRENT-TAGGED`, `CURRENT-UNTAGGED`.
> - Baris 0: `br-vlan`, VLAN-IDS `10`, CURRENT-TAGGED `ether1`
> - Baris 1: `br-vlan`, VLAN-IDS `20`, CURRENT-TAGGED `ether1`
> - Baris 2 (D, ditandai komentar `;;; added by pvid`): `br-vlan`, VLAN-IDS `1`, CURRENT-UNTAGGED `br-vlan`, `ether1`
> - Baris 3 (D, `;;; added by pvid`): `br-vlan`, VLAN-IDS `10`, CURRENT-UNTAGGED `ether2`
> - Baris 4 (D, `;;; added by pvid`): `br-vlan`, VLAN-IDS `20`, CURRENT-UNTAGGED `ether6`
> **Tujuan gambar:** Memverifikasi bahwa bridge `br-vlan` pada SW-Jabar telah benar mendaftarkan VLAN 10 dan VLAN 20 sebagai tagged pada port trunk `ether1`, serta bahwa port access (`ether2`, `ether6`, dst.) ter-assign secara otomatis (dynamic, via PVID) ke VLAN yang sesuai.
> **Hasil konfigurasi yang ditunjukkan:** Bridge VLAN Filtering pada SW-Jabar berhasil berjalan; trunk port ether1 membawa kedua VLAN (10 dan 20) secara tagged, sesuai rencana pada Tabel 3.5.

**Gambar 5.1.2. interface bridge port print pada SW-Jabar — menampilkan pvid masing-masing port**

> 🖼️ **DESKRIPSI GAMBAR 5.1.2:**
>
> **Apa yang terlihat:** Tangkapan layar terminal MikroTik menjalankan `/interface bridge port print`. Flag legend: `I - INACTIVE`. Kolom: `#`, `INTERFACE`, `BRIDGE`, `HW`, `HORIZON`, `TRUSTED`, `TRUSTED-RA`, `FAST-LEAVE`, `BPDU-GUARD`, `EDGE`, `POINT-TO-POINT`, `PVID`, `FRAME-TYPES`. Seluruh 8 baris (ether1 sampai ether8) terdaftar pada bridge `br-vlan`, dengan nilai `HW=yes`, sebagian besar kolom flag berisi `no`/`auto`, dan kolom `PVID` bernilai:
> - `ether1`: PVID `1`, FRAME-TYPES `admit-all`
> - `ether2, ether3, ether4, ether5`: PVID `10`, FRAME-TYPES `admit-all`
> - `ether6, ether7, ether8`: PVID `20`, FRAME-TYPES `admit-all`
> **Tujuan gambar:** Memverifikasi PVID (Port VLAN ID) tiap port fisik pada bridge SW-Jabar.
> **Hasil konfigurasi yang ditunjukkan:** Port ether2–ether5 berhasil di-PVID 10 (VLAN Staf) dan ether6–ether8 di-PVID 20 (VLAN Guest), sedangkan ether1 tetap di PVID default (1) karena berfungsi sebagai trunk tagged, bukan access port.

### 5.2 Konfigurasi Inter-VLAN Routing — CAB1-Galih

IP address lama di ether2 (192.168.10.1/26) dihapus dan digantikan dua sub-interface VLAN. Interface fisik ether2 menjadi trunk port tanpa IP langsung — inilah implementasi Router-on-a-Stick.

```
# ─── CAB1-Galih: Inter-VLAN Routing (Router-on-a-Stick) ───

# 1. Hapus IP lama di ether2
/ip address remove [find interface=ether2]

# 2. Buat sub-interface VLAN pada ether2
/interface vlan add interface=ether2 name=vlan10-staff vlan-id=10
/interface vlan add interface=ether2 name=vlan20-guest vlan-id=20

# 3. Berikan IP gateway masing-masing VLAN
/ip address add address=192.168.10.1/26  interface=vlan10-staff
/ip address add address=192.168.10.65/26 interface=vlan20-guest

# 4. Verifikasi
/ip address print
/interface vlan print
```

**Gambar 5.2.1. interface vlan print pada CAB1-Galih — menampilkan vlan10-staff (VLAN ID 10) dan vlan20-guest (VLAN ID 20)**

> ⚠️ **CATATAN KONVERSI — GAMBAR TIDAK TERSEDIA:** Pada dokumen Word asli, slot gambar untuk **Gambar 5.2.1** ditemukan **kosong/tidak memiliki gambar yang ter-embed** (placeholder paragraf untuk gambar ini tidak berisi objek gambar apa pun, berbeda dari seluruh gambar lain pada laporan yang berhasil ter-embed). Berdasarkan caption dan konteks perintah `/interface vlan print` di atasnya, gambar ini seharusnya menampilkan output yang membuktikan dua sub-interface VLAN berhasil dibuat pada ether2 Router CAB1-Galih: `vlan10-staff` dengan VLAN ID 10, dan `vlan20-guest` dengan VLAN ID 20, keduanya berinduk pada interface fisik `ether2`. Informasi yang sama (dengan tambahan kolom MTU dan status ARP) dapat dilihat secara tervalidasi pada **Gambar 6.5** (bagian 6.4) yang menampilkan output identik di tahap pengujian.

**Gambar 5.2.2. ip address print pada CAB1-Galih — menampilkan 192.168.10.1/26 (vlan10-staff) dan 192.168.10.65/26 (vlan20-guest)**

> 🖼️ **DESKRIPSI GAMBAR 5.2.2:**
>
> **Apa yang terlihat:** Tangkapan layar terminal MikroTik (prompt `[admin-cab1@Cab1-Gallih] >`) menjalankan `/ip address print`. Kolom: `#`, `ADDRESS`, `NETWORK`, `INTERFACE`, `VRF`. Baris data:
> - `0`: `10.10.10.6/30`, network `10.10.10.4`, interface `ether1`, VRF `main` — komentar `;;; Link to HQ`
> - `1`: `192.168.10.1/26`, network `192.168.10.0`, interface `vlan10-staff`, VRF `main`
> - `2`: `192.168.10.65/26`, network `192.168.10.64`, interface `vlan20-guest`, VRF `main`
> - komentar `;;; Link to DC-Dicky-Rista (backup)`
> - `3`: `10.10.10.14/30`, network `10.10.10.12`, interface `ether3`, VRF `main`
> **Tujuan gambar:** Memverifikasi seluruh IP address yang aktif pada Router CAB1-Galih setelah konfigurasi VLAN dan link backup selesai — termasuk gateway VLAN 10 (192.168.10.1/26) dan VLAN 20 (192.168.10.65/26), link primer ke HQ (ether1), serta link backup ke DC (ether3, dikonfigurasi pada bagian 5.11).
> **Catatan:** Gambar ini diambil pada tahap lanjut (setelah interface backup ether3 juga sudah dikonfigurasi pada bagian 5.11), sehingga turut menampilkan baris `10.10.10.14/30` pada ether3 yang belum dibahas pada bagian 5.2 ini, namun tetap konsisten dan relevan sebagai bukti konfigurasi akhir Router CAB1-Galih.

### 5.3 Konfigurasi Inter-VLAN Routing — CAB2-Marist

```
# ─── CAB2-Marist: Inter-VLAN Routing (Router-on-a-Stick) ───

/ip address remove [find interface=ether2]
/interface vlan add interface=ether2 name=vlan10-staff vlan-id=10
/interface vlan add interface=ether2 name=vlan20-guest vlan-id=20
/ip address add address=192.168.20.1/26  interface=vlan10-staff
/ip address add address=192.168.20.65/26 interface=vlan20-guest
```

### 5.4 Konfigurasi Client VLAN

```
# pc1.cab1 — VPCS Staf Jabar (VLAN 10, ether2 SW-Jabar)
ip 192.168.10.2/26 192.168.10.1
ip dns 172.16.10.3

# pc2.cab1 — Win7 Guest Jabar (VLAN 20, ether6 SW-Jabar)
# Set via Control Panel: IP 192.168.10.66/26, GW 192.168.10.65, DNS 172.16.10.3

# pc1.cab2 — VPCS Staf Jatim (VLAN 10, ether2 SW-Jatim)
ip 192.168.20.2/26 192.168.20.1
ip dns 172.16.10.3

# pc2.cab2 — VPCS Guest Jatim (VLAN 20, ether6 SW-Jatim)
ip 192.168.20.66/26 192.168.20.65
ip dns 172.16.10.3
```

### 5.5 Nonaktifkan Static Route — Semua Router

Sebelum mengaktifkan OSPF, seluruh static route dinonaktifkan (disabled) agar tidak terjadi konflik administrative distance. Perintah berikut dijalankan di HQ-Dika, DC-Dicky-Rista, CAB1-Galih, dan CAB2-Marist:

```
# Nonaktifkan semua static route — JANGAN dihapus
/ip route set [find static=yes] disabled=yes

# Verifikasi — flag S harus hilang dari routing table
/ip route print
```

### 5.6 Konfigurasi OSPF — HQ-Dika

```
# ─── HQ-Dika: OSPF v7, Router-ID 1.1.1.1 ───

/routing ospf instance add name=ospf-nusantara router-id=1.1.1.1
/routing ospf area add instance=ospf-nusantara name=area-backbone area-id=0.0.0.0

# Iklankan ketiga interface backbone
/routing ospf interface-template add area=area-backbone interfaces=ether1
/routing ospf interface-template add area=area-backbone interfaces=ether2
/routing ospf interface-template add area=area-backbone interfaces=ether3
```

### 5.7 Konfigurasi OSPF — DC-Dicky-Rista

```
# ─── DC-Dicky-Rista: OSPF v7, Router-ID 2.2.2.2 ───

/routing ospf instance add name=ospf-nusantara router-id=2.2.2.2
/routing ospf area add instance=ospf-nusantara name=area-backbone area-id=0.0.0.0
/routing ospf interface-template add area=area-backbone interfaces=ether1
/routing ospf interface-template add area=area-backbone interfaces=ether2
```

### 5.8 Konfigurasi OSPF — CAB1-Galih

```
# ─── CAB1-Galih: OSPF v7, Router-ID 3.3.3.3 ───

/routing ospf instance add name=ospf-nusantara router-id=3.3.3.3
/routing ospf area add instance=ospf-nusantara name=area-backbone area-id=0.0.0.0

# Sertakan ether1 (link HQ) dan kedua sub-interface VLAN
/routing ospf interface-template add area=area-backbone interfaces=ether1
/routing ospf interface-template add area=area-backbone interfaces=vlan10-staff
/routing ospf interface-template add area=area-backbone interfaces=vlan20-guest
```

### 5.9 Konfigurasi OSPF — CAB2-Marist

```
# ─── CAB2-Marist: OSPF v7, Router-ID 4.4.4.4 ───

/routing ospf instance add name=ospf-nusantara router-id=4.4.4.4
/routing ospf area add instance=ospf-nusantara name=area-backbone area-id=0.0.0.0
/routing ospf interface-template add area=area-backbone interfaces=ether1
/routing ospf interface-template add area=area-backbone interfaces=vlan10-staff
/routing ospf interface-template add area=area-backbone interfaces=vlan20-guest
```

### 5.10 Konfigurasi Interface dan IP Backup — DC-Dicky-Rista

Setelah link fisik baru terpasang di GNS3 (DC ether3 ke CAB1 ether3, DC ether4 ke CAB2 ether3), konfigurasi berikut ditambahkan pada DC-Dicky-Rista:

```
# ─── DC-Dicky-Rista: Interface dan IP Backup ───

# Tambah IP di interface baru ke CAB1
/ip address add address=10.10.10.13/30 interface=ether3 comment="Link to CAB1-Galih (backup)"

# Tambah IP di interface baru ke CAB2
/ip address add address=10.10.10.17/30 interface=ether4 comment="Link to CAB2-Marist (backup)"

# Tambah interface baru ke OSPF instance
/routing ospf interface-template add area=area-backbone interfaces=ether3
/routing ospf interface-template add area=area-backbone interfaces=ether4

# Verifikasi IP sudah terpasang
/ip address print

# Verifikasi neighbor terbentuk (tunggu 30-60 detik)
/routing ospf neighbor print
```

**Gambar 5.5. ip address print pada DC-Dicky-Rista — menampilkan 10.10.10.13/30 (ether3) dan 10.10.10.17/30 (ether4) sebagai interface backup baru**

> 🖼️ **DESKRIPSI GAMBAR 5.5:**
>
> **Apa yang terlihat:** Tangkapan layar terminal MikroTik (prompt `[admin-dc@DC-Dicky] >`) menjalankan `/ip address print`. Kolom: `#`, `ADDRESS`, `NETWORK`, `INTERFACE`, `VRF`. Baris data:
> - komentar `;;; Link to HQ` → `0`: `10.10.10.2/30`, network `10.10.10.0`, interface `ether1`, VRF `main`
> - komentar `;;; LAN Server` → `1`: `172.16.10.1/26`, network `172.16.10.0`, interface `ether2`, VRF `main`
> - komentar `;;; Link to CAB1-Galih (backup)` → `2`: `10.10.10.13/30`, network `10.10.10.12`, interface `ether3`, VRF `main`
> - komentar `;;; Link to CAB2-Marist (backup)` → `3`: `10.10.10.17/30`, network `10.10.10.16`, interface `ether4`, VRF `main`
> **Tujuan gambar:** Membuktikan bahwa dua IP address backup baru (10.10.10.13/30 di ether3, 10.10.10.17/30 di ether4) telah berhasil ditambahkan pada Router DC-Dicky-Rista, melengkapi IP link ke HQ dan LAN Data Center yang sudah ada sebelumnya.
> **Hasil konfigurasi yang ditunjukkan:** DC-Dicky-Rista kini memiliki total 4 interface ber-IP: ether1 (ke HQ), ether2 (LAN DC), ether3 (backup ke CAB1), ether4 (backup ke CAB2) — sesuai rencana pada Tabel 4.2 dan Tabel 4.5.

### 5.11 Konfigurasi Interface dan IP Backup — CAB1-Galih

```
# ─── CAB1-Galih: Interface dan IP Backup ───

# Tambah IP di interface baru ke DC
/ip address add address=10.10.10.14/30 interface=ether3 comment="Link to DC-Dicky-Rista (backup)"

# Tambah interface baru ke OSPF instance
/routing ospf interface-template add area=area-backbone interfaces=ether3

# JANGAN ubah apapun yang berhubungan dengan ether2, vlan10-staff, vlan20-guest

# Verifikasi IP
/ip address print

# Verifikasi neighbor — harus muncul 2.2.2.2 dari DC sebagai neighbor baru
/routing ospf neighbor print
```

### 5.12 Konfigurasi Interface dan IP Backup — CAB2-Marist

```
# ─── CAB2-Marist: Interface dan IP Backup ───

# Tambah IP di interface baru ke DC
/ip address add address=10.10.10.18/30 interface=ether3 comment="Link to DC-Dicky-Rista (backup)"

# Tambah interface baru ke OSPF instance
/routing ospf interface-template add area=area-backbone interfaces=ether3

# JANGAN ubah apapun yang berhubungan dengan ether2, vlan10-staff, vlan20-guest

# Verifikasi IP
/ip address print

# Verifikasi neighbor — harus muncul 2.2.2.2 dari DC sebagai neighbor baru
/routing ospf neighbor print
```

### 5.13 Konfigurasi OSPF Cost pada Interface Backup

Setelah link backup terpasang, OSPF secara default memilih jalur DC langsung karena cost-nya lebih rendah dibandingkan jalur via HQ. Agar HQ-Dika tetap menjadi jalur utama (primary path), dilakukan konfigurasi cost manual pada interface ether3 di CAB1-Galih dan CAB2-Marist.

OSPF memilih jalur berdasarkan total accumulated cost terendah. Dengan menaikkan cost interface backup menjadi 100, jalur DC langsung menjadi lebih mahal dibandingkan jalur via HQ (yang menggunakan cost default sekitar 10 per hop), sehingga OSPF tetap memilih jalur via HQ sebagai primary. Ketika HQ-Dika down dan jalur via HQ tidak tersedia, OSPF otomatis berpindah menggunakan jalur backup DC langsung meskipun cost-nya lebih tinggi.

```
# ─── CAB1-Galih: Set OSPF Cost pada interface backup ───
/routing ospf interface-template set [find interfaces=ether3] cost=100

# ─── CAB2-Marist: Set OSPF Cost pada interface backup ───
/routing ospf interface-template set [find interfaces=ether3] cost=100

# Verifikasi cost sudah terpasang
/routing ospf interface-template print

# Verifikasi routing table — pastikan rute ke DC masih via HQ (next-hop 10.10.10.5)
/ip route print
```

**Gambar 5.6. routing ospf interface-template print pada CAB1-Galih — menampilkan ether3 dengan cost=100**

> 🖼️ **DESKRIPSI GAMBAR 5.6:**
>
> **Apa yang terlihat:** Tangkapan layar terminal MikroTik (prompt `[admin-cab1@Cab1-Gallih] >`) menjalankan `/routing ospf interface-template print`. Flag legend: `X - DISABLED, I - INACTIVE`. Empat entri ditampilkan, masing-masing dengan parameter `instance-id=0 type=broadcast retransmit-interval=5s transmit-delay=1s hello-interval=10s dead-interval=40s priority=128`:
> - `0`: `area=area-backbone interfaces=ether1` ... `cost=1`
> - `1`: `area=area-backbone interfaces=vlan10-staff` ... `cost=1`
> - `2`: `area=area-backbone interfaces=vlan20-guest` ... `cost=1`
> - `3`: `area=area-backbone interfaces=ether3` ... **`cost=100`**
> **Tujuan gambar:** Membuktikan bahwa cost OSPF manual sebesar 100 telah berhasil diterapkan secara spesifik hanya pada interface backup `ether3`, sementara interface lain (ether1, vlan10-staff, vlan20-guest) tetap menggunakan cost default 1.
> **Hasil konfigurasi yang ditunjukkan:** Hello-interval 10 detik dan dead-interval 40 detik (default RouterOS v7) berlaku pada seluruh interface OSPF, sesuai Landasan Teori 2.4–2.5. Cost 100 pada ether3 inilah yang membuat OSPF tetap memilih jalur via HQ-Dika sebagai primary path.

**Gambar 5.7. ip route print pada CAB1-Galih — menampilkan rute ke 172.16.10.0/26 via 10.10.10.5 (HQ) sebagai primary path**

> 🖼️ **DESKRIPSI GAMBAR 5.7:**
>
> **Apa yang terlihat:** Tangkapan layar terminal MikroTik menjalankan `/ip route print`. Flag legend: `D - DYNAMIC; X - DISABLED, I - INACTIVE, A - ACTIVE; c - CONNECT, s - STATIC, o - OSPF`. Kolom: `#`, `DST-ADDRESS`, `GATEWAY`, `ROUTING-TABLE`, `DISTANCE`. Baris data:
> - `;;; default via HQ` → `0`: flag `Xs` (disabled static), `0.0.0.0/0` via `10.10.10.5`
> - `DAo 10.10.10.0/30` via `10.10.10.5%ether1`, table `main`, distance `110`
> - `DAc 10.10.10.4/30` via `ether1`, table `main`, distance `0`
> - `DAo 10.10.10.8/30` via `10.10.10.5%ether1`, table `main`, distance `110`
> - `DAc 10.10.10.12/30` via `ether3`, table `main`, distance `0`
> - `DAo 10.10.10.16/30` via `10.10.10.5%ether1`, table `main`, distance `110`
> - **`DAo 172.16.10.0/26` via `10.10.10.5%ether1`, table `main`, distance `110`** ← rute menuju LAN Data Center
> - `DAc 192.168.10.0/26` via `vlan10-staff`, distance `0`
> - `DAc 192.168.10.64/26` via `vlan20-guest`, distance `0`
> - `DAo 192.168.20.0/26` via `10.10.10.5%ether1`, distance `110`
> - `DAo 192.168.20.64/26` via `10.10.10.5%ether1`, distance `110`
> **Tujuan gambar:** Membuktikan bahwa meskipun jalur backup DC langsung sudah aktif, OSPF tetap memilih rute ke LAN Data Center (172.16.10.0/26) melalui gateway `10.10.10.5` (HQ-Dika) sebagai primary path, sesuai tujuan konfigurasi cost manual pada Gambar 5.6.
> **Hasil konfigurasi yang ditunjukkan:** Seluruh rute dinamis OSPF bertanda flag `DAo` (Dynamic, Active, OSPF) dengan distance 110 (administrative distance default OSPF), sedangkan rute ke subnet yang langsung terhubung (connected) bertanda `DAc` dengan distance 0.

### 5.14 Ringkasan Konfigurasi

| **Router** | **Router-ID** | **Interfaces OSPF** | **Keterangan** |
| --- | --- | --- | --- |
| HQ-Dika | 1.1.1.1 | ether1, ether2, ether3 | Link ke DC, CAB1, CAB2 — tidak berubah |
| DC-Dicky-Rista | 2.2.2.2 | ether1, ether2, ether3, ether4 | Link ke HQ + LAN DC + 2 link backup baru |
| CAB1-Galih | 3.3.3.3 | ether1, ether3 (cost=100), vlan10-staff, vlan20-guest | Link ke HQ (primary) + DC backup (cost=100) + 2 VLAN Jabar |
| CAB2-Marist | 4.4.4.4 | ether1, ether3 (cost=100), vlan10-staff, vlan20-guest | Link ke HQ (primary) + DC backup (cost=100) + 2 VLAN Jatim |

*Tabel 5.14. Ringkasan Konfigurasi OSPF Final (Termasuk Backup Interface)*

---

## BAB 6. HASIL PENGUJIAN

### 6.1 Alur Paket (Packet Flow)

Pada kondisi normal (HQ-Dika aktif), seluruh traffic antar segmen tetap melewati HQ-Dika sebagai primary path sesuai konfigurasi OSPF cost. Contoh alur paket dari pc1.cab1 ke server.dc:

```
# Flow Normal: pc1.cab1 → server.dc (jalur via HQ)
pc1.cab1 (192.168.10.2)
  ↓ → Gateway VLAN 10 : CAB1-Galih vlan10-staff (192.168.10.1)
  ↓ → Backbone        : CAB1-Galih ether1 → HQ-Dika ether2
  ↓ → Core HQ         : HQ-Dika ether1
  ↓ → DC              : DC-Dicky-Rista ether1 → ether2
  ↓ → Tujuan          : server.dc (172.16.10.3)

# Flow Failover: pc1.cab1 → server.dc (saat HQ-Dika down)
pc1.cab1 (192.168.10.2)
  ↓ → Gateway VLAN 10 : CAB1-Galih vlan10-staff (192.168.10.1)
  ↓ → Backbone Backup : CAB1-Galih ether3 → DC-Dicky-Rista ether3
  ↓ → DC              : DC-Dicky-Rista ether2
  ↓ → Tujuan          : server.dc (172.16.10.3)
```

### 6.2 Verifikasi OSPF Neighbor

Verifikasi dilakukan di seluruh router. Setelah revisi topologi, DC-Dicky-Rista harus memiliki 3 neighbor, sedangkan CAB1-Galih dan CAB2-Marist masing-masing memiliki 2 neighbor.

```
# Di HQ-Dika — harus ada 3 neighbor: 2.2.2.2, 3.3.3.3, 4.4.4.4
/routing ospf neighbor print

# Di DC-Dicky-Rista — harus ada 3 neighbor: 1.1.1.1 (HQ), 3.3.3.3 (CAB1), 4.4.4.4 (CAB2)
/routing ospf neighbor print

# Di CAB1-Galih — harus ada 2 neighbor: 1.1.1.1 (HQ), 2.2.2.2 (DC)
/routing ospf neighbor print

# Di CAB2-Marist — harus ada 2 neighbor: 1.1.1.1 (HQ), 2.2.2.2 (DC)
/routing ospf neighbor print
```

**Gambar 6.1. routing ospf neighbor print pada HQ-Dika — menampilkan DC-Dicky-Rista (2.2.2.2), CAB1-Galih (3.3.3.3), CAB2-Marist (4.4.4.4) dengan state Full**

> 🖼️ **DESKRIPSI GAMBAR 6.1:**
>
> **Apa yang terlihat:** Tangkapan layar terminal MikroTik (prompt `[admin-hq@HQ-Dika] >`) menjalankan `/routing ospf neighbor print`. Flag legend: `V - VIRTUAL; D - DYNAMIC`. Tiga neighbor OSPF terdaftar:
> - `0`: `instance=ospf-nusantara area=area-backbone interface=ether1`, `address=10.10.10.2`, `priority=128`, `dr=10.10.10.1`, `bdr=10.10.10.2`, **`state="Full"`**, `state-changes=6`, `router-id=2.2.2.2`, `adjacency=15m44s`, `timeout=35s`
> - `1`: `interface=ether2`, `address=10.10.10.6`, `dr=10.10.10.5`, `bdr=10.10.10.6`, **`state="Full"`**, `router-id=3.3.3.3`, `adjacency=17m55s`, `timeout=35s`
> - `2`: `interface=ether3`, `address=10.10.10.10`, `dr=10.10.10.9`, `bdr=10.10.10.10`, **`state="Full"`**, `router-id=4.4.4.4`, `adjacency=21m15s`, `timeout=36s`
> **Tujuan gambar:** Membuktikan bahwa Router HQ-Dika berhasil membentuk OSPF adjacency dengan ketiga router lain (DC, CAB1, CAB2) melalui ether1, ether2, ether3 secara berurutan, seluruhnya dalam status **Full** (adjacency OSPF terbentuk sempurna, siap bertukar rute).
> **Hasil pengujian:** Sesuai ekspektasi pada Tabel 3.2 — HQ-Dika tetap memiliki 3 neighbor seperti pada topologi awal.

**Gambar 6.2. routing ospf neighbor print pada DC-Dicky-Rista — menampilkan 3 neighbor: HQ (1.1.1.1), CAB1 (3.3.3.3), CAB2 (4.4.4.4) dengan state Full**

> 🖼️ **DESKRIPSI GAMBAR 6.2:**
>
> **Apa yang terlihat:** Tangkapan layar terminal MikroTik (prompt `[admin-dc@DC-Dicky] >`) menjalankan `/routing ospf neighbor print`. Tiga neighbor terdaftar:
> - `0`: `interface=ether3`, `address=10.10.10.14`, `dr=10.10.10.14`, `bdr=10.10.10.13`, **`state="Full"`**, `router-id=3.3.3.3`, `adjacency=16m27s`, `timeout=33s`
> - `1`: `interface=ether4`, `address=10.10.10.18`, `dr=10.10.10.18`, `bdr=10.10.10.17`, **`state="Full"`**, `router-id=4.4.4.4`, `adjacency=16m27s`, `timeout=32s`
> - `2`: `interface=ether1`, `address=10.10.10.1`, `dr=10.10.10.1`, `bdr=10.10.10.2`, **`state="Full"`**, `router-id=1.1.1.1`, `adjacency=16m28s`, `timeout=32s`
> **Tujuan gambar:** Membuktikan bahwa DC-Dicky-Rista, setelah revisi topologi, berhasil membentuk OSPF adjacency dengan **3 neighbor** (CAB1 via ether3, CAB2 via ether4, dan HQ via ether1) — bertambah dari sebelumnya hanya 1 neighbor (HQ) pada topologi ATS, sesuai Tabel 3.2.
> **Hasil pengujian:** Seluruh neighbor berstatus Full, mengonfirmasi link backup DC↔CAB1 dan DC↔CAB2 berfungsi dengan baik di level OSPF.

**Gambar 6.3. routing ospf neighbor print pada CAB1-Galih — menampilkan 2 neighbor: HQ (1.1.1.1) dan DC (2.2.2.2) dengan state Full**

> 🖼️ **DESKRIPSI GAMBAR 6.3:**
>
> **Apa yang terlihat:** Tangkapan layar terminal MikroTik (prompt `[admin-cab1@Cab1-Gallih] >`) menjalankan `/routing ospf neighbor print`. Dua neighbor terdaftar:
> - `0`: `interface=ether1`, `address=10.10.10.5`, `dr=10.10.10.5`, `bdr=10.10.10.6`, **`state="Full"`**, `router-id=1.1.1.1`, `adjacency=19m37s`, `timeout=33s`
> - `1`: `interface=ether3`, `address=10.10.10.13`, `dr=10.10.10.14`, `bdr=10.10.10.13`, **`state="Full"`**, `router-id=2.2.2.2`, `adjacency=17m26s`, `timeout=34s`
> **Tujuan gambar:** Membuktikan bahwa CAB1-Galih memiliki tepat 2 neighbor OSPF (HQ via ether1, DC via ether3), sesuai Tabel 3.2 (topologi revisi), dan keduanya berstatus Full.
> **Hasil pengujian:** Kondisi ini diambil pada saat HQ masih aktif (kondisi normal) — kedua jalur (primary via HQ dan backup via DC) sama-sama terbentuk adjacency-nya, namun pemilihan jalur aktif tetap ditentukan oleh OSPF cost (lihat Gambar 5.7).

### 6.3 Verifikasi Routing Table OSPF (Kondisi Normal)

Rute yang dipelajari melalui OSPF memiliki flag ADo (Active, Dynamic, OSPF) pada routing table. Pada kondisi normal, rute ke 172.16.10.0/26 (DC) dari CAB1-Galih harus melewati HQ (next-hop 10.10.10.5).

```
# Di CAB1-Galih — kondisi normal (HQ aktif):
/ip route print

# Yang diharapkan: rute ke 172.16.10.0/26 via 10.10.10.5 (HQ-Dika)
```

**Gambar 6.4. ip route print pada CAB1-Galih (kondisi normal) — menampilkan rute ADo ke 172.16.10.0/26 via 10.10.10.5 (HQ-Dika sebagai primary path)**

> 🖼️ **DESKRIPSI GAMBAR 6.4:**
>
> **Apa yang terlihat:** Tangkapan layar terminal MikroTik menjalankan `/ip route print` pada CAB1-Galih. Isi tabel routing identik dengan Gambar 5.7: rute default (`Xs 0.0.0.0/0` via `10.10.10.5`, disabled), beberapa rute `DAo` (dynamic active OSPF, distance 110) menuju subnet backbone lain, dan baris kunci **`DAo 172.16.10.0/26` via `10.10.10.5%ether1`** (distance 110) — membuktikan rute ke LAN Data Center melewati HQ-Dika sebagai primary path. Rute lokal VLAN (`DAc 192.168.10.0/26` via `vlan10-staff`, `DAc 192.168.10.64/26` via `vlan20-guest`) tetap berstatus connected (distance 0).
> **Tujuan gambar:** Mengonfirmasi ulang (re-verifikasi pada fase pengujian BAB 6) bahwa flag `ADo` muncul pada seluruh rute dinamis hasil pembelajaran OSPF, dan primary path ke DC tetap melalui HQ.

### 6.4 Verifikasi VLAN Interface

**Gambar 6.5. interface vlan print pada CAB1-Galih — menampilkan vlan10-staff (VLAN ID 10) dan vlan20-guest (VLAN ID 20) pada interface ether2**

> 🖼️ **DESKRIPSI GAMBAR 6.5:**
>
> **Apa yang terlihat:** Tangkapan layar terminal MikroTik (prompt `[admin-cab1@Cab1-Gallih] >`) menjalankan `/interface vlan print`. Flag legend: `R - RUNNING`. Kolom: `#`, `NAME`, `MTU`, `ARP`, `VLAN-ID`, `INTERFACE`. Dua baris:
> - `0` (R): `vlan10-staff`, MTU `1500`, ARP `enabled`, VLAN-ID `10`, INTERFACE `ether2`
> - `1` (R): `vlan20-guest`, MTU `1500`, ARP `enabled`, VLAN-ID `20`, INTERFACE `ether2`
> **Tujuan gambar:** Membuktikan bahwa kedua sub-interface VLAN (Router-on-a-Stick) pada CAB1-Galih berjalan (status RUNNING) di atas interface fisik `ether2` yang sama, masing-masing dengan VLAN ID yang benar (10 dan 20) dan MTU standar 1500. Gambar ini melengkapi data yang seharusnya tampak pada Gambar 5.2.1 yang gambarnya tidak tersedia di dokumen asli.

**Gambar 6.6. interface bridge vlan print pada SW-Jabar — menampilkan VLAN 10 dan VLAN 20 dengan tagged port ether1**

> 🖼️ **DESKRIPSI GAMBAR 6.6:**
>
> **Apa yang terlihat:** Tangkapan layar terminal MikroTik (prompt `[admin@switch-Jabar] >`) menjalankan `/interface bridge vlan print`. Isi output identik secara substansi dengan Gambar 5.1.1: bridge `br-vlan` dengan VLAN-IDS `10` dan `20` keduanya CURRENT-TAGGED pada `ether1`, ditambah baris dynamic `;;; added by pvid` untuk VLAN 1 (untagged pada br-vlan/ether1), VLAN 10 (untagged pada ether2), dan VLAN 20 (untagged pada ether6).
> **Tujuan gambar:** Verifikasi ulang pada fase pengujian (BAB 6) bahwa konfigurasi Bridge VLAN Filtering pada SW-Jabar tetap konsisten dan berjalan dengan benar setelah seluruh tahap konfigurasi OSPF dan backup selesai dilakukan.

### 6.5 Pengujian Konektivitas VLAN

```
# pc1.cab1 ping ke Gateway VLAN 10:
ping 192.168.10.1

# pc2.cab1 ping ke Gateway VLAN 20:
ping 192.168.10.65
```

**Gambar 6.7. Ping dari pc1.cab1 (192.168.10.2) ke Gateway VLAN 10 (192.168.10.1) — Reply ✓**

> 🖼️ **DESKRIPSI GAMBAR 6.7:**
>
> **Apa yang terlihat:** Tangkapan layar terminal VPCS (prompt `pc1.cab1>`) menjalankan `ping 192.168.10.1`. Lima baris balasan ditampilkan, semuanya berhasil: `84 bytes from 192.168.10.1 icmp_seq=1 ttl=64 time=25.291 ms`, `icmp_seq=2 ttl=64 time=4.577 ms`, `icmp_seq=3 ttl=64 time=7.774 ms`, `icmp_seq=4 ttl=64 time=7.133 ms`, `icmp_seq=5 ttl=64 time=2.961 ms`.
> **Tujuan gambar:** Membuktikan konektivitas pc1.cab1 (klien VLAN 10/Staf) ke gateway VLAN 10-nya sendiri (192.168.10.1, interface vlan10-staff di CAB1-Galih) berjalan normal — seluruh 5 paket ICMP berhasil direspons (TTL 64, menandakan hanya 1 hop dari klien ke gateway langsung).

**Gambar 6.8. Ping dari pc2.cab1 (192.168.10.66) ke Gateway VLAN 20 (192.168.10.65) — Reply ✓**

> 🖼️ **DESKRIPSI GAMBAR 6.8:**
>
> **Apa yang terlihat:** Tangkapan layar jendela Command Prompt Windows (`C:\Users\MeMeBigBoy>`) menjalankan `ping 192.168.10.65`. Output menunjukkan 4 balasan sukses (`Reply from 192.168.10.65: bytes=32 time=11ms TTL=64`, dst. dengan waktu 11ms, 10ms, 9ms, 22ms), diikuti statistik: `Packets: Sent = 4, Received = 4, Lost = 0 (0% loss)`, dan `Minimum = 9ms, Maximum = 22ms, Average = 13ms`.
> **Tujuan gambar:** Membuktikan bahwa pc2.cab1 — klien Windows 7 yang merepresentasikan VLAN 20 (Guest) — berhasil terhubung ke gateway VLAN 20-nya (192.168.10.65, interface vlan20-guest di CAB1-Galih) tanpa packet loss, mengonfirmasi konfigurasi Inter-VLAN Routing berfungsi untuk VLAN Guest.

### 6.6 Pengujian Ping ke Server DC (Kondisi Normal)

```
# Dari pc1.cab1 ke server.dc:
ping 172.16.10.3
```

**Gambar 6.9. Ping dari pc1.cab1 ke server.dc (172.16.10.3) melalui jalur OSPF primary via HQ — Reply ✓**

> 🖼️ **DESKRIPSI GAMBAR 6.9:**
>
> **Apa yang terlihat:** Tangkapan layar terminal VPCS (`pc1.cab1>`) menjalankan `ping 172.16.10.3`. Lima balasan sukses dengan **TTL=61** pada setiap baris (`icmp_seq=1` hingga `5`, waktu masing-masing 16.053 ms, 10.114 ms, 35.908 ms, 18.445 ms, 10.270 ms).
> **Tujuan gambar:** Membuktikan pc1.cab1 berhasil melakukan ping ke server.dc melewati jalur primary (via HQ-Dika, 3 hop). Nilai TTL=61 (bukan TTL=64 default dikurangi jumlah hop) menjadi indikator jumlah hop yang dilalui paket — konsisten dengan jalur 3-hop yang dibuktikan pada Gambar 6.11 (traceroute normal).

**Gambar 6.10. Ping dari pc1.cab2 ke server.dc (172.16.10.3) — Reply ✓**

> 🖼️ **DESKRIPSI GAMBAR 6.10:**
>
> **Apa yang terlihat:** Tangkapan layar terminal VPCS (`pc1.cab2>`) menjalankan `ping 172.16.10.3`. Lima balasan sukses dengan TTL=61 (waktu 48.919 ms, 17.229 ms, 20.935 ms, 11.074 ms, 11.863 ms).
> **Tujuan gambar:** Membuktikan klien Staf di Cabang Jatim (pc1.cab2) juga berhasil mengakses server.dc melalui jalur primary via HQ, membuktikan konektivitas yang sama berlaku untuk kedua cabang (Jabar dan Jatim), bukan hanya Cabang Jabar.

### 6.7 Traceroute Normal — pc1.cab1 ke server.dc

Traceroute dilakukan saat HQ-Dika aktif untuk membuktikan jalur primary via HQ (3 hop: gateway VLAN → HQ → server.dc).

```
# Di pc1.cab1:
trace 172.16.10.3

# Hasil yang diharapkan (primary path via HQ):
# Hop 1: 192.168.10.1  (Gateway VLAN 10 — CAB1-Galih vlan10-staff)
# Hop 2: 10.10.10.5    (HQ-Dika ether2 sisi Cab1)
# Hop 3: 172.16.10.3   (server.dc — tujuan akhir)
```

**Gambar 6.11. Traceroute dari pc1.cab1 ke server.dc (kondisi normal) — menampilkan 3 hop: 192.168.10.1 → 10.10.10.5 (HQ) → 172.16.10.3**

> 🖼️ **DESKRIPSI GAMBAR 6.11:**
>
> **Apa yang terlihat:** Tangkapan layar terminal VPCS (`pc1.cab1>`) menjalankan `trace 172.16.10.3`, dengan header `trace to 172.16.10.3, 8 hops max, press Ctrl+C to stop`. Empat baris hop ditampilkan:
> - Hop `1`: `192.168.10.1` — waktu `9.060 ms  3.626 ms  3.306 ms`
> - Hop `2`: `10.10.10.5` — waktu `84.067 ms  8.411 ms  8.770 ms`
> - Hop `3`: `10.10.10.2` — waktu `7.733 ms  8.156 ms  5.985 ms`
> - Hop `4`: `*172.16.10.3` — waktu `14.764 ms (ICMP type:3, code:3, Destination port unreachable)`, menandakan paket telah mencapai tujuan akhir (server.dc merespons dengan ICMP "port unreachable" karena port UDP traceroute tidak ada layanan yang listen, ini adalah perilaku normal akhir traceroute pada VPCS).
> **Tujuan gambar:** Membuktikan jalur primary saat kondisi normal: dari gateway VLAN 10 (192.168.10.1) paket melewati HQ-Dika (10.10.10.5) lalu interface DC sisi HQ (10.10.10.2) sebelum mencapai server.dc (172.16.10.3). Tiga hop intermediate (192.168.10.1 → 10.10.10.5 → 10.10.10.2) plus baris ke-4 yang menandai tujuan akhir tercapai, konsisten dengan deskripsi "3 hop via HQ" pada Tabel 6.11.

### 6.8 Pengujian Failover — Simulasi HQ-Dika Down

Pengujian failover dilakukan dengan cara mematikan HQ-Dika di GNS3 dan mengamati apakah OSPF berhasil melakukan failover otomatis ke jalur backup DC langsung.

```
# Langkah 1 — Matikan HQ-Dika di GNS3
# Klik kanan HQ-Dika → Stop

# Langkah 2 — Tunggu konvergensi OSPF (40–60 detik / dead interval)

# Langkah 3 — Cek OSPF neighbor di CAB1-Galih
/routing ospf neighbor print
# Yang diharapkan:
#   - Neighbor 1.1.1.1 (HQ) sudah tidak ada
#   - Neighbor 2.2.2.2 (DC) masih ada dengan status Full

# Langkah 4 — Cek routing table CAB1-Galih setelah HQ down
/ip route print
# Yang diharapkan:
#   - Rute ke 172.16.10.0/26 via 10.10.10.13 (DC langsung) — masih ada
#   - Rute ke 10.10.10.0/30 (link HQ-DC) — sudah hilang

# Langkah 5 — Ping dari pc1.cab1 ke server.dc saat HQ down
ping 172.16.10.3
# Yang diharapkan: tetap reply — traffic kini lewat DC langsung

# Langkah 6 — Traceroute setelah HQ down
trace 172.16.10.3
# Yang diharapkan (backup path via DC langsung):
# Hop 1: 192.168.10.1  (Gateway VLAN 10)
# Hop 2: 172.16.10.3   (server.dc — via DC backup path, satu hop lebih sedikit)
```

**Gambar 6.12. Status HQ-Dika dimatikan di GNS3 — indikator router berubah merah (stopped)**

> 🖼️ **DESKRIPSI GAMBAR 6.12:**
>
> **Apa yang terlihat:** Potongan (cropped) dari diagram topologi GNS3, menampilkan kotak biru **"CORE NETWORK (HQ)"** berisi ikon router **HQ-Dika** beserta label info (`OSPF Router-ID: 1.1.1.1`, `Area: 0.0.0.0 (Backbone)`, `Interfaces: ether1, ether2, ether3`). Pada keempat titik koneksi router (atas — ke management cloud, kiri-bawah, tengah-bawah, kanan-bawah — ke tiga site lain) terdapat **kotak kecil berwarna merah** yang menggantikan indikator hijau (yang biasanya menandakan link aktif), menandakan seluruh interface pada HQ-Dika dalam status down/tidak aktif.
> **Tujuan gambar:** Memvisualisasikan secara langsung di kanvas simulasi GNS3 bahwa Router HQ-Dika telah dihentikan (klik kanan → Stop) sebagai bagian dari skenario pengujian failover, sesuai Langkah 1 pada prosedur pengujian di atas.
> **Informasi penting:** Indikator merah pada keempat port HQ-Dika (bukan hijau seperti pada Gambar 3.1) adalah representasi visual GNS3 untuk node yang sedang berstatus stopped/down.

**Gambar 6.13. routing ospf neighbor print pada CAB1-Galih setelah HQ down — menampilkan hanya DC (2.2.2.2) dengan state Full; neighbor HQ (1.1.1.1) sudah tidak ada**

> 🖼️ **DESKRIPSI GAMBAR 6.13:**
>
> **Apa yang terlihat:** Tangkapan layar terminal MikroTik (`[admin-cab1@Cab1-Gallih] >`) menjalankan `/routing ospf neighbor print`. Hanya **satu** neighbor tersisa:
> - `0`: `instance=ospf-nusantara area=area-backbone interface=ether3`, `address=10.10.10.13`, `priority=128`, `dr=10.10.10.14`, `bdr=10.10.10.13`, **`state="Full"`**, `state-changes=6`, `router-id=2.2.2.2`, `adjacency=31m41s`, `timeout=40s`
> **Tujuan gambar:** Membuktikan bahwa setelah HQ-Dika dimatikan, neighbor OSPF dengan router-id 1.1.1.1 (HQ) menghilang dari tabel, sementara neighbor DC (2.2.2.2, via ether3) tetap berstatus Full — bukti bahwa adjacency OSPF ke jalur backup tidak terganggu sama sekali oleh matinya HQ.

**Gambar 6.14. ip route print pada CAB1-Galih setelah HQ down — rute ke 172.16.10.0/26 kini via 10.10.10.13 (DC-Dicky-Rista backup path)**

> 🖼️ **DESKRIPSI GAMBAR 6.14:**
>
> **Apa yang terlihat:** Tangkapan layar terminal MikroTik menjalankan `/ip route print` setelah HQ down. Kolom dan flag legend sama seperti sebelumnya. Baris data:
> - `Xs 0.0.0.0/0` via `10.10.10.5` (default route, masih tertera namun disabled/static)
> - `DAo 10.10.10.0/30` via **`10.10.10.13%ether3`** (distance 110) — berubah dari sebelumnya via ether1/HQ
> - `DAc 10.10.10.4/30` via `ether1` (distance 0, masih terhubung secara fisik/connected meskipun HQ tidak merespons OSPF)
> - `DAo 10.10.10.8/30` via `10.10.10.13%ether3` (distance 110)
> - `DAc 10.10.10.12/30` via `ether3` (distance 0)
> - `DAo 10.10.10.16/30` via `10.10.10.13%ether3` (distance 110)
> - **`DAo 172.16.10.0/26` via `10.10.10.13%ether3`** (distance 110) ← rute ke server.dc kini lewat DC langsung
> - `DAc 192.168.10.0/26` via `vlan10-staff` (distance 0)
> - `DAc 192.168.10.64/26` via `vlan20-guest` (distance 0)
> - `DAo 192.168.20.0/26` via `10.10.10.13%ether3` (distance 110)
> - `DAo 192.168.20.64/26` via `10.10.10.13%ether3` (distance 110)
> **Tujuan gambar:** Membuktikan bahwa OSPF berhasil melakukan re-konvergensi (SPF recalculation) setelah HQ-Dika down — seluruh rute dinamis yang sebelumnya melalui `10.10.10.5%ether1` (HQ) kini sepenuhnya berpindah ke `10.10.10.13%ether3` (DC langsung), termasuk rute kunci ke `172.16.10.0/26` (server.dc).

**Gambar 6.15. Ping dari pc1.cab1 ke server.dc (172.16.10.3) saat HQ down — tetap Reply ✓ membuktikan failover berhasil**

> 🖼️ **DESKRIPSI GAMBAR 6.15:**
>
> **Apa yang terlihat:** Tangkapan layar terminal VPCS (`pc1.cab1>`) menjalankan `ping 172.16.10.3`. Lima balasan sukses dengan **TTL=62** (waktu 17.399 ms, 12.943 ms, 11.559 ms, 22.297 ms, 15.976 ms).
> **Tujuan gambar:** Membuktikan bahwa meski HQ-Dika down, ping dari pc1.cab1 ke server.dc tetap berhasil (tidak ada request timeout), membuktikan failover OSPF otomatis berfungsi.
> **Detail penting:** TTL bernilai **62** di sini, lebih tinggi 1 dibanding TTL=61 pada Gambar 6.9 (kondisi normal) — konsisten dengan jalur backup yang satu hop lebih pendek (2 hop) dibandingkan jalur primary (3 hop).

**Gambar 6.16. Traceroute dari pc1.cab1 ke server.dc saat HQ down — menampilkan 2 hop: 192.168.10.1 → 172.16.10.3 (jalur langsung via DC backup)**

> 🖼️ **DESKRIPSI GAMBAR 6.16:**
>
> **Apa yang terlihat:** Tangkapan layar terminal VPCS (`pc1.cab1>`) menjalankan `trace 172.16.10.3`. Header `trace to 172.16.10.3, 8 hops max, press Ctrl+C to stop`. Tiga baris ditampilkan:
> - Hop `1`: `192.168.10.1` — waktu `6.684 ms  2.373 ms  2.620 ms`
> - Hop `2`: `10.10.10.13` — waktu `3.881 ms  6.295 ms  3.467 ms`
> - Hop `3`: `*172.16.10.3` — waktu `10.913 ms (ICMP type:3, code:3, Destination port unreachable)` — menandai tujuan akhir tercapai.
> **Tujuan gambar:** Membuktikan jalur backup yang dipakai saat failover: dari gateway VLAN 10 (192.168.10.1) paket langsung melalui interface backup DC (10.10.10.13) tanpa lagi melewati HQ-Dika, sebelum mencapai server.dc. Ini adalah 2 hop intermediate (dibandingkan 3 hop pada Gambar 6.11 kondisi normal), membuktikan jalur menjadi lebih singkat satu hop karena HQ-Dika di-bypass.

**Tabel Hasil Pengukuran Waktu Failover**

| **Parameter** | **Nilai** |
| --- | --- |
| Latensi normal (HQ on) | 10 ms |
| Waktu mulai time out | T+0 detik |
| Durasi time out | 36.73 detik |
| Waktu failover total | 36.73 detik |
| Latensi setelah failover | 10 ms |
| Hop normal (via HQ) | 3 hop |
| Hop setelah failover | 2 hop |

### 6.9 Resolusi DNS

**Gambar 6.17. Ping menggunakan nama domain dari pc1.cab1 — DNS resolve inventory.nusantara.local → 172.16.10.3**

> 🖼️ **DESKRIPSI GAMBAR 6.17:**
>
> **Apa yang terlihat:** Tangkapan layar terminal VPCS (`pc1.cab1>`) menjalankan `ping inventory.nusantara.local`. Baris pertama output: `inventory.nusantara.local resolved to 172.16.10.3`, diikuti lima balasan ping sukses dengan TTL=62 (waktu 22.520 ms, 9.330 ms, 16.558 ms, 10.929 ms, 10.546 ms).
> **Tujuan gambar:** Membuktikan bahwa layanan DNS (Bind9) di server.dc berhasil melakukan resolusi nama domain internal `inventory.nusantara.local` menjadi alamat IP `172.16.10.3`, dan klien berhasil melakukan ping ke alamat tersebut menggunakan nama domain (bukan IP langsung).

### 6.10 Akses Web Server

**Gambar 6.18. Akses browser ke http://inventory.nusantara.local dari pc2.cab1 — halaman web PT Nusantara Retail Digital berhasil dimuat**

> 🖼️ **DESKRIPSI GAMBAR 6.18:**
>
> **Apa yang terlihat:** Tangkapan layar jendela aplikasi virtualisasi berjudul **"Windows7-GNS3 (GNS3 Linked Base for clones) [Running] - Oracle VirtualBox"**, menampilkan browser Google Chrome dengan tab terbuka berjudul "PT Nusantara Retail Digital — Int..." dan address bar bertuliskan `inventory.nusantara.local/` (dengan indikator "Not secure" karena HTTP tanpa SSL). Halaman web yang termuat menampilkan dashboard internal dengan:
> - Badge atas: "■ SISTEM INTERNAL • RESTRICTED ACCESS"
> - Judul besar: **"PT Nusantara Retail Digital"** dengan subjudul "— Internal Network Dashboard —"
> - Kartu status hijau: **"ONLINE • CONNECTED — Terhubung ke Data Center"**, dengan info tambahan `LIVE`, IP `172.16.10.3`, dan badge "✓ AKTIF"
> - Empat kotak ringkasan kecil: **TOPOLOGI** "Star via HQ", **PROTOKOL** "TCP/IP v4", **CABANG AKTIF** "2 / 2", **UPTIME** "00:00:47"
> - Empat kartu status sistem (masing-masing dengan indikator bulat hijau "online"): **01 — JARINGAN "Status Jaringan"** ("Semua cabang terhubung melalui HQ secara terpusat dan stabil."), **02 — SERVER "Data Center"** ("Server pusat aktif dan siap melayani semua permintaan dari cabang."), **03 — CABANG "Cabang Aktif"** ("Cabang Jabar & Jatim aktif dan terhubung ke sistem pusat."), **04 — KEAMANAN "Akses Aman"** ("Akses dikelola melalui routing terpusat HQ. Tidak ada akses langsung antar cabang.")
> - Taskbar Windows 7 di bagian bawah jendela menunjukkan jam "8:28 PM 5/20/2026".
> **Tujuan gambar:** Membuktikan bahwa Web Server (Apache2) di server.dc berhasil diakses melalui browser menggunakan nama domain (bukan IP langsung), dan halaman dashboard internal perusahaan berhasil dimuat secara sempurna dari klien pc2.cab1 (Guest VLAN 20).
> **Catatan kontekstual:** Teks pada kartu "TOPOLOGI: Star via HQ" di dalam halaman web tersebut adalah konten statis halaman web internal perusahaan (bukan data topologi real-time), sehingga label tersebut belum diperbarui untuk mencerminkan revisi topologi partial mesh yang dijelaskan pada BAB 3; ini hanyalah konten tampilan dashboard, bukan representasi aktual status routing jaringan.

### 6.11 Tabel Ringkasan Hasil Pengujian

| **No** | **Pengujian** | **Sumber** | **Tujuan** | **Hasil** |
| --- | --- | --- | --- | --- |
| 1 | OSPF Neighbor State HQ-Dika | HQ-Dika | DC, CAB1, CAB2 | Full ✓ |
| 2 | OSPF Neighbor State DC-Dicky-Rista | DC-Dicky-Rista | HQ, CAB1, CAB2 | Full ✓ |
| 3 | OSPF Neighbor CAB1 (2 neighbor) | CAB1-Galih | HQ, DC | Full ✓ |
| 4 | Routing Table OSPF flag ADo | CAB1-Galih | Semua jaringan | ADo ✓ |
| 5 | Routing Table — Primary via HQ | CAB1-Galih | 172.16.10.0/26 | Via 10.10.10.5 ✓ |
| 6 | Ping VLAN 10 → Gateway | pc1.cab1 | 192.168.10.1 | Reply ✓ |
| 7 | Ping VLAN 20 → Gateway | pc2.cab1 | 192.168.10.65 | Reply ✓ |
| 8 | Ping Staf Jabar → server.dc | pc1.cab1 | 172.16.10.3 | Reply ✓ |
| 9 | Ping Guest Jabar → server.dc | pc2.cab1 | 172.16.10.3 | Reply ✓ |
| 10 | Ping Staf Jatim → server.dc | pc1.cab2 | 172.16.10.3 | Reply ✓ |
| 11 | Ping Guest Jatim → server.dc | pc2.cab2 | 172.16.10.3 | Reply ✓ |
| 12 | Traceroute Normal (3 hop via HQ) | pc1.cab1 | 172.16.10.3 | 3 hop ✓ |
| 13 | OSPF Neighbor setelah HQ down | CAB1-Galih | DC (2.2.2.2) | Full ✓ |
| 14 | Routing Table setelah HQ down | CAB1-Galih | 172.16.10.0/26 | Via 10.10.10.13 ✓ |
| 15 | Ping ke DC saat HQ down | pc1.cab1 | 172.16.10.3 | Reply ✓ (Failover) |
| 16 | Traceroute saat HQ down (2 hop via DC) | pc1.cab1 | 172.16.10.3 | 2 hop ✓ |
| 17 | DNS Resolution | pc1.cab1 | inventory.nusantara.local | Resolve ✓ |
| 18 | Web Server Access | pc2.cab1 | http://inventory | Muncul ✓ |
| 19 | Ping antar Cabang | pc1.cab1 | 192.168.20.2 | Reply ✓ |

*Tabel 6.11. Ringkasan Hasil Pengujian (Termasuk Pengujian Failover)*

---

## BAB 7. ANALISIS

### 7.1 Mengapa ether2 Tidak Perlu IP dan Konsep Router-on-a-Stick

Pada konfigurasi sebelumnya (tanpa VLAN), ether2 berfungsi sebagai interface biasa dalam satu domain broadcast (192.168.X.0/26) sehingga memiliki satu IP address sebagai gateway.

Setelah VLAN diterapkan dengan teknik Router-on-a-Stick, ether2 berubah fungsi menjadi trunk port yang meneruskan frame dari dua VLAN berbeda (VLAN 10 dan VLAN 20) dalam satu kabel fisik. Frame-frame ini dibedakan menggunakan tag VLAN IEEE 802.1Q.

Trunk port tidak dapat memiliki satu IP address tunggal karena ia menangani dua domain broadcast yang berbeda secara bersamaan. Oleh karena itu, IP address berpindah ke dua sub-interface logical: vlan10-staff mendapatkan IP 192.168.X.1/26 sebagai gateway VLAN 10, dan vlan20-guest mendapatkan IP 192.168.X.65/26 sebagai gateway VLAN 20. Dengan demikian, satu kabel fisik (ether2) dan satu interface fisik mampu melayani dua jaringan VLAN yang terpisah secara logis.

### 7.2 Perbandingan Static Routing vs OSPF

| **Aspek** | **Static Routing (ATS)** | **OSPF (Modul 3)** |
| --- | --- | --- |
| Konfigurasi rute | Manual — admin input setiap rute | Otomatis — router belajar dari tetangga |
| Respons link down | Tidak ada — traffic terputus | Recalculate otomatis dalam hitungan detik |
| Penambahan cabang | Tambah static route manual di semua router | Router baru cukup aktifkan OSPF |
| Visibilitas rute | Terbatas | Lengkap — setiap router punya peta topologi |
| Self-healing | Tidak ada | Ada — reroute otomatis |
| Overhead | Sangat ringan | Sedikit lebih berat (hello, LSA exchange) |

*Tabel 7.2. Perbandingan Static Routing vs OSPF*

### 7.3 Cara Kerja Failover OSPF

OSPF menggunakan mekanisme Hello packet untuk mendeteksi kegagalan neighbor. Pada MikroTik RouterOS v7, Hello interval default adalah 10 detik dan Dead interval 40 detik. Berikut timeline failover saat HQ-Dika dimatikan:

| **Waktu** | **Kejadian** |
| --- | --- |
| T+0 detik | HQ-Dika dimatikan |
| T+10 detik | Hello packet pertama tidak diterima oleh DC, CAB1, CAB2 |
| T+20 detik | Hello packet kedua tidak diterima |
| T+30 detik | Hello packet ketiga tidak diterima |
| T+40 detik | Dead timer habis — neighbor HQ-Dika dinyatakan down oleh semua router tetangganya |
| T+41 detik | OSPF mulai recalculate SPF (Dijkstra algorithm) |
| T+42 detik | Rute baru via DC langsung aktif di routing table CAB1-Galih dan CAB2-Marist |
| T+42+ detik | Traffic dari cabang ke server.dc kembali mengalir melalui jalur backup DC langsung |

*Tabel 7.3. Timeline Failover OSPF saat HQ-Dika Down*

Proses recalculation berjalan sepenuhnya otomatis. OSPF menghapus semua rute yang next-hop-nya melewati HQ-Dika (10.10.10.5), kemudian menghitung ulang jalur terpendek berdasarkan topologi yang tersisa. Karena tersedia link langsung DC ↔ CAB1 dan DC ↔ CAB2, OSPF langsung memasukkan rute baru via 10.10.10.13 (DC ether3 sisi CAB1) ke routing table. Tidak diperlukan intervensi administrator sama sekali.

**Tabel Perbandingan Teoritis dengan Aktual**

| **Tahap** | **Teoritis** | **Aktual** |
| --- | --- | --- |
| Dead interval | 40 detik | 40 detik |
| SPF recalculate | 1-3 detik | <1 detik |
| Total failover | 40-60 detik | 36.73 detik |
| Ping recovery | 2ms | 9.599ms |

Berdasarkan hasil pengujian failover yang dilakukan sebanyak tiga kali, diperoleh waktu failover masing-masing sebesar 37.92 detik, 36.61 detik, dan 35.65 detik dengan rata-rata 36.73 detik. Hasil tersebut menunjukkan bahwa protokol OSPF berhasil mendeteksi kegagalan tautan pada router HQ-Dika setelah dead interval 40 detik terpenuhi dan langsung melakukan SPF recalculate kurang dari 1 detik untuk mengaktifkan jalur alternatif melalui router DC. Dengan demikian, sistem jaringan PT Nusantara Retail Digital terbukti mampu melakukan failover secara otomatis tanpa intervensi manual dengan waktu pemulihan yang berada dalam batas toleransi operasional.

### 7.4 Analisis OSPF Cost dan Pemilihan Jalur

Tanpa konfigurasi cost manual, OSPF secara default memilih jalur DC langsung sebagai primary karena jalur tersebut memiliki total cost lebih rendah (2 hop) dibandingkan jalur via HQ (3 hop). Namun requirement implementasi menghendaki HQ-Dika tetap sebagai jalur utama agar pola traffic konsisten dengan arsitektur semula.

Dengan menaikkan cost interface ether3 (backup) menjadi 100 di CAB1-Galih dan CAB2-Marist, total cost jalur DC langsung menjadi jauh lebih tinggi dibandingkan jalur via HQ. Hasilnya, OSPF memilih jalur via HQ sebagai primary saat kondisi normal. Ketika HQ down, jalur backup dengan cost 100 menjadi satu-satunya pilihan dan OSPF menggunakannya secara otomatis.

### 7.5 Analisis Hasil Modernisasi dan Revisi Topologi

Modernisasi infrastruktur berhasil mencapai tiga tujuan utama. Pertama, segmentasi VLAN meningkatkan keamanan jaringan di setiap cabang: traffic staf dan guest terpisah dalam domain broadcast berbeda, sehingga guest tidak dapat langsung mengakses jaringan staf tanpa melewati router.

Kedua, migrasi ke OSPF meningkatkan ketangguhan backbone. Routing table pada setiap router kini terisi secara dinamis, sehingga perubahan topologi dapat ditangani otomatis tanpa intervensi administrator.

Ketiga, revisi topologi menjadi partial mesh berhasil menghilangkan single point of failure pada HQ-Dika. Dengan penambahan link backup DC ↔ CAB1 dan DC ↔ CAB2, OSPF kini memiliki dua jalur dari setiap cabang menuju Data Center. Ketika HQ-Dika down, OSPF mendeteksi kegagalan melalui mekanisme dead interval dan secara otomatis merekalkukasi jalur menggunakan algoritma SPF dalam waktu kurang dari 60 detik, tanpa intervensi manual.

---

## BAB 8. KESIMPULAN

Modernisasi infrastruktur jaringan PT Nusantara Retail Digital pada Praktikum Modul 3 telah berhasil diselesaikan dengan tiga pencapaian utama:

Pertama, implementasi VLAN berhasil memisahkan traffic karyawan staf (VLAN 10, port ether2–ether5) dan tamu (VLAN 20, port ether6–ether8) di Cabang Jabar dan Jatim menggunakan managed switch SW-Jabar dan SW-Jatim berbasis MikroTik CHR dengan Bridge VLAN Filtering. Inter-VLAN Routing dikonfigurasi menggunakan teknik Router-on-a-Stick pada CAB1-Galih dan CAB2-Marist, dengan sub-interface vlan10-staff dan vlan20-guest masing-masing sebagai gateway VLAN.

Kedua, migrasi ke OSPF berhasil menggantikan static routing di seluruh router (HQ-Dika, DC-Dicky-Rista, CAB1-Galih, CAB2-Marist) dengan protokol routing dinamis OSPF v7. Seluruh router berhasil membentuk adjacency dengan status Full, routing table terisi dengan rute ADo, dan jaringan kini memiliki kemampuan self-healing.

Ketiga, revisi topologi menjadi partial mesh berhasil menghilangkan single point of failure pada Router HQ-Dika. Dengan penambahan dua link backup langsung antara Data Center dan masing-masing cabang (10.10.10.12/30 untuk DC ↔ CAB1, dan 10.10.10.16/30 untuk DC ↔ CAB2), jaringan PT Nusantara Retail Digital kini bersifat fault-tolerant terhadap kegagalan HQ-Dika. OSPF terbukti melakukan failover otomatis dalam waktu kurang dari 60 detik (satu dead interval), memastikan ketersediaan layanan DNS dan Web Server di Data Center tetap terjaga meskipun HQ mengalami gangguan. Konfigurasi OSPF cost manual (cost=100) pada interface backup memastikan HQ-Dika tetap berfungsi sebagai primary path saat kondisi jaringan normal.

Seluruh pengujian konektivitas berhasil: ping antar VLAN, ping ke server.dc, traceroute 3 hop (gateway VLAN → HQ → server.dc) saat kondisi normal, failover otomatis saat HQ down, traceroute 2 hop (gateway VLAN → server.dc langsung) saat failover, resolusi DNS, dan akses web server.

| **Pengujian** | **Target** | **Hasil** |
| --- | --- | --- |
| OSPF Neighbor (HQ-Dika) | DC, CAB1, CAB2 state Full | Berhasil |
| OSPF Neighbor (DC-Dicky-Rista) | HQ, CAB1, CAB2 state Full | Berhasil |
| Routing Table OSPF | Flag ADo pada semua rute dinamis | Berhasil |
| Primary path via HQ | Rute ke DC via 10.10.10.5 | Berhasil |
| Ping VLAN 10 → Gateway (Jabar) | Reply dari 192.168.10.1 | Berhasil |
| Ping VLAN 20 → Gateway (Jabar) | Reply dari 192.168.10.65 | Berhasil |
| Ping Staf/Guest → server.dc | Reply dari 172.16.10.3 | Berhasil |
| Traceroute Normal (via HQ) | 3 hop: GW VLAN → HQ → server.dc | Berhasil |
| OSPF Failover saat HQ down | Neighbor HQ hilang, DC tetap Full | Berhasil |
| Ping ke DC saat HQ down | Reply tetap dari 172.16.10.3 | Berhasil |
| Traceroute saat HQ down | 2 hop: GW VLAN → server.dc via DC | Berhasil |
| DNS Resolution | Resolve inventory.nusantara.local | Berhasil |
| Web Server Access | Halaman web PT Nusantara terbuka | Berhasil |

*Tabel 8.1. Ringkasan Hasil Pengujian Final*
