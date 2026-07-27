import { defineConfig } from '@playwright/test';
import dotenv from 'dotenv';

dotenv.config();

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : 4,
  reporter: [
    ['html'],
    ['allure-playwright'],
    ['junit', { outputFile: 'test-results.xml' }]
  ],
  use: {
    baseURL: 'https://api.precisely.com',
    timeout: 30000
  }
});
