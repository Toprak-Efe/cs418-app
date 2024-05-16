<script setup lang="ts">
import { Ref, ref } from 'vue';

defineProps({
  pages: Array<String>
})
const emit: any = defineEmits([
  'page-change'
]);

const currentPage: Ref<String> = ref("Breakroom");

const pageChange = (page: String) => {
  currentPage.value = page;
  emit('page-change', page);
}
</script>

<template>
<div class="topbar">
  <div v-for="page in pages" @click="pageChange(page)" :class="{ 'hyperref': true, 'selected': currentPage === page }">
    <div>{{ page }}</div>
  </div>
</div>
</template>

<style scoped>
.topbar {
  display: flex;
  flex-direction: row;
  justify-content: space-around;
  align-items: center;
  background-color: var(--secondary);
  height: 10vh;
  width: 100vw;
}

.hyperref {
  padding: 0 min(4em, 5) 0em min(4em, 5);
  font-size: 1.5em;
  user-select: none;
  transition: color 0.3s;
}

.selected {
  color: var(--highlight);
}
</style>