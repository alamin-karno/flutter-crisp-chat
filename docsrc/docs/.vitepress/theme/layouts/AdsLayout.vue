<!--.vitepress/theme/MyLayout.vue-->
<script setup>
import DefaultTheme from "vitepress/theme";
import { useData } from "vitepress";

import HomeSponsors from "@theme/components/HomeSponsors.vue";
import PubDevStats from "@theme/components/PubDevStats.vue";
import HomeAuthor from "@theme/components/HomeAuthor.vue";

const { Layout } = DefaultTheme;
const { frontmatter } = useData();
</script>

<template>
    <Layout>
        <!-- Show extra sections only on the home page -->
        <template #home-features-after>
            <template v-if="frontmatter.layout === 'home'">
                <PubDevStats />
                <HomeSponsors />
                <HomeAuthor />
            </template>
        </template>
    </Layout>
</template>
