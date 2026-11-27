<script setup lang="ts">
import { useData } from "vitepress";
const { frontmatter } = useData();
</script>

<template>
    <div v-if="frontmatter.sponsors !== false">
        <a href="https://www.buymeacoffee.com/alpondith" target="_blank">
            <img class="img" src="/graphics/advertisement/bmc.webp" alt="buy me a coffee" width="960" height="702" loading="lazy" decoding="async" />
        </a>
    </div>
</template>

<style>
.img {
    border: 1px solid #ddd;
}
</style>
