#!/data/data/com.termux/files/usr/bin/bash
# Jalankan di DALAM folder repo GitHub kamu.
# Script ini membuat semua file proyek video "4.000 minggu", lalu memasang paketnya.
set -e

echo "== Membuat file proyek =="
mkdir -p src out

cat > .gitignore << 'EOF'
node_modules
out
EOF

cat > package.json << 'EOF'
{
  "name": "video-4000-minggu",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "foto": "remotion still src/index.jsx Minggu out/foto.png --frame=2150",
    "tes": "remotion render src/index.jsx Minggu out/tes.mp4 --frames=1950-2099 --concurrency=2",
    "render": "remotion render src/index.jsx Minggu out/video.mp4 --concurrency=2"
  }
}
EOF

cat > src/index.jsx << 'EOF'
import {registerRoot} from 'remotion';
import {Root} from './Root';

registerRoot(Root);
EOF

cat > src/Root.jsx << 'EOF'
import React from 'react';
import {Composition} from 'remotion';
import {Hidup} from './Hidup';
import {DURASI_DETIK, FPS, LEBAR_VIDEO, TINGGI_VIDEO} from './gaya';

export const Root = () => (
  <Composition
    id="Minggu"
    component={Hidup}
    durationInFrames={DURASI_DETIK * FPS}
    fps={FPS}
    width={LEBAR_VIDEO}
    height={TINGGI_VIDEO}
  />
);
EOF

cat > src/gaya.js << 'EOF'
import {Easing, interpolate} from 'remotion';

export const FPS = 30;
export const LEBAR_VIDEO = 1920;
export const TINGGI_VIDEO = 1080;
export const DURASI_DETIK = 100;

export const WARNA = {
  latar: '#101426',
  teks: '#f1ece4',
  redup: '#9aa0bd',
  kosong: '#1d2340',
  anak: '#5cc2b0',
  dewasa: '#8a94c8',
  sisa: '#34508a',
  biru: '#7fb0ff',
  tidur: '#9a7be6',
  emas: '#ffc857',
  sayang: '#ff6477',
  sekarang: '#ffffff',
};

export const FONT =
  'system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif';

// detik -> nomor frame
export const detik = (s) => Math.round(s * FPS);

// Animasi nilai dari v0 ke v1 antara detik t0 dan t1
export const an = (frame, [t0, t1], [v0, v1], easing = Easing.inOut(Easing.cubic)) =>
  interpolate(frame, [detik(t0), detik(t1)], [v0, v1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing,
  });

// Angka dengan titik ribuan: 4160 -> 4.160
export const titik = (n) =>
  String(Math.round(n)).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
EOF

cat > src/Kisi.jsx << 'EOF'
import React from 'react';
import {WARNA} from './gaya';

export const KOLOM = 52;
export const BARIS = 80;
export const TOTAL = KOLOM * BARIS;
export const JARAK = 12;
export const SEL = 10;
export const LEBAR_KISI = KOLOM * JARAK;
export const TINGGI_KISI = BARIS * JARAK;

export const posisiKotak = (idx) => ({
  x: (idx % KOLOM) * JARAK,
  y: Math.floor(idx / KOLOM) * JARAK,
});

const Pola = ({id, warna, lebar = 1}) => (
  <pattern id={id} width={JARAK * lebar} height={JARAK} patternUnits="userSpaceOnUse">
    <rect x={1} y={1} width={SEL} height={SEL} rx={2} fill={warna} />
  </pattern>
);

// Mewarnai kotak nomor [dari, ke) dengan pola tertentu
const Rentang = ({dari, ke, pola, opacity = 1}) => {
  const a = Math.max(0, Math.round(dari));
  const b = Math.min(TOTAL, Math.round(ke));
  if (b <= a || opacity <= 0) return null;
  const baris1 = Math.floor(a / KOLOM);
  const kol1 = a % KOLOM;
  const baris2 = Math.floor((b - 1) / KOLOM);
  const kol2 = (b - 1) % KOLOM;
  const isi = `url(#${pola})`;
  const potong = (baris, ka, kb, key) => (
    <rect
      key={key}
      x={ka * JARAK}
      y={baris * JARAK}
      width={(kb - ka + 1) * JARAK}
      height={JARAK}
      fill={isi}
      opacity={opacity}
    />
  );
  if (baris1 === baris2) {
    return <g>{potong(baris1, kol1, kol2, 'a')}</g>;
  }
  return (
    <g>
      {potong(baris1, kol1, KOLOM - 1, 'a')}
      {baris2 - baris1 > 1 ? (
        <rect
          key="b"
          x={0}
          y={(baris1 + 1) * JARAK}
          width={KOLOM * JARAK}
          height={(baris2 - baris1 - 1) * JARAK}
          fill={isi}
          opacity={opacity}
        />
      ) : null}
      {potong(baris2, 0, kol2, 'c')}
    </g>
  );
};

