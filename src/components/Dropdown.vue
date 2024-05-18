<template>
    <button @click="toggleDropdown">{{ selected.label }}</button>
    <div id="dcontainer">
      <ul v-if="isOpen" class="dropdown-menu">
        <li v-for="item in items" :key="item.id" @click="selectItem(item)">{{ item.label }}</li>
      </ul>
    </div>
</template>

<script setup lang="ts">
import { Ref, ref }from 'vue';

// Define props here
// Example: const prop1 = defineProps({ prop1: String });

const isOpen: Ref<boolean> = ref(false);
const items: { id: number; label: string }[] = [
  { id: 1, label: 'Auto' },
  { id: 2, label: '480p' },
  { id: 3, label: '720p' },
  { id: 4, label: '1080p' },
];
const selected: Ref<{ id: number; label: string }> = ref(items[0]);
  
function toggleDropdown() {
  isOpen.value = !isOpen.value;
}

function selectItem(item: { id: number; label: string }) {
  selected.value = item;
  isOpen.value = false;
}
</script>

<style scoped>
#dcontainer {
  position: inherit;
  top: 0%;
  left: 0%;
  width: calc(max(4em, 100%));
  font-size: x-large;
  display: inline-block;
}

.dropdown-menu {
  list-style-type: none;
  padding: 0;
  margin: 0;
  background-color: #f1f1f1;
  border: 1px solid #ccc;
  border-radius: 5px;
  width: calc(max(4em, 4vw));
  font-size: 0.6em;
}

.dropdown-menu li {
  cursor: pointer;
}

.dropdown-menu li:hover {
  background-color: #ddd;
}

button {
  padding: 0%;
  margin: 0%;
  border-radius: 0.2em;
  width: calc(max(5em, 5vw));
  height: calc(max(1em, 2vh));
  font-size: 0.5em;
  background-color: #4a4a4a;
  color: white;
  border: none;
  cursor: pointer;
}

</style>