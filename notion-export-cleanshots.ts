import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import { Client } from '@notionhq/client';
import { glob } from 'glob';
import { parseArgs } from 'node:util';

dotenv.config();

const notion = new Client({
  auth: process.env.NOTION_TOKEN,
});

interface NotionExportConfig {
  databaseId: string;
  component?: string;
}

interface ComponentMetadata {
  name: string;
  description: string;
  tags: string[];
  screenshots: string[];
  lastUpdated: string;
}

async function getComponentMetadata(componentDir: string): Promise<ComponentMetadata> {
  const readmePath = path.join(componentDir, 'README.md');
  const content = fs.readFileSync(readmePath, 'utf-8');

  // Parse AI-generated description and tags
  const descriptionMatch = content.match(/## 🤖 AI Generated Description.*?\n(.*?)\n\n/s);
  const tagsMatch = content.match(/### Tags\n((?:- `.*`\n)+)/);

  const screenshots = glob.sync('*.png', { cwd: componentDir });
  const lastUpdated = new Date().toISOString();

  return {
    name: path.basename(componentDir),
    description: descriptionMatch?.[1] || 'No description available',
    tags: tagsMatch?.[1].match(/`(.*?)`/g)?.map((tag) => tag.replace(/`/g, '')) || [],
    screenshots: screenshots,
    lastUpdated,
  };
}

async function uploadScreenshotToNotion(imagePath: string): Promise<string> {
  // TODO: Implement actual file upload when Notion API supports it
  // For now, we'll just return the local path
  return imagePath;
}

async function createOrUpdateNotionPage(config: NotionExportConfig, metadata: ComponentMetadata) {
  const existingPages = await notion.databases.query({
    database_id: config.databaseId,
    filter: {
      property: 'Component',
      title: {
        equals: metadata.name,
      },
    },
  });

  const properties = {
    Component: {
      title: [{ text: { content: metadata.name } }],
    },
    Description: {
      rich_text: [{ text: { content: metadata.description } }],
    },
    Tags: {
      multi_select: metadata.tags.map((tag) => ({ name: tag })),
    },
    'Last Updated': {
      date: { start: metadata.lastUpdated },
    },
    'Screenshot Count': {
      number: metadata.screenshots.length,
    },
  };

  if (existingPages.results.length > 0) {
    const pageId = existingPages.results[0].id;
    await notion.pages.update({
      page_id: pageId,
      properties,
    });
    console.log(`✅ Updated Notion page for ${metadata.name}`);
  } else {
    await notion.pages.create({
      parent: { database_id: config.databaseId },
      properties,
    });
    console.log(`✨ Created new Notion page for ${metadata.name}`);
  }
}

async function exportToNotion(config: NotionExportConfig) {
  const SCREENSHOTS_DIR = path.join(process.cwd(), 'docs', 'screenshots');

  if (!process.env.NOTION_TOKEN || !config.databaseId) {
    console.error('❌ Missing NOTION_TOKEN or DATABASE_ID');
    process.exit(1);
  }

  let components: string[];
  if (config.component) {
    const componentDir = path.join(SCREENSHOTS_DIR, config.component);
    if (!fs.existsSync(componentDir)) {
      console.error(`❌ Component directory not found: ${config.component}`);
      process.exit(1);
    }
    components = [config.component];
  } else {
    components = fs
      .readdirSync(SCREENSHOTS_DIR)
      .filter((item) => fs.statSync(path.join(SCREENSHOTS_DIR, item)).isDirectory());
  }

  console.log(`🚀 Exporting ${components.length} component(s) to Notion...`);

  for (const component of components) {
    const componentDir = path.join(SCREENSHOTS_DIR, component);
    console.log(`\n📤 Processing ${component}...`);

    const metadata = await getComponentMetadata(componentDir);
    await createOrUpdateNotionPage(config, metadata);
  }
}

// Parse command line arguments
const { values } = parseArgs({
  options: {
    component: { type: 'string' },
    database: { type: 'string' },
  },
});

const config: NotionExportConfig = {
  databaseId: values.database || process.env.NOTION_DATABASE_ID || '',
  component: values.component,
};

exportToNotion(config).catch(console.error);
