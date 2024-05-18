<script setup lang="ts">
import { MediaPlayer, MediaPlayerClass, MediaPlayerSettingClass, BitrateInfo } from 'dashjs';
import { Ref, ref, onMounted } from 'vue';
import moment from 'moment';
import FFIcon from './FFIcon.vue'
import RFIcon from './RFIcon.vue'
import jsQR, { QRCode } from 'jsqr';

// Parameter refs
const url: Ref<String> = ref("http://localhost:8000/stream.mpd")
const quality: Ref<number> = ref(0)
const quality_types: Ref<String[]> = ref(['auto', '240p', '360p', '480p', '720p', '1080p'])
const latency_buffer: Ref<String[]> = ref([])
const moving_average: Ref<String> = ref("0")
const player: Ref<MediaPlayerClass> = ref(MediaPlayer().create())
const live_delay: Ref<String> = ref("0")
const buffer_len: Ref<String> = ref("0");
const qr_delay: Ref<String> = ref("0")

// Settings for livestreaming
const settings: MediaPlayerSettingClass = {
  streaming: {
    delay: {
      liveDelay: 0.5
    },
    abr: {
      additionalAbrRules: {
        insufficientBufferRule: true,
        switchHistoryRule: true,
        droppedFramesRule: true,
        abandonRequestsRule: false
      },
    },
    liveCatchup: {
      playbackRate: {
        min: -0.5,
        max: 0.5
      },
    }
  }
}

const fetchQualityNames = () => {
  quality_types.value.length = 0;
  quality_types.value.push('auto');
  player.value.getBitrateInfoListFor('video').forEach((bitrate: BitrateInfo) => {
    quality_types.value.push(String(bitrate.bitrate));
  });
}

const updateURL = () => {
  player.value.attachSource(url.value);
  fetchQualityNames();
}

// Video element
onMounted(() => {
  player.value.updateSettings(settings);
  const query: Element | null = document.querySelector('#dash');
  if (query) {
    player.value.initialize(<HTMLMediaElement>query, url.value, true);
    fetchQualityNames();
  }
  const div_time = document.getElementById('wall_time')
  if (div_time) {
    div_time.innerHTML = moment().format('HH:mm:ss')
  }
})

const trace10 = () => {
  player.value.seek(player.value.time() - 10);
}

const skip10 = () => {
  player.value.seek(player.value.time() + 10);
}

const bitrateApply = () => {
  if (!settings) {
    return;
  }
  if (!settings.streaming) {
    return;
  }
  if (!settings.streaming.abr) {
    return;
  }
  if (!settings.streaming.abr.autoSwitchBitrate) {
    return;
  }
  if (quality.value === 0) {
    settings.streaming.abr.autoSwitchBitrate.video = true
    player.value.updateSettings(settings)
    return
  }
  settings.streaming.abr.autoSwitchBitrate.video = false
  player.value.updateSettings(settings)
  player.value.setQualityFor('video', quality.value - 1)
}

const capture = () => {
  const query: Element | null = document.querySelector('#dash');
  if (query) {
    const canvas: HTMLCanvasElement | null = document.createElement('canvas');
    if (!canvas) {
      return;
    }
    canvas.width = query.clientWidth;
    canvas.height = query.clientHeight;
    const ctx: CanvasRenderingContext2D | null = canvas.getContext('2d');
    if (ctx) {
      ctx.drawImage(<HTMLVideoElement>query, 0, 0, canvas.width, canvas.height);
      const a: HTMLAnchorElement | null = document.createElement('a');
      if (!a) {
        return;
      }
      a.href = canvas.toDataURL('image/png');
      a.download = 'capture.png';
      a.click();
    }
  }
}

const runReallyFast = () => {
  const query: Element | null = document.querySelector('#dash');
  if (query) {
    const canvas: HTMLCanvasElement | null = document.createElement('canvas');
    if (!canvas) {
      return;
    }
    canvas.width = query.clientWidth;
    canvas.height = query.clientHeight;
    const ctx: CanvasRenderingContext2D | null = canvas.getContext('2d');
    if (ctx) {
      ctx.drawImage(<HTMLVideoElement>query, 0, 0, canvas.width, canvas.height);
      const imageData: ImageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
      const code: QRCode | null = jsQR(imageData.data, imageData.width, imageData.height);
      if (code) {
        qr_delay.value = ((moment().unix()*1000 - parseInt(code.data))/1000.0).toFixed(2)
      }
    }
  }
  buffer_len.value = player.value.getBufferLength('video').toFixed(2)
  live_delay.value = player.value.getCurrentLiveLatency().toFixed(2)
  if (latency_buffer.value.length < 20) {
    latency_buffer.value.push(qr_delay.value)
  } else {
    latency_buffer.value.shift()
    latency_buffer.value.push(qr_delay.value)
    moving_average.value = (latency_buffer.value.reduce((a, b) => a + parseFloat(b), 0) / latency_buffer.value.length).toFixed(2)
  }
}
setInterval(runReallyFast, 100)

