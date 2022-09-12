<template>
  <div id="app">
    <home-page/>
  </div>
</template>

<script>

import HomePage from './components/HomePage.vue'

export default {
  name: 'App',
  components: {
    'home-page' : HomePage
  }
}
</script>

<style>
</style>
