<script setup lang="ts">
import TopBar from './components/TopBar.vue'
import DemodulatorPage from './components/DemodulatorPage.vue'
import { Ref, ref } from 'vue';

const pageMap: Map<String, any> = new Map([
  ['Video Feed', DemodulatorPage]
]);
const currentPage: Ref<String> = ref('Breakroom');

const changePage = (page: String): void => {
  currentPage.value = page;
}
</script>

<template>
  <TopBar :pages="Array.from(pageMap.keys())" @page-change="changePage"/>
  <component :is="pageMap.get(currentPage)"/>
</template>

<style>
TopBar {
  position: absolute;
  padding: 0%;
  margin: 0%;
}
</style>
