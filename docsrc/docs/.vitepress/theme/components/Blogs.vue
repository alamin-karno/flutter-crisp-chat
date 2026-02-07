<script setup>

import blogsJson from "@theme/data/blogs.json";

const blogs = blogsJson.blogs ?? [];

</script>

<template>
  <div class="blog-page">
    <div class="header">
      <h1 class="title">Flutter Crisp Chat Blog</h1>
      <p class="subtitle">Updates, deep dives, and practical guides for building better in-app support.</p>
    </div>

    <div v-if="blogs.length === 0" class="empty">
      <p>No blog posts yet.</p>
    </div>

    <div v-else class="grid">
      <a
        v-for="blog in blogs"
        :key="blog.id"
        class="card"
        :href="blog.url"
        target="_blank"
        rel="noreferrer"
      >
        <div class="thumb" v-if="blog.thumbnail">
          <img class="thumbImg" :src="blog.thumbnail" :alt="blog.title" loading="lazy" />
          <div class="thumbOverlay" aria-hidden="true"></div>
        </div>

        <div class="content">
          <div class="meta">
            <span v-if="blog.date" class="date">{{ blog.date }}</span>
            <span v-if="blog.readTime" class="dot">·</span>
            <span v-if="blog.readTime" class="readTime">{{ blog.readTime }}</span>
          </div>

          <h2 class="cardTitle">{{ blog.title }}</h2>
          <p v-if="blog.description" class="desc">{{ blog.description }}</p>

          <div class="footer">
            <span v-if="blog.author" class="author">By {{ blog.author }}</span>

            <div v-if="blog.tags && blog.tags.length" class="tags">
              <span v-for="tag in blog.tags" :key="tag" class="tag">{{ tag }}</span>
            </div>
          </div>

          <div class="ctaRow">
            <span class="cta">
              Read full blog
              <span class="ctaArrow" aria-hidden="true">→</span>
            </span>
          </div>
        </div>
      </a>
    </div>
  </div>
</template>

<style scoped>
.blog-page {
  max-width: 1160px;
  margin: 0 auto;
  padding: 40px 16px 80px;
}

.header {
  text-align: center;
  margin-top: 16px;
  margin-bottom: 34px;
}

.title {
  font-size: clamp(2.2rem, 3.2vw, 3.4rem);
  font-weight: 900;
  margin: 0;
  line-height: 1.05;
  letter-spacing: -0.02em;
  background: linear-gradient(90deg, var(--vp-c-brand-1), var(--vp-c-brand-2));
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

.subtitle {
  margin: 14px auto 0;
  color: var(--vp-c-text-2);
  max-width: 780px;
  font-size: 1.05rem;
  line-height: 1.7;
}

.dark .date {
    color: #ffffff;
}

.dark .dot {
    color: #ffffff;
}

.dark .readTime {
    color: #ffffff;
}

.empty {
  text-align: center;
  color: var(--vp-c-text-2);
  padding: 60px 0;
}

.grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 18px;
}

.card {
  display: block;
  border: 1px solid var(--vp-c-divider);
  border-radius: 14px;
  overflow: hidden;
  text-decoration: none;
  background: linear-gradient(180deg, var(--vp-c-bg-soft) 0%, var(--vp-c-bg) 100%);
  transition: transform 0.22s ease, border-color 0.22s ease, box-shadow 0.22s ease;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.06);
}

.card:hover {
  transform: translateY(-6px);
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 18px 50px rgba(0, 0, 0, 0.12);
}

.dark .card {
    background: #1a1a1a;
    border-color: rgba(255, 255, 255, 0.1);
}

.dark .card:hover {
    border-color: #4DA8FF;
    box-shadow: 0 4px 20px rgba(77, 168, 255, 0.12);
}

.thumb {
  width: 100%;
  height: 190px;
  background: var(--vp-c-bg-alt);
  position: relative;
  overflow: hidden;
}

.thumbImg {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  transform: scale(1.001);
  transition: transform 0.35s ease;
}

.thumbOverlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(0, 0, 0, 0.05), rgba(0, 0, 0, 0.22));
  opacity: 0.6;
  transition: opacity 0.25s ease;
}

.card:hover .thumbImg {
  transform: scale(1.06);
}

.card:hover .thumbOverlay {
  opacity: 0.75;
}

.content {
  padding: 16px 16px 18px;
}

.meta {
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
  margin-bottom: 8px;
}

.dot {
  margin: 0 8px;
}

.cardTitle {
  margin: 0 0 10px;
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--vp-c-text-1);
  line-height: 1.35;
}

.desc {
  margin: 0;
  color: var(--vp-c-text-2);
  line-height: 1.6;
  display: -webkit-box;
  line-clamp: 2;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.footer {
  margin-top: 14px;
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}

.author {
  color: var(--vp-c-text-2);
  font-size: 0.95rem;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag {
  font-size: 0.8rem;
  padding: 4px 10px;
  border-radius: 999px;
  border: 1px solid var(--vp-c-divider);
  color: var(--vp-c-text-2);
  background: var(--vp-c-bg);
}

.ctaRow {
  margin-top: 16px;
  display: flex;
  justify-content: flex-start;
}

.cta {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 10px 14px;
  border-radius: 10px;
  background: var(--vp-c-brand-1);
  color: white;
  font-weight: 700;
  font-size: 0.95rem;
  transition: transform 0.2s ease, background 0.2s ease;
}

.ctaArrow {
  transition: transform 0.2s ease;
}

.card:hover .cta {
  transform: translateY(-1px);
  background: var(--vp-c-brand-2);
}

.card:hover .ctaArrow {
  transform: translateX(2px);
}

/* Dark mode text contrast fixes */
:global(.dark) .cardTitle {
  color: #ffffff;
}

:global(.dark) .desc {
  color: rgba(255, 255, 255, 0.7);
}

:global(.dark) .meta,
:global(.dark) .author {
  color: rgba(255, 255, 255, 0.6);
}

:global(.dark) .tag {
  color: rgba(255, 255, 255, 0.65);
  background: rgba(255, 255, 255, 0.08);
  border-color: rgba(255, 255, 255, 0.15);
}

@media (min-width: 768px) {
  .grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .thumb {
    height: 200px;
  }
}
</style>