export const Kisi = ({lapisan, children}) => (
  <svg width={LEBAR_KISI} height={TINGGI_KISI} style={{overflow: 'visible'}}>
    <defs>
      <Pola id="kosong" warna={WARNA.kosong} />
      <Pola id="anak" warna={WARNA.anak} />
      <Pola id="dewasa" warna={WARNA.dewasa} />
      <Pola id="sisa" warna={WARNA.sisa} />
      <Pola id="tidur" warna={WARNA.tidur} lebar={3} />
      <Pola id="emas" warna={WARNA.emas} />
    </defs>
    {lapisan.map((l, i) => (
      <Rentang key={i} {...l} />
    ))}
    {children}
  </svg>
);
EOF

cat > src/Teks.jsx << 'EOF'
import React from 'react';
import {AbsoluteFill, Easing, interpolate, useCurrentFrame} from 'remotion';
import {FONT, WARNA, an, detik, titik} from './gaya';

const UKURAN = {raksasa: 200, besar: 80, sedang: 58, kecil: 40};

// Satu baris teks. u = ukuran, w = warna (lihat WARNA di gaya.js)
export const T = ({u = 'sedang', w = 'teks', children, style}) => (
  <div
    style={{
      fontFamily: FONT,
      fontSize: UKURAN[u],
      fontWeight: u === 'besar' || u === 'raksasa' ? 800 : 600,
      color: WARNA[w],
      lineHeight: 1.18,
      margin: '6px 0',
      fontVariantNumeric: 'tabular-nums',
      ...style,
    }}
  >
    {children}
  </div>
);

const Masuk = ({awal, tunda, children}) => {
  const frame = useCurrentFrame();
  const t = interpolate(frame, [awal + tunda, awal + tunda + 16], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.cubic),
  });
  return (
    <div style={{opacity: t, transform: `translateY(${(1 - t) * 28}px)`}}>
      {children}
    </div>
  );
};

