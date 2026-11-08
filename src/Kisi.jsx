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
