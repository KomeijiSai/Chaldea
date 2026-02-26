#!/usr/bin/env node
/**
 * Clawra CLI - 命令行工具
 */

import { generateSelfie, generateBatch, generateAndSend } from './index';
import * as fs from 'fs';
import * as path from 'path';

// 加载 .env
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    printHelp();
    process.exit(0);
  }

  const command = args[0];

  switch (command) {
    case 'generate':
    case 'gen':
      await handleGenerate(args.slice(1));
      break;

    case 'batch':
      await handleBatch(args.slice(1));
      break;

    case 'send':
      await handleSend(args.slice(1));
      break;

    case 'test':
      await handleTest();
      break;

    case 'help':
    case '--help':
    case '-h':
      printHelp();
      break;

    default:
      console.error(`❌ 未知命令: ${command}`);
      printHelp();
      process.exit(1);
  }
}

async function handleGenerate(args: string[]) {
  if (args.length === 0) {
    console.error('❌ 请提供场景描述');
    console.log('示例: clawra generate "在咖啡馆"');
    process.exit(1);
  }

  const scene = args.join(' ');
  const outputPath = args.includes('-o')
    ? args[args.indexOf('-o') + 1]
    : '/tmp/clawra-selfie.png';

  try {
    await generateSelfie({ scene, outputPath });
    console.log('\n✅ 生成成功！');
  } catch (error: any) {
    console.error('❌ 生成失败:', error.message);
    process.exit(1);
  }
}

async function handleBatch(args: string[]) {
  if (args.length === 0) {
    console.error('❌ 请提供场景文件路径');
    console.log('示例: clawra batch scenes.txt');
    process.exit(1);
  }

  const inputFile = args[0];
  const outputDir = args.includes('-o')
    ? args[args.indexOf('-o') + 1]
    : '/tmp/clawra-batch';

  if (!fs.existsSync(inputFile)) {
    console.error(`❌ 文件不存在: ${inputFile}`);
    process.exit(1);
  }

  // 创建输出目录
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  // 读取场景列表
  const scenes = fs.readFileSync(inputFile, 'utf-8')
    .split('\n')
    .map(line => line.trim())
    .filter(line => line && !line.startsWith('#'));

  console.log(`📋 读取到 ${scenes.length} 个场景`);

  try {
    const results = await generateBatch(scenes, outputDir);
    console.log(`\n✅ 成功生成 ${results.length}/${scenes.length} 张图片`);
  } catch (error: any) {
    console.error('❌ 批量生成失败:', error.message);
    process.exit(1);
  }
}

async function handleSend(args: string[]) {
  if (args.length < 2) {
    console.error('❌ 请提供场景和频道');
    console.log('示例: clawra send "在咖啡馆" "#general"');
    process.exit(1);
  }

  const scene = args[0];
  const channel = args[1];
  const message = args.length > 2 ? args.slice(2).join(' ') : undefined;

  try {
    await generateAndSend(scene, channel, message);
    console.log('\n✅ 发送成功！');
  } catch (error: any) {
    console.error('❌ 发送失败:', error.message);
    process.exit(1);
  }
}

async function handleTest() {
  console.log('🧪 测试 ModelScope API 连接...\n');

  const apiKey = process.env.MODELSCOPE_API_KEY;
  if (!apiKey) {
    console.error('❌ MODELSCOPE_API_KEY 未设置');
    console.log('请在 .env 文件中配置 MODELSCOPE_API_KEY');
    process.exit(1);
  }

  console.log(`API Key: ${apiKey.substring(0, 10)}...${apiKey.substring(apiKey.length - 10)}`);
  console.log(`API URL: https://api-inference.modelscope.cn/v1/images/generations`);
  console.log(`Model: Tongyi-MAI/Z-Image-Turbo`);

  try {
    console.log('\n📸 生成测试图片...');
    await generateSelfie({
      scene: '在咖啡厅',
      outputPath: '/tmp/clawra-test.png'
    });
    console.log('\n✅ 测试成功！API 连接正常');
  } catch (error: any) {
    console.error('\n❌ 测试失败:', error.message);
    process.exit(1);
  }
}

function printHelp() {
  console.log(`
Clawra - ModelScope Z-Image-Turbo 自拍生成器

用法:
  clawra <command> [options]

命令:
  generate <scene>    生成自拍
                      示例: clawra generate "在咖啡馆"

  batch <file>        批量生成
                      示例: clawra batch scenes.txt

  send <scene> <channel>  生成并发送
                      示例: clawra send "在咖啡馆" "#general"

  test                测试 API 连接

  help                显示帮助

选项:
  -o <path>           指定输出路径

示例:
  clawra generate "在咖啡厅里喝拿铁"
  clawra generate "戴着帽子在公园" -o ./selfie.png
  clawra send "在家里工作" "#random" "加班中！"
  clawra batch scenes.txt -o ./output

环境变量:
  MODELSCOPE_API_KEY  ModelScope API Key (必需)
`);
}

main().catch(error => {
  console.error('❌ 错误:', error.message);
  process.exit(1);
});
