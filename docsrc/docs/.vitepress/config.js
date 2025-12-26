import { defineConfig } from "vitepress";

export default defineConfig({
  title: 'Crisp',
  description: 'Crisp Documentation',
  base: "/flutter-crisp-chat/",
  lastUpdated: true,
  lang: 'en-US',
  // Clean URLs are prettier, but they require server config and dedicated 404 page. 
  // So keep it false.
  cleanUrls: false,
  assetsDir: 'assets',

  markdown: {
    // Choose theme from here : node_modules/shiki/themes. 
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
    hostname: 'https://github.com/alamin-karno/flutter-crisp-chat'
  },

  head: [
    // html head icon or favicon set up
    ['link', { rel: "icon", type: "image/png", sizes: "16x16", href: "/graphics/logo.png", alt: "logo" }],

    // Google Analytics
    // ['script', { async: '', src: "https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXX" }],
    // ['script',
    //   {},
    //   `window.dataLayer = window.dataLayer || [];
    //   function gtag(){dataLayer.push(arguments);}
    //   gtag('js', new Date());
    //   gtag('config', 'G-XXXXXXXX');`
    // ],

  ],

  // Set up the open graph meta tags for better SEO
  transformPageData(pageData) {
    let url = 'https://get-storage.tabpole.dev';
    pageData.frontmatter.head ??= []
    pageData.frontmatter.head.push(['meta', { property: 'og:locale', content: 'en_US' }])
    pageData.frontmatter.head.push(['meta', { property: 'og:type', content: 'website' }])
    pageData.frontmatter.head.push(['meta', { property: 'og:title', content: `${pageData.title} | ${this.site.title}` }])
    pageData.frontmatter.head.push(['meta', { property: 'og:description', content: `${pageData.description}` }])
    pageData.frontmatter.head.push(['meta', { property: 'og:image', content: `${url}/graphics/logo.png` }])
    pageData.frontmatter.head.push(['meta', { property: 'og:url', content: `${url}/${pageData.filePath.replace(".md", ".html")}` }])
  },

  themeConfig: {
    siteTitle: 'Crisp Chat',
    logo: {
      src: '/graphics/logo.png',
      alt: 'logo',
    },

    // search: {
    //   provider: 'algolia',
    //   options: {
    //     appId: 'XXXXXXXXXXXXXXX',
    //     apiKey: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    //     indexName: 'XXXXXXXXXXXXXX'
    //   }
    // },

    // local search
    // search: {
    //   provider: 'local',
    //   options: {
    //     miniSearch: {
    //       options: {},
    //       searchOptions: {
    //         fuzzy: 0.2,
    //         prefix: true,
    //         boost: { title: 4, text: 2, titles: 1 },
    //       },
    //     }
    //   }
    // },

    editLink: {
      pattern: 'https://github.com/alamin-karno/flutter-crisp-chat/tree/main/docsrc/docs/:path',
      text: 'Edit this page on GitHub'
    },

    // Navigation Section
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Documentation', link: '/getting_started/overview.md' },
      { text: 'About', link: 'https://github.com/alamin-karno/flutter-crisp-chat' },
      { text: 'Support', link: 'https://www.buymeacoffee.com/XXXXXXXX' },
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/alamin-karno/flutter-crisp-chat' },
      { icon: 'twitter', link: 'https://x.com/alamin_karno' },
    ],

    // Sidebar Section
    sidebar: [
      {
        text: 'Getting Started',
        collapsed: false,
        items: [
          { text: 'Overview', link: '/getting_started/overview.md' },
          { text: 'About', link: '/getting_started/about.md' },
          { text: 'Benchmark', link: '/getting_started/benchmark.md' },
          { text: 'Install', link: '/getting_started/install.md' },
          { text: 'Uninstall', link: '/getting_started/uninstall.md' },
        ],
      },

      {
        text: 'Core Features',
        collapsed: true,
        items: [
          { text: 'Initialize', link: '/core_feature/initialize.md' },
          { text: 'Send Message', link: '/core_feature/send_message.md' },
          { text: 'Receive Message', link: '/core_feature/receive_message.md' },
          { text: 'Customizations', link: '/core_feature/customizations.md' },
          { text: 'Notifications', link: '/core_feature/notifications.md' },
        ],
      },

      {
        text: 'Advanced Features',
        collapsed: true,
        items: [
          { text: 'Multi-Language Support', link: '/advanced_feature/multi_language_support.md' },
          { text: 'Offline Mode', link: '/advanced_feature/offline_mode.md' },
          { text: 'Chat History', link: '/advanced_feature/chat_history.md' },
          { text: 'Analytics Integration', link: '/advanced_feature/analytics_integration.md' },
          { text: 'Custom Events', link: '/advanced_feature/custom_events.md' },
        ],
      },

      {
        text: 'Troubleshooting',
        collapsed: true,
        items: [
          { text: 'Common Issues', link: '/troubleshooting/common_issues.md' },
          { text: 'Debugging', link: '/troubleshooting/debugging.md' },
          { text: 'Error Handling', link: '/troubleshooting/error_handling.md' },
        ],
      },

      {
        text: 'References',
        collapsed: true,
        items: [
          { text: 'API Documentation', link: '/reference/api_documentation.md' },
          { text: 'Examples', link: '/reference/examples.md' },
          { text: 'FAQ', link: '/reference/faq.md' },
          { text: 'Changelog', link: '/reference/changelog.md' },
        ],
      },
    ],

    // Footer Section
    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2025 Crisp'
    },
  },
})