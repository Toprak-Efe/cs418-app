<script setup lang="ts">
import { MediaPlayer, MediaPlayerClass, MediaPlayerSettingClass } from 'dashjs';
import { Ref, ref, onMounted } from 'vue';

// Parameter refs
const url: Ref<string> = ref("https://livesim2.dashif.org/livesim2/ato_10/testpic_2s/Manifest.mpd");
//const quality: Ref<number> = ref(0);
//const quality_names: string[] = ["Auto", "240p", "360p", "480p", "720p", "1080p"];
const player: Ref<MediaPlayerClass> = ref(MediaPlayer().create());

// Video element
onMounted(() => {
  const settings: MediaPlayerSettingClass = {
    streaming: {
      delay: {
        liveDelay: 3
      },
      abr: {
        autoSwitchBitrate: {
          video: true
        }
      }
    }
  }
  player.value.updateSettings(settings);
  const query: Element | null = document.querySelector('#dash');
  if (query) {
    player.value.initialize(<HTMLMediaElement>query, url.value, true);
  }
})

const trace10 = () => {
  player.value.seek(player.value.time() - 10);
}

const skip10 = () => {
  player.value.seek(player.value.time() + 10);
}

const updateURL = () => {
  player.value.attachSource(url.value);
}
</script>

<template>
  <div id="container">
    <video id="dash" controls></video>
    <div id="buttons">
      <div id="left">
        <button class="interactible" @click="trace10"><</button>
        <button class="interactible" @click="skip10">></button>
        <select id="quality">
          <option value="0">Auto</option>
          <option value="1">240p</option>
          <option value="2">360p</option>
          <option value="3">480p</option>
          <option value="4">720p</option>
          <option value="5">1080p</option>
        </select>
        <input class="interactible" v-model="url" v-on:change="updateURL" />
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
  top: 92%;
  left: 0%;
  padding-left: 0%;
  margin-left: 0%;
  padding-right: 0%;
  margin-right: 0%;
  display: flex;
  flex-grow: 0.8;
  justify-content: flex-start;
  align-items: center;
  gap: 1em;
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
  transition: 0.5s;
}

select:hover {
  background-color: rgba(59, 59, 59, 0.816);
  color: rgb(255, 255, 255);
  transition: 0.5s;
}

select:focus {
  background-color: rgba(59, 59, 59, 0.816);
  color: rgb(255, 255, 255);
  transition: 0.5s;
}

button {
  height: 2.5vh;
  width: 5vw;
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
</style>
