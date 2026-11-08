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
