import { defineConfig } from "vitepress";

export default defineConfig({
  title: 'Flutter Crisp Chat',
  description: 'Official documentation for the Flutter Crisp Chat plugin — Crisp live chat on Android, iOS, Web, and desktop.',
  base: "/flutter-crisp-chat/",
  lastUpdated: true,
  lang: 'en-US',
  cleanUrls: false,
  assetsDir: 'assets',

  markdown: {
    theme: {
      light: 'github-light',
      dark: 'github-dark',
    },
    languages: ['dart', 'yaml', 'json', 'bash', 'java', 'swift', 'kotlin', 'xml'],
    lineNumbers: true,
    linkify: true,
    anchors: {
      slugify(str) {
        return encodeURIComponent(str)
      }
    }
  },

  sitemap: {
    hostname: 'https://alamin-karno.github.io/flutter-crisp-chat/',
    transformItems: (items) => {
      return items.map((item) => ({
        ...item,
        lastmod: item.lastmod ? new Date(item.lastmod).toISOString() : undefined
      }))
    }
  },

  head: [
    // Favicon — `alt` is not a valid attribute on <link>
    ['link', { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/flutter-crisp-chat/graphics/logo.png' }],
    // Preconnect to origins used by the page (reduces TCP/TLS latency)
    ['link', { rel: 'preconnect', href: 'https://fonts.googleapis.com' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' }],
    ['link', { rel: 'preconnect', href: 'https://www.googletagmanager.com' }],
    // Google Fonts — loaded as a <link> instead of CSS @import to avoid render-blocking
    ['link', { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Google+Sans:wght@400;500;700&family=Roboto+Mono:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500;1,600;1,700&family=Roboto:wght@300;400;500;700&display=swap' }],
    // Google Analytics
    ['script', { async: '', src: 'https://www.googletagmanager.com/gtag/js?id=G-SWJLYZRT92' }],
    ['script', {}, `window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments)}gtag('js',new Date());gtag('config','G-SWJLYZRT92');`],
  ],

  transformPageData(pageData) {
    const base = 'https://alamin-karno.github.io/flutter-crisp-chat';
    const cleanPath = pageData.filePath.replace(/\.md$/, '').replace(/\/index$/, '/');
    const pageUrl = `${base}/${cleanPath}`.replace(/\/+$/, '/');
    const ogImage = `${base}/graphics/logo.png`;

    pageData.frontmatter.head ??= [];
    // Open Graph
    pageData.frontmatter.head.push(['meta', { property: 'og:locale', content: 'en_US' }]);
    pageData.frontmatter.head.push(['meta', { property: 'og:type', content: 'website' }]);
    pageData.frontmatter.head.push(['meta', { property: 'og:title', content: `${pageData.title} | Flutter Crisp Chat` }]);
    pageData.frontmatter.head.push(['meta', { property: 'og:description', content: pageData.description || '' }]);
    pageData.frontmatter.head.push(['meta', { property: 'og:image', content: ogImage }]);
    pageData.frontmatter.head.push(['meta', { property: 'og:image:width', content: '200' }]);
    pageData.frontmatter.head.push(['meta', { property: 'og:image:height', content: '200' }]);
    pageData.frontmatter.head.push(['meta', { property: 'og:image:alt', content: 'Flutter Crisp Chat logo' }]);
    pageData.frontmatter.head.push(['meta', { property: 'og:url', content: pageUrl }]);
    // Twitter / X Card
    pageData.frontmatter.head.push(['meta', { name: 'twitter:card', content: 'summary' }]);
    pageData.frontmatter.head.push(['meta', { name: 'twitter:site', content: '@alamin_karno' }]);
    pageData.frontmatter.head.push(['meta', { name: 'twitter:title', content: `${pageData.title} | Flutter Crisp Chat` }]);
    pageData.frontmatter.head.push(['meta', { name: 'twitter:description', content: pageData.description || '' }]);
    pageData.frontmatter.head.push(['meta', { name: 'twitter:image', content: ogImage }]);
    // Canonical URL
    pageData.frontmatter.head.push(['link', { rel: 'canonical', href: pageUrl }]);
    // JSON-LD structured data
    pageData.frontmatter.head.push(['script', { type: 'application/ld+json' }, JSON.stringify({
      '@context': 'https://schema.org',
      '@type': 'SoftwareApplication',
      name: 'Flutter Crisp Chat',
      description: 'Flutter plugin for Crisp live chat on Android, iOS, Web, macOS, Windows, and Linux.',
      url: 'https://alamin-karno.github.io/flutter-crisp-chat/',
      applicationCategory: 'DeveloperApplication',
      operatingSystem: 'Android, iOS, macOS, Windows, Linux, Web',
      author: { '@type': 'Person', name: 'Md. Al-Amin', url: 'https://github.com/alamin-karno' },
      license: 'https://github.com/alamin-karno/flutter-crisp-chat/blob/main/LICENSE',
      codeRepository: 'https://github.com/alamin-karno/flutter-crisp-chat',
    })]);
  },

  themeConfig: {
    siteTitle: 'Flutter Crisp Chat',
    logo: {
      src: '/graphics/logo.png',
      alt: 'Flutter Crisp Chat',
    },

    search: {
      provider: 'local',
      options: {
        miniSearch: {
          options: {},
          searchOptions: {
            fuzzy: 0.2,
            prefix: true,
            boost: { title: 4, text: 2, titles: 1 },
          },
        }
      }
    },

    editLink: {
      pattern: 'https://github.com/alamin-karno/flutter-crisp-chat/tree/main/docsrc/docs/:path',
      text: 'Edit this page on GitHub'
    },

    nav: [
      { text: 'Home', link: '/' },
      { text: 'Guide', link: '/getting_started/overview' },
      { text: 'API Reference', link: '/reference/api_documentation' },
      { text: 'Blog', link: '/blog/' },
      {
        text: 'Links',
        items: [
          { text: 'pub.dev', link: 'https://pub.dev/packages/crisp_chat' },
          { text: 'GitHub', link: 'https://github.com/alamin-karno/flutter-crisp-chat' },
          { text: 'Changelog', link: '/reference/changelog' },
          { text: 'Contributing', link: '/community/contributing' },
          { text: 'Support the Author', link: 'https://www.supportkori.com/alaminkarno' },
        ]
      },
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/alamin-karno/flutter-crisp-chat' },
      { icon: 'x', link: 'https://x.com/alamin_karno' },
      { icon: 'linkedin', link: 'https://www.linkedin.com/in/alaminkarno/' },
    ],

    sidebar: [
      {
        text: 'Getting Started',
        collapsed: false,
        items: [
          { text: 'Overview', link: '/getting_started/overview' },
          { text: 'Installation', link: '/getting_started/install' },
          { text: 'Platform Setup', link: '/getting_started/platform_setup' },
          { text: 'Supported Platforms', link: '/getting_started/supported_platforms' },
          { text: 'Quick Start', link: '/getting_started/quick_start' },
        ],
      },

      {
        text: 'Core Features',
        collapsed: false,
        items: [
          { text: 'Configuration', link: '/core_feature/configuration' },
          { text: 'iOS Features', link: '/core_feature/ios_features' },
          { text: 'User & Company', link: '/core_feature/user_and_company' },
          { text: 'Session Management', link: '/core_feature/session_management' },
          { text: 'Unread Messages', link: '/core_feature/unread_messages' },
          { text: 'Helpdesk / FAQ', link: '/core_feature/helpdesk' },
        ],
      },

      {
        text: 'Push Notifications',
        collapsed: false,
        items: [
          { text: 'Firebase Setup', link: '/notifications/firebase_setup' },
          { text: 'Android Notifications', link: '/notifications/android' },
          { text: 'iOS Notifications', link: '/notifications/ios' },
          { text: 'Notification Handling', link: '/notifications/handling' },
        ],
      },

      {
        text: 'Reference',
        collapsed: true,
        items: [
          { text: 'API Documentation', link: '/reference/api_documentation' },
          { text: 'Full Example', link: '/reference/examples' },
          { text: 'FAQ', link: '/reference/faq' },
          { text: 'Changelog', link: '/reference/changelog' },
        ],
      },

      {
        text: 'Blog',
        collapsed: true,
        items: [
          { text: 'All Posts', link: '/blog/' },
        ],
      },

      {
        text: 'Troubleshooting',
        collapsed: true,
        items: [
          { text: 'Common Issues', link: '/troubleshooting/common_issues' },
          { text: 'Platform-Specific', link: '/troubleshooting/platform_specific' },
        ],
      },

      {
        text: 'Community',
        collapsed: true,
        items: [
          { text: 'Contributing', link: '/community/contributing' },
          { text: 'Author & Maintainer', link: '/community/author' },
          { text: 'Support', link: '/community/support' },
        ],
      },
    ],

    footer: {
      message: 'Released under the <a href="https://github.com/alamin-karno/flutter-crisp-chat/blob/main/LICENSE">MIT License</a>.',
      copyright: 'Copyright © 2022-present <a href="https://github.com/alamin-karno">Md. Al-Amin</a>'
    },
  },
})