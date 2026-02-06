import { defineConfig } from "vitepress";

export default defineConfig({
  title: 'Flutter Crisp Chat',
  description: 'Official documentation for the Flutter Crisp Chat plugin — integrate Crisp live chat natively on Android & iOS.',
  base: "/flutter-crisp-chat/",
  lastUpdated: true,
  lang: 'en-US',
  cleanUrls: false,
  assetsDir: 'assets',

  markdown: {
    theme: {
      light: 'min-light',
      dark: 'material-theme-palenight',
    },
    lineNumbers: true,
    linkify: true,
    anchors: {
      slugify(str) {
        return encodeURIComponent(str)
      }
    }
  },

  sitemap: {
    hostname: 'https://alamin-karno.github.io/flutter-crisp-chat/'
  },

  head: [
    ['link', { rel: "icon", type: "image/png", sizes: "16x16", href: "/flutter-crisp-chat/graphics/logo.png", alt: "logo" }],
  ],

  transformPageData(pageData) {
    let url = 'https://alamin-karno.github.io/flutter-crisp-chat';
    pageData.frontmatter.head ??= []
    pageData.frontmatter.head.push(['meta', { property: 'og:locale', content: 'en_US' }])
    pageData.frontmatter.head.push(['meta', { property: 'og:type', content: 'website' }])
    pageData.frontmatter.head.push(['meta', { property: 'og:title', content: `${pageData.title} | Flutter Crisp Chat` }])
    pageData.frontmatter.head.push(['meta', { property: 'og:description', content: `${pageData.description}` }])
    pageData.frontmatter.head.push(['meta', { property: 'og:image', content: `${url}/graphics/logo.png` }])
    pageData.frontmatter.head.push(['meta', { property: 'og:url', content: `${url}/${pageData.filePath.replace(".md", ".html")}` }])
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
      { icon: 'linkedin', link: 'https://www.linkedin.com/in/alaborkarno/' },
    ],

    sidebar: [
      {
        text: 'Getting Started',
        collapsed: false,
        items: [
          { text: 'Overview', link: '/getting_started/overview' },
          { text: 'Installation', link: '/getting_started/install' },
          { text: 'Platform Setup', link: '/getting_started/platform_setup' },
          { text: 'Quick Start', link: '/getting_started/quick_start' },
        ],
      },

      {
        text: 'Core Features',
        collapsed: false,
        items: [
          { text: 'Configuration', link: '/core_feature/configuration' },
          { text: 'User & Company', link: '/core_feature/user_and_company' },
          { text: 'Session Management', link: '/core_feature/session_management' },
          { text: 'Unread Messages', link: '/core_feature/unread_messages' },
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