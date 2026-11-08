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
