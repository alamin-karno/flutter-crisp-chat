<script setup>
import { withBase } from 'vitepress'

function goAuthor() {
    window.location.href = withBase('/community/author')
}
</script>

<template>
    <div class="ha-wrap">
        <div class="ha-card" @click="goAuthor">
            <!-- Left: avatar + identity -->
            <div class="ha-left">
                <img
                    src="https://avatars.githubusercontent.com/u/56608168?v=4"
                    alt="Md. Al-Amin"
                    class="ha-avatar"
                />
                <div class="ha-identity">
                    <span class="ha-name">Md. Al-Amin</span>
                    <span class="ha-role">Creator &amp; Maintainer</span>
                </div>
            </div>

            <!-- Center: about text -->
            <div class="ha-center">
                <p class="ha-about">Passionate software engineer and Flutter developer from Dhaka, Bangladesh. Building high-quality mobile apps and open-source plugins at Vivasoft Limited.</p>
            </div>

            <!-- Right: action buttons -->
            <div class="ha-right" @click.stop>
                <a href="https://www.fiverr.com/s/kLEWZzQ" target="_blank" class="ha-btn ha-fiverr">
                    <svg width="16" height="16" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <circle cx="12" cy="12" r="12" fill="#ffffff"/>
                      <path d="M9.4 16V10.2H8V8.6h1.4V7.9c0-1.9 1.1-2.9 2.9-2.9.7 0 1.3.1 1.6.2v1.7h-1c-.8 0-1 .4-1 1v.7h2l-.3 1.6h-1.7V16H9.4z"
                            fill="#1DBF73"/>
                    </svg>
                    <span>Hire Me</span>
                </a>
                <a href="https://github.com/alamin-karno" target="_blank" class="ha-btn ha-github">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z"/></svg>
                    <span>GitHub</span>
                </a>
                <a href="https://www.linkedin.com/in/alaminkarno/" target="_blank" class="ha-btn ha-linkedin">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433a2.062 2.062 0 0 1-2.063-2.065 2.064 2.064 0 1 1 2.063 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/></svg>
                    <span>LinkedIn</span>
                </a>
            </div>
        </div>
    </div>
</template>

<style scoped>
.ha-wrap {
    max-width: 960px;
    margin: 1rem auto 3rem;
    padding: 0 1.5rem;
}

.ha-card {
    display: flex;
    align-items: center;
    gap: 1.5rem;
    padding: 1.25rem 1.75rem;
    border: 1px solid var(--vp-c-divider);
    border-radius: 16px;
    background: var(--vp-c-bg-soft);
    overflow: hidden;
    cursor: pointer;
    transition: all 0.3s ease;
}

.ha-card:hover {
    border-color: var(--vp-c-brand-1);
    box-shadow: 0 4px 20px rgba(2, 125, 253, 0.08);
    transform: translateY(-2px);
}

/* Left: avatar + identity */
.ha-left {
    display: flex;
    align-items: center;
    gap: 0.875rem;
    flex-shrink: 0;
}

.ha-avatar {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    border: 2px solid var(--vp-c-brand-1);
    box-shadow: 0 2px 8px rgba(2, 125, 253, 0.15);
}

.ha-identity {
    display: flex;
    flex-direction: column;
}

.ha-name {
    font-size: 0.95rem;
    font-weight: 700;
    color: var(--vp-c-text-1);
    line-height: 1.2;
}

.ha-role {
    font-size: 0.75rem;
    color: var(--vp-c-text-3);
    font-weight: 500;
    margin-top: 0.15rem;
}

/* Center: about text */
.ha-center {
    flex: 1;
    min-width: 0;
    padding: 0 0.5rem;
}

.ha-about {
    font-size: 0.85rem;
    color: var(--vp-c-text-2);
    line-height: 1.45;
    margin: 0;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

/* Right: action buttons */
.ha-right {
    display: flex;
    align-items: center;
    gap: 0.625rem;
    flex-shrink: 0;
}

.ha-btn {
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    padding: 0.5rem 1rem;
    border-radius: 10px;
    font-size: 0.8rem;
    font-weight: 600;
    text-decoration: none !important;
    white-space: nowrap;
    transition: all 0.3s ease;
    position: relative;
    overflow: hidden;
}

.ha-btn::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    border-radius: inherit;
    opacity: 0;
    transition: opacity 0.3s ease;
}

/* Fiverr button */
.ha-fiverr {
    background: linear-gradient(135deg, #1DBF73, #19a463);
    color: #fff;
    border: none;
    box-shadow: 0 2px 12px rgba(29, 191, 115, 0.25);
}

.ha-fiverr::before {
    background: linear-gradient(135deg, rgba(255,255,255,0.2), rgba(255,255,255,0.1));
}

.ha-fiverr:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 20px rgba(29, 191, 115, 0.35);
}

.ha-fiverr:hover::before {
    opacity: 1;
}

.ha-fiverr:active {
    transform: translateY(0);
}

/* GitHub button */
.ha-github {
    background: #24292e;
    color: #fff;
    border: none;
    box-shadow: 0 2px 12px rgba(36, 41, 46, 0.25);
}

.ha-github::before {
    background: linear-gradient(135deg, rgba(255,255,255,0.15), rgba(255,255,255,0.05));
}

.ha-github:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 20px rgba(36, 41, 46, 0.35);
}

.ha-github:hover::before {
    opacity: 1;
}

/* LinkedIn button */
.ha-linkedin {
    background: #0A66C2;
    color: #fff;
    border: none;
    box-shadow: 0 2px 12px rgba(10, 102, 194, 0.25);
}

.ha-linkedin::before {
    background: linear-gradient(135deg, rgba(255,255,255,0.2), rgba(255,255,255,0.1));
}

.ha-linkedin:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 20px rgba(10, 102, 194, 0.35);
}

.ha-linkedin:hover::before {
    opacity: 1;
}

/* Logo styling */
.ha-logo {
    width: 16px;
    height: 16px;
    filter: brightness(0) invert(1);
}

.ha-btn svg {
    flex-shrink: 0;
}

/* Dark theme adjustments */
.dark .ha-card {
    background: #1a1a1a;
    border-color: rgba(255, 255, 255, 0.1);
}

.dark .ha-card:hover {
    border-color: #4DA8FF;
    box-shadow: 0 4px 20px rgba(77, 168, 255, 0.12);
}

.dark .ha-name {
    color: #ffffff;
}

.dark .ha-role {
    color: #b3b3b3;
}

.dark .ha-about {
    color: #e5e7eb;
}

.dark .ha-avatar {
    border-color: #4DA8FF;
    box-shadow: 0 2px 8px rgba(77, 168, 255, 0.25);
}

/* Responsive */
@media (max-width: 768px) {
    .ha-card {
        flex-direction: column;
        text-align: center;
        padding: 1.5rem;
        gap: 1rem;
    }

    .ha-left {
        flex-direction: column;
        gap: 0.625rem;
    }

    .ha-identity {
        align-items: center;
    }

    .ha-center {
        padding: 0;
    }

    .ha-right {
        flex-wrap: wrap;
        justify-content: center;
        gap: 0.5rem;
    }

    .ha-btn {
        flex: 1;
        min-width: 120px;
        justify-content: center;
    }
}

@media (max-width: 480px) {
    .ha-right {
        flex-direction: column;
        width: 100%;
    }

    .ha-btn {
        width: 100%;
        justify-content: center;
    }
}
</style>