// Sekelompok baris teks yang muncul pada detik "mulai" dan hilang pada detik "akhir".
// tengah = di tengah layar (tanpa kisi). jeda = selang antar baris (dalam frame).
export const Grup = ({mulai, akhir, tengah = false, jeda = 12, children}) => {
  const frame = useCurrentFrame();
  const a = detik(mulai);
  const b = detik(akhir);
  if (frame < a || frame > b) return null;
  const keluar = interpolate(frame, [b - 12, b], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const anak = React.Children.toArray(children);
  return (
    <AbsoluteFill
      style={{
        justifyContent: 'center',
        alignItems: tengah ? 'center' : 'flex-start',
        textAlign: tengah ? 'center' : 'left',
        paddingLeft: tengah ? 0 : 940,
        paddingRight: tengah ? 0 : 100,
        opacity: keluar,
      }}
    >
      {anak.map((el, i) => (
        <Masuk key={i} awal={a} tunda={i * jeda}>
          {el}
        </Masuk>
      ))}
    </AbsoluteFill>
  );
};

// Angka yang menghitung naik dari 0 sampai "ke"
export const Hitung = ({ke, mulai, akhir, u = 'raksasa', w = 'emas'}) => {
  const frame = useCurrentFrame();
  const n = an(frame, [mulai, akhir], [0, ke], Easing.out(Easing.cubic));
  return (
    <T u={u} w={w}>
      {titik(n)}
    </T>
  );
};
EOF

cat > src/Hidup.jsx << 'EOF'
import React from 'react';
import {AbsoluteFill, Easing, useCurrentFrame} from 'remotion';
import {Kisi, KOLOM, TOTAL, JARAK, SEL, posisiKotak} from './Kisi';
import {Grup, Hitung, T} from './Teks';
import {FONT, WARNA, an, detik, titik} from './gaya';

// ---- Pengaturan utama ----
const UMUR = 25; // umur contoh di video (ubah angka ini jika mau)
const JUMLAH_SAYANG = 36; // kotak merah: orang yang disayang

const MINGGU_ANAK = 18 * KOLOM;
const SEKARANG = UMUR * KOLOM;
const SISA = TOTAL - SEKARANG;
const TERJAGA = Math.round((SISA * 2) / 3 / 100) * 100;
const KIRI = 190;
const ATAS = 60;

// Posisi kotak merah, tersebar merata di sisa hidup
const SAYANG = Array.from({length: JUMLAH_SAYANG}, (_, k) => {
  const langkah = (SISA - 60) / JUMLAH_SAYANG;
  const acak = ((k * 53) % 31) - 15;
  const idx = Math.round(SEKARANG + 30 + k * langkah + acak);
  return Math.max(SEKARANG + 10, Math.min(TOTAL - 1, idx));
});

export const Hidup = () => {
  const f = useCurrentFrame();

  const pudar = an(f, [99, 100], [1, 0]);
  const opKisi = an(f, [8, 8.8], [0, 1]);
  const tampil = an(f, [8.2, 12.8], [0, TOTAL]);
  const anak = an(f, [21, 24], [0, MINGGU_ANAK]);
  const dewasa = an(f, [26.4, 29.4], [MINGGU_ANAK, SEKARANG]);
  const opSisa = an(f, [36, 37.5], [0, 1]);
  const opTidur = Math.min(an(f, [41.5, 43.5], [0, 0.9]), an(f, [76.5, 78], [1, 0]));
  const emas = an(f, [77, 81], [0, SISA]);
  const opLabel = Math.min(an(f, [12.5, 13.5], [0, 1]), an(f, [85, 86], [1, 0]));

  const lapisan = [
    {dari: 0, ke: tampil, pola: 'kosong'},
    {dari: 0, ke: anak, pola: 'anak'},
    {dari: MINGGU_ANAK, ke: dewasa, pola: 'dewasa'},
    {dari: SEKARANG, ke: TOTAL, pola: 'sisa', opacity: opSisa},
    {dari: SEKARANG, ke: TOTAL, pola: 'tidur', opacity: opTidur},
    {dari: SEKARANG, ke: SEKARANG + emas, pola: 'emas'},
  ];

  // Penanda "minggu ini"
  const pos = posisiKotak(SEKARANG);
  const tanda = an(f, [29.4, 30], [0, 1]);
  const fase = (f % 40) / 40;

  return (
    <AbsoluteFill style={{background: WARNA.latar}}>
      <AbsoluteFill
        style={{
          background:
            'radial-gradient(ellipse at 28% 50%, #1a2040 0%, #101426 60%, #0a0d1a 100%)',
        }}
      />
      <AbsoluteFill style={{opacity: pudar}}>
        <div
          style={{
            position: 'absolute',
            left: KIRI,
            top: 22,
            fontFamily: FONT,
            fontSize: 24,
            color: WARNA.redup,
            opacity: opLabel,
          }}
        >
          1 baris = 1 tahun (52 minggu)
        </div>

        <div style={{position: 'absolute', left: KIRI, top: ATAS, opacity: opKisi}}>
          <Kisi lapisan={lapisan}>
            <g opacity={tanda}>
              <circle
                cx={pos.x + JARAK / 2}
                cy={pos.y + JARAK / 2}
                r={8 + fase * 34}
                fill="none"
                stroke={WARNA.sekarang}
                strokeWidth={2}
                opacity={(1 - fase) * 0.8}
              />
              <rect
                x={pos.x + 1}
                y={pos.y + 1}
                width={SEL}
                height={SEL}
                rx={2}
                fill={WARNA.sekarang}
              />
            </g>
            {SAYANG.map((idx, k) => {
              const mulai = 65.3 + k * 0.1;
              const s = an(f, [mulai, mulai + 0.5], [0, 1], Easing.out(Easing.back(2.5)));
              if (s <= 0) return null;
              const denyut = f > detik(70) ? 1 + 0.12 * Math.sin(f / 7 + k) : 1;
              const p = posisiKotak(idx);
              return (
                <g
                  key={k}
                  transform={`translate(${p.x + JARAK / 2} ${p.y + JARAK / 2}) scale(${s * denyut})`}
                >
                  <circle r={16} fill={WARNA.sayang} opacity={0.2} />
                  <rect
                    x={-SEL / 2}
                    y={-SEL / 2}
                    width={SEL}
                    height={SEL}
                    rx={2}
                    fill={WARNA.sayang}
                  />
                </g>
              );
            })}
          </Kisi>
        </div>

        {/* 1. Pembuka */}
        <Grup tengah mulai={0.3} akhir={3.4}>
          <T u="besar">Anggap hidupmu 80 tahun.</T>
        </Grup>
        <Grup tengah mulai={3.6} akhir={7.9}>
          <T u="sedang" w="redup">Itu hanya sekitar</T>
          <Hitung ke={TOTAL} mulai={4.3} akhir={6.3} />
          <T u="besar">minggu.</T>
        </Grup>

        {/* 2. Kisi muncul */}
        <Grup mulai={9} akhir={13.5}>
          <T u="besar">Satu kotak</T>
          <T u="besar" w="emas">= satu minggu.</T>
        </Grup>
        <Grup mulai={14} akhir={20.5}>
          <T u="besar">Ini seluruh hidupmu.</T>
          <T u="sedang" w="redup">Dalam satu layar.</T>
        </Grup>

        {/* 3. Yang sudah berlalu */}
        <Grup mulai={21.2} akhir={26}>
          <T u="besar" w="anak">18 tahun pertama.</T>
          <T u="sedang" w="redup">Sekolah, bermain,</T>
          <T u="sedang" w="redup">belum banyak memilih.</T>
        </Grup>
        <Grup mulai={26.6} akhir={32}>
          <T u="sedang" w="redup">Sampai hari ini,</T>
          <Hitung ke={SEKARANG} mulai={27} akhir={29.4} w="dewasa" />
          <T u="sedang">minggu sudah berlalu.</T>
        </Grup>
        <Grup mulai={32.5} akhir={36}>
          <T u="besar">Kotak yang berkedip</T>
          <T u="besar">adalah minggu ini.</T>
        </Grup>
        <Grup mulai={36.3} akhir={41}>
          <T u="sedang" w="redup">Sisa kotak:</T>
          <Hitung ke={SISA} mulai={36.8} akhir={38.8} w="biru" />
          <T u="sedang">Masih banyak, kan?</T>
        </Grup>

        {/* 4. Dikurangi tidur */}
        <Grup mulai={41.5} akhir={46.5}>
          <T u="besar">Tapi sepertiganya</T>
          <T u="besar" w="tidur">untuk tidur.</T>
        </Grup>
        <Grup mulai={47} akhir={51}>
          <T u="sedang" w="redup">Sisa waktu terjaga:</T>
          <T u="besar" w="emas">sekitar {titik(TERJAGA)}</T>
          <T u="sedang">minggu.</T>
        </Grup>
        <Grup mulai={51.5} akhir={56}>
          <T u="sedang">Belum dikurangi macet,</T>
          <T u="sedang" w="redup">antre, dan scroll tanpa sadar.</T>
        </Grup>

        {/* 5. Orang yang disayang */}
        <Grup mulai={56.5} akhir={60.5}>
          <T u="sedang" w="redup">Sekarang bayangkan</T>
          <T u="besar">satu orang yang</T>
          <T u="besar" w="sayang">kamu sayang.</T>
        </Grup>
        <Grup mulai={61} akhir={64.8}>
          <T u="sedang" w="redup">Kamu hanya bisa bertemu dia</T>
          <T u="besar">10 hari</T>
          <T u="sedang" w="redup">dalam setahun.</T>
        </Grup>
        <Grup mulai={65} akhir={68.8}>
          <T u="sedang" w="redup">25 tahun ke depan</T>
          <T u="besar" w="sayang">= 250 hari.</T>
        </Grup>
        <Grup mulai={69.2} akhir={76}>
          <T u="sedang" w="redup">Itu kurang dari</T>
          <T u="raksasa" w="sayang">{JUMLAH_SAYANG}</T>
          <T u="besar">minggu.</T>
          <T u="sedang" w="redup">{JUMLAH_SAYANG} kotak, dari {titik(TOTAL)}.</T>
        </Grup>

        {/* 6. Harapan */}
        <Grup mulai={76.5} akhir={80.5}>
          <T u="sedang" w="redup">Tapi kotak minggu ini</T>
          <T u="besar" w="emas">belum terisi.</T>
        </Grup>
        <Grup mulai={81} akhir={88} jeda={24}>
          <T u="besar" w="emas">Masih milikmu.</T>
          <T u="sedang">Hubungi dia.</T>
          <T u="sedang">Mulai yang kamu tunda.</T>
          <T u="sedang">Istirahat tanpa rasa bersalah.</T>
        </Grup>

        {/* 7. Ajakan komentar */}
        <Grup mulai={88.5} akhir={92.5}>
          <T u="sedang" w="redup">Cara menghitungnya:</T>
          <T u="besar">umurmu × 52</T>
          <T u="sedang" w="redup">= minggumu sekarang.</T>
        </Grup>
        <Grup mulai={93} akhir={99} jeda={14}>
          <T u="besar">Kamu ada di minggu</T>
          <T u="besar" w="emas">ke berapa?</T>
          <T u="sedang">Tulis angkanya di komentar.</T>
          <T u="kecil" w="redup">Bagikan ke seseorang yang ingin kamu temui minggu ini.</T>
        </Grup>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
EOF

echo "== Memasang paket (perlu internet, bisa beberapa menit) =="
npm install --save-exact remotion @remotion/cli react@18.3.1 react-dom@18.3.1

echo ""
echo "== Selesai! =="
echo "Langkah berikutnya:"
echo "  1) npm run foto     (cek satu gambar dulu)"
echo "  2) npm run tes      (video pendek 5 detik)"
echo "  3) npm run render   (video penuh 100 detik)"