const runEverySecond = () => {
  const div_time = document.getElementById('wall_time')
  if (div_time) {
    div_time.innerHTML = moment().format('HH:mm:ss')
  }
  fetchQualityNames()
}
setInterval(runEverySecond, 1000)
</script>

<template>
  <div id="container">
    <video id="dash" controls></video>
    <div id="buttons">
      <div id="left">
        <button class="interactible" @click="trace10"><RFIcon /></button>
        <button class="interactible" @click="skip10"><FFIcon /></button>
        <button class="interactible" @click="capture">Capture</button>
        <select id="quality" v-model="quality" v-on:change="bitrateApply">
          <option v-for="(name, index) in quality_types" :key="index" :value="index">{{ name }}</option>
        </select>
        <input class="interactible" v-model="url" @change="updateURL">
        <span id="wall_time"></span>
        <span id="qr_delay">{{ qr_delay }}s</span>
        <span id="moving_average">{{ moving_average }}s</span>
        <span id="live_delay">{{ live_delay }}s</span>
        <span id="buffer_len">{{ buffer_len }}s</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
#container {
  position: absolute;
  padding: 0%;
  margin: 0%;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  font-size: 2em;
  color: var(--highlight);
}

#buttons {
  position: absolute;
  top: 0%;
  left: 0%;
  padding-left: 0%;
  margin-left: 0%;
  padding-right: 0%;
  margin-right: 0%;
  display: flex;
  justify-content: flex-start;
  align-items: center;
  gap: 1em;
}

#live_delay {
  padding-right: 0%;
  margin-right: 0%;
  font-size: 0.5em;
}

#qr_delay {
  padding-right: 0%;
  margin-right: 0%;
  font-size: 0.5em;
  color: red;
}

#moving_average {
  padding-right: 0%;
  margin-right: 0%;
  font-size: 0.5em;
  color: rgb(252, 128, 128);
}

#left button {
  margin: 0.2em;
}

input {
  width: 20vw;
  height: 2vh;
  border-radius: 0.6em;
  font-size: 0.35em;
  border: 0cap;
  background-color: rgba(194, 194, 194, 0.059);
  color: rgba(240, 248, 255, 0.312);
  transition: 0.5s;
}

input::selection {
  background-color: rgba(0, 72, 255, 0.371);
  color: var(--background);
}

input:focus  {
  transition: 0.5s;
  color: aliceblue;
  background-color: rgba(43, 43, 43, 0.598);
  border: 1px solid;
  outline: none;
}

select {
  width: 4vw;
  font-size: 5%em;  
  height: 2.5vh;
  margin: 0.2em;
  background-color: rgba(59, 59, 59, 0.235);
  border-radius: 0.5em;
  border: 1px solid rgba(134, 134, 134, 0.186);
  color: rgb(166, 166, 166);
}

button {
  height: 2.5vh;
  width: 2.5vw;
  border-radius: 0.15em;
  border: 0px solid var(--highlight);
  background-color: rgba(78, 78, 78, 0.219);
  box-shadow: 0px 1px 0.2em 0.1em rgba(0, 0, 0, 0.233);
  color: aliceblue;
  transition: 0.5s;
}

button:hover {
  background-color: rgba(39, 39, 39, 0.73);
  color: rgb(194, 194, 194);
}

interactible {
  background-color: var(--highlight);
  color: var(--background);
  border: none;
  padding: 0.5em 1em;
  margin: 0.5em 0em;
  font-size: 1em;
  cursor: pointer;
}

video {
  position: absolute;
  height: 100vh;
  width: 100vw;
  flex-grow: 0.8;
  background-color: black;
  margin-bottom: 0%;
  padding-bottom: 0%;
}

span {
  font-size: 0.5em;
  padding-left: 0.5em;
}
</style>
