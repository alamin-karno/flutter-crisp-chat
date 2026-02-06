<script setup>
import sponsorsJson from "@theme/data/sponsor.json";

const sponsors = [...sponsorsJson.platinum, ...sponsorsJson.average];
</script>

<template>
    <div class="sponsor-section">
        <h2>Sponsors</h2>
        <p class="subtitle">Support the development of Flutter Crisp Chat</p>

        <div class="sponsor-grid">
            <template v-if="sponsors.length > 0">
                <a
                    v-for="sponsor in sponsors"
                    :key="sponsor.name"
                    :href="sponsor.link"
                    target="_blank"
                    class="sponsor-card"
                >
                    <img :src="sponsor.image" :alt="sponsor.name" />
                    <span>{{ sponsor.name }}</span>
                </a>
            </template>
            <div v-else class="sponsor-empty">
                <div>
                    <p style="font-size: 2rem; margin-bottom: 0.5rem;">💙</p>
                    <p>Your logo could be here!</p>
                    <p style="font-size: 0.85rem; margin-top: 0.25rem;">Become the first sponsor of Flutter Crisp Chat</p>
                </div>
            </div>
        </div>

        <a
            href="https://www.supportkori.com/alaminkarno"
            target="_blank"
            class="sponsor-btn"
        >
            ❤️ Sponsor This Project
        </a>
    </div>

    <div class="powered-by">
        <h3>Powered By</h3>
        <div class="logos">
            <a href="https://flutter.dev" target="_blank" title="Flutter">
                <img src="https://tse3.mm.bing.net/th/id/OIP.hGnjnxryKnKZW9AJ_3ErvQHaFf?rs=1&pid=ImgDetMain&o=7&rm=3" alt="Flutter" style="height: 32px;" />
            </a>
            <a href="https://crisp.chat" target="_blank" title="Crisp">
                <img src="https://uploads-ssl.webflow.com/5fcdef3cc7cf1d1e14b4ba0c/5fef34e1b64093d0aec1d091_crisp-chat.png" alt="Crisp" style="height: 32px;" />
            </a>
            <a href="https://firebase.google.com" target="_blank" title="Firebase">
                <img src="https://th.bing.com/th/id/R.1422944bd0e2453d6a2588f7ee305e6c?rik=DCQBmrX16yn13A&riu=http%3a%2f%2fblogs.powercode.id%2fwp-content%2fuploads%2f2022%2f09%2ffirebase3.png&ehk=WNZyhzq%2bgco2pRc50QvTZSxVcXufW2%2f29KPZ5Z6S26A%3d&risl=&pid=ImgRaw&r=0" alt="Firebase" style="height: 32px;" />
            </a>
        </div>
    </div>
</template>

<style scoped>
.sponsor-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 1.25rem;
    border: 1px solid var(--vp-c-divider);
    border-radius: 12px;
    background: var(--vp-c-bg-soft);
    min-width: 160px;
    transition: all 0.3s ease;
    text-decoration: none;
    color: var(--vp-c-text-1);
}

.sponsor-card:hover {
    border-color: var(--vp-c-brand-1);
    box-shadow: 0 4px 16px rgba(2, 125, 253, 0.1);
    transform: translateY(-2px);
}

.sponsor-card img {
    max-height: 48px;
    max-width: 120px;
    margin-bottom: 0.5rem;
}

.sponsor-card span {
    font-size: 0.85rem;
    font-weight: 500;
}
</style>
