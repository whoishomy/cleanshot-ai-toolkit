import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import OpenAI from 'openai';
import { glob } from 'glob';

// Load environment variables
dotenv.config();

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

interface ScreenshotMetadata {
  component: string;
  viewport: string;
  date: string;
  description?: string;
  tags?: string[];
}

async function generateScreenshotDescription(
  metadata: ScreenshotMetadata
): Promise<{ description: string; tags: string[] }> {
  const prompt = `
Given a UI component screenshot with the following metadata:
- Component: ${metadata.component}
- Viewport: ${metadata.viewport}
- Date: ${metadata.date}

Please provide:
1. A concise description of what this component likely does (max 2 sentences)
2. A list of relevant tags (max 5) that categorize this component

Format the response as JSON:
{
  "description": "...",
  "tags": ["tag1", "tag2", ...]
}`;

  const completion = await openai.chat.completions.create({
    model: 'gpt-4-turbo-preview',
    messages: [{ role: 'user', content: prompt }],
    temperature: 0.7,
    max_tokens: 150,
  });

  try {
    return JSON.parse(completion.choices[0].message.content || '{"description": "", "tags": []}');
  } catch (e) {
    console.error('Failed to parse OpenAI response:', e);
    return { description: '', tags: [] };
  }
}

async function updateReadmeWithAITags(componentDir: string, metadata: ScreenshotMetadata) {
  const readmePath = path.join(componentDir, 'README.md');
  const { description, tags } = await generateScreenshotDescription(metadata);

  let content = '';
  if (fs.existsSync(readmePath)) {
    content = fs.readFileSync(readmePath, 'utf-8') + '\n\n';
  }

  const newEntry = `## 🤖 AI Generated Description (${metadata.date})
${description}

### Tags
${tags.map((tag) => `- \`${tag}\``).join('\n')}

---\n`;

  fs.writeFileSync(readmePath, content + newEntry);
  return { description, tags };
}

async function processScreenshot(screenshotPath: string) {
  const filename = path.basename(screenshotPath);
  const match = filename.match(/^(\d{2}-[A-Za-z]+-\d{4})-\[([^\]]+)\]-\[([^\]]+)\]@?.*\.png$/);

  if (!match) {
    console.warn(`❌ Invalid filename format: ${filename}`);
    return;
  }

  const [, date, component, viewport] = match;
  const metadata: ScreenshotMetadata = { date, component, viewport };
  const componentDir = path.dirname(screenshotPath);

  console.log(`\n🔍 Processing: ${filename}`);
  const result = await updateReadmeWithAITags(componentDir, metadata);

  console.log(`✅ Updated ${component} README.md`);
  console.log(`📝 Description: ${result.description}`);
  console.log(`🏷️ Tags: ${result.tags.join(', ')}`);
}

async function main() {
  const SCREENSHOTS_DIR = path.join(process.cwd(), 'docs', 'screenshots');

  if (!process.env.OPENAI_API_KEY) {
    console.error('❌ Error: OPENAI_API_KEY not found in environment variables');
    process.exit(1);
  }

  const screenshots = glob
    .sync('**/*.png', { cwd: SCREENSHOTS_DIR })
    .map((file) => path.join(SCREENSHOTS_DIR, file));

  console.log(`🚀 Found ${screenshots.length} screenshots to process`);

  for (const screenshot of screenshots) {
    await processScreenshot(screenshot);
  }

  console.log('\n✨ AI tagging complete!');
}

main().catch(console.error);
