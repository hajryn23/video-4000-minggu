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
