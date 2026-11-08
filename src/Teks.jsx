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
