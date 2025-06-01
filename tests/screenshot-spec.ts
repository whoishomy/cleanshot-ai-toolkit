import { describe, it, expect } from 'vitest';
import fs from 'fs';
import path from 'path';
import { glob } from 'glob';

const PROJECT_DIR = process.env.HOME + '/homy-ui-v3';
const SCREENSHOTS_DIR = path.join(PROJECT_DIR, 'docs/screenshots');

interface ScreenshotMetadata {
  component: string;
  date: string;
  viewport: string;
  resolution: string;
}

function parseScreenshotName(filename: string): ScreenshotMetadata | null {
  // Expected format: DD-Month-YYYY-[component]-[viewport]@resolution.png
  const pattern = /^(\d{2}-[A-Za-z]+-\d{4})-\[([^\]]+)\]-\[([^\]]+)\]@?([\dx]*)\.png$/;
  const match = filename.match(pattern);

  if (!match) return null;

  return {
    date: match[1],
    component: match[2].toLowerCase(),
    viewport: match[3],
    resolution: match[4] || '1x',
  };
}

describe('Screenshot Organization Tests', () => {
  // Get all screenshot directories
  const componentDirs = fs
    .readdirSync(SCREENSHOTS_DIR)
    .filter((item) => fs.statSync(path.join(SCREENSHOTS_DIR, item)).isDirectory());

  it('should have valid component directories', () => {
    expect(componentDirs.length).toBeGreaterThan(0);
    componentDirs.forEach((dir) => {
      expect(dir).toMatch(/^[a-z0-9-]+$/);
    });
  });

  it('each component directory should have a README.md', () => {
    componentDirs.forEach((dir) => {
      const readmePath = path.join(SCREENSHOTS_DIR, dir, 'README.md');
      expect(fs.existsSync(readmePath)).toBe(true);
    });
  });

  describe('Screenshot File Tests', () => {
    const allScreenshots = glob.sync('**/*.png', { cwd: SCREENSHOTS_DIR });

    it('should have valid file names', () => {
      allScreenshots.forEach((screenshot) => {
        const metadata = parseScreenshotName(path.basename(screenshot));
        expect(metadata).not.toBeNull();
      });
    });

    it('screenshots should be in correct component directories', () => {
      allScreenshots.forEach((screenshot) => {
        const metadata = parseScreenshotName(path.basename(screenshot));
        if (metadata) {
          const expectedDir = metadata.component;
          const actualDir = path.dirname(screenshot);
          expect(actualDir).toBe(expectedDir);
        }
      });
    });

    it('should have consistent date formats', () => {
      const datePattern = /^\d{2}-[A-Za-z]+-\d{4}$/;
      allScreenshots.forEach((screenshot) => {
        const metadata = parseScreenshotName(path.basename(screenshot));
        if (metadata) {
          expect(metadata.date).toMatch(datePattern);
        }
      });
    });

    it('should have valid viewport specifications', () => {
      const validViewports = ['mobile', 'tablet', 'desktop', 'wide'];
      allScreenshots.forEach((screenshot) => {
        const metadata = parseScreenshotName(path.basename(screenshot));
        if (metadata) {
          expect(validViewports).toContain(metadata.viewport.toLowerCase());
        }
      });
    });
  });

  describe('File System Integrity', () => {
    it('should not have orphaned screenshots', () => {
      const allFiles = glob.sync('**/*', { cwd: SCREENSHOTS_DIR });
      allFiles.forEach((file) => {
        if (file.endsWith('.png')) {
          const dir = path.dirname(file);
          expect(componentDirs).toContain(dir);
        }
      });
    });

    it('should have consistent file permissions', () => {
      const allFiles = glob.sync('**/*', { cwd: SCREENSHOTS_DIR });
      allFiles.forEach((file) => {
        const stats = fs.statSync(path.join(SCREENSHOTS_DIR, file));
        expect(stats.mode & 0o644).toBeTruthy();
      });
    });
  });
});
