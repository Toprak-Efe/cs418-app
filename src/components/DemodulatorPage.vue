<script setup lang="ts">
import { onMounted, Ref, ref } from 'vue';
import { ssim } from 'ssim.js';
import { MediaPlayer, MediaPlayerClass, MediaPlayerSettingClass } from 'dashjs';

const url_base: string = 'https://10.200.89.196/dash/webcam_';
const res_sfix: string[] = ['l', 'm', 'h'];
const delay: Ref = ref(0);
const buffer: Ref = ref(0);
var quality_changed: boolean = false;
var prev_img: ImageData = new ImageData(1, 1);
const adaptation: Ref<boolean> = ref(false);
const motion_alert: Ref<boolean> = ref(false);

onMounted(() => {
  let url: string = url_base.concat(res_sfix[0]).concat('.mpd');
  const player: MediaPlayerClass = MediaPlayer().create();
  const settings: MediaPlayerSettingClass = {
    streaming: {
      cacheInitSegments: true,
      cacheLoadThresholds: {
        video: 0,
        audio: 0
      },
      buffer: {
        bufferTimeAtTopQuality: 30,
        bufferTimeAtTopQualityLongForm: 60,
        stableBufferTime: 12,
        longFormContentDurationThreshold: 600,
        mediaSourceDurationInfinity: true
      },
      delay: {
        liveDelay: 3
      },
      liveCatchup: {
        enabled: true,
        maxDrift: 0.0,
        playbackRate: {
          min: -0.4,
          max: 0.0
        },        
        mode: 'liveCatchupModeDefault'
      },
      gaps: {
        enableSeekFix: true,
        enableStallFix: true
      },
    }
  };
  player.updateSettings(settings);
  const query: Element | null = document.querySelector('#player');
  if (query) {
    player.initialize(<HTMLMediaElement>query, url, true);
  }

  setInterval(() => {
    const d = new Date();
    delay.value = Math.round((d.getTime() / 1000) - Number(player.timeAsUTC()));;
    const buffer_candidate: Number = player.getBufferLength('video');
    buffer.value = Number.isNaN(buffer_candidate) ? 0 : buffer_candidate;
  }, 50);

  setInterval(() => {
    const canvas: HTMLCanvasElement = document.createElement('canvas');
    const ctx_or_null: CanvasRenderingContext2D | null = canvas.getContext('2d');
    if (ctx_or_null === null) {
      return;
    }
    const ctx: CanvasRenderingContext2D = ctx_or_null;
    const video: HTMLVideoElement = <HTMLVideoElement>document.querySelector('#player');
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
    const img: ImageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    if (prev_img.width === img.width && prev_img.height === img.height) {
      if (!quality_changed && motion_alert.value) {
        const ssim_val = ssim(prev_img, img).mssim;
        console.log("Current SSIM value, threshold for motion is 0.5: ", ssim_val)
        if (ssim_val < 0.5) {
          window.alert('Video feed experienced temporal gradience, motion detected!');
        }
      }
    }
    prev_img = img;

    if (adaptation.value) {
      quality_changed = false;
      const bitrate: number = player.getAverageThroughput('video');
      console.log("Current bitrate throughput: bitrate");
      if (bitrate < 30000 && player.getSource() !== url_base.concat(res_sfix[0]).concat('.mpd')) {
        player.attachSource(url_base.concat(res_sfix[0]).concat('.mpd'));
        quality_changed = true;
      }
      if (bitrate < 50000 && player.getSource() !== url_base.concat(res_sfix[1]).concat('.mpd')) {
        player.attachSource(url_base.concat(res_sfix[1]).concat('.mpd'));
        quality_changed = true;
      }
      if (bitrate > 70000 && player.getSource() !== url_base.concat(res_sfix[2]).concat('.mpd')) {
        player.attachSource(url_base.concat(res_sfix[2]).concat('.mpd'));
        quality_changed = true;
      }
    }
  }, 500);
});

const save_current_frame = () => {
  const canvas: HTMLCanvasElement = document.createElement('canvas');
  const ctx_or_null: CanvasRenderingContext2D | null = canvas.getContext('2d');
  if (ctx_or_null === null) {
    return;
  }
  const ctx: CanvasRenderingContext2D = ctx_or_null;
  const video: HTMLVideoElement = <HTMLVideoElement>document.querySelector('#player');
  canvas.width = video.videoWidth;
  canvas.height = video.videoHeight;
  ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
  const a: HTMLAnchorElement = document.createElement('a');
  a.href = canvas.toDataURL('image/png');
  a.download = 'screenshot.png';
  a.click();
}
</script>

<template>
  <div id="container">
    <video id="player" controls></video>
    <div>
      <div id="delay">
        Live Delay: {{ delay }}
        <progress :value="delay" min="0" max="10"></progress>
      </div>
      <div id="buffer">
        Buffer Length: {{ buffer }}
        <progress :value="buffer" max="6"></progress>
      </div> 
      <div id="choices">
        <div>
          <input type="checkbox" v-model="adaptation">Adaptation</input>
        </div>
        <div>
          <input type="checkbox" v-model="motion_alert">Motion Alert</input>
        </div>
        <div>
          <button @click="save_current_frame">Screenshot</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
#container {
  display: flex;
  flex-direction: column;
  justify-content: space-evenly;
  align-items: center;
  height: 90vh;
  color: var(--highlight);
}

#player {
  width: min(95vw, 95vh);
  height: 50vh;
}

#delay {
  display: flex;
  flex-direction: column;
  justify-content: space-evenly;
  align-items: center;
  width: 95vw;
  height: 5vh;
}


#delay progress {
  width: 50vw;
  height: 1vh;
  background-color: var(--highlight);
  color: var(--background);
}

#buffer {
  display: flex;
  flex-direction: column;
  justify-content: space-evenly;
  align-items: center;
  width: 95vw;
  height: 5vh;
}

#buffer progress {
  width: 50vw;
  height: 1vh;
  background-color: var(--highlight);
  color: var(--background);
}

#choices {
  display: flex;
  flex-direction: row;
  justify-content: space-evenly;
  align-items: center;
  width: 95vw;
  height: 5vh;
}
</style>