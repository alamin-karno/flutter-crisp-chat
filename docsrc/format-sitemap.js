const fs = require('fs');
const { execSync } = require('child_process');

// Format sitemap after VitePress build
const sitemapPath = './docs/.vitepress/dist/sitemap.xml';

if (fs.existsSync(sitemapPath)) {
  try {
    // Use xmllint to format the sitemap with proper indentation
    execSync(`xmllint --format "${sitemapPath}" > "${sitemapPath}.tmp"`, { stdio: 'inherit' });
    fs.renameSync(`${sitemapPath}.tmp`, sitemapPath);
    console.log('✅ Sitemap formatted successfully');
  } catch (error) {
    console.log('⚠️  Could not format sitemap (xmllint not available):', error.message);
  }
}
