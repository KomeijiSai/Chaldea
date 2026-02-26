/**
 * Clawra Selfie Generator - ModelScope Z-Image-Turbo
 *
 * 核心功能：使用魔搭 ModelScope API 生成 Clawra 自拍
 */

import axios from 'axios';
import * as fs from 'fs';
import * as path from 'path';

// 固定人设提示词
const CHARACTER_PROMPT = '18岁K-pop少女，元气可爱，统一面部特征，高清自拍，自然光线，日常穿搭';

// API 配置
const API_URL = 'https://api-inference.modelscope.cn/v1/images/generations';
const MODEL = 'Tongyi-MAI/Z-Image-Turbo';

// 生成参数
const GENERATION_PARAMS = {
  size: '1024x1024',
  steps: 8,
  guidance_scale: 0.0,
  negative_prompt: 'watermark, text, logo, low quality, blurry'
};

export interface SelfieOptions {
  scene: string;           // 场景描述，如"咖啡馆"、"家里"、"戴帽子"
  outputPath?: string;     // 输出路径，默认 /tmp/clawra-selfie.png
  timeout?: number;        // 超时时间，默认 60000ms
}

export interface GenerationResponse {
  created: number;
  data: Array<{
    url?: string;
    b64_json?: string;
  }>;
}

/**
 * 生成自拍
 */
export async function generateSelfie(options: SelfieOptions): Promise<string> {
  const { scene, outputPath = '/tmp/clawra-selfie.png', timeout = 60000 } = options;

  // 读取 API Key
  const apiKey = process.env.MODELSCOPE_API_KEY;
  if (!apiKey) {
    throw new Error('MODELSCOPE_API_KEY 未设置，请在 .env 文件中配置');
  }

  // 构建完整提示词
  const fullPrompt = `${CHARACTER_PROMPT}，${scene}`;

  console.log('📸 生成 Clawra 自拍...');
  console.log(`场景: ${scene}`);
  console.log(`完整提示词: ${fullPrompt}`);

  try {
    // 调用 ModelScope API
    const response = await axios.post<GenerationResponse>(
      API_URL,
      {
        model: MODEL,
        input: {
          prompt: fullPrompt,
          negative_prompt: GENERATION_PARAMS.negative_prompt
        },
        parameters: {
          size: GENERATION_PARAMS.size,
          steps: GENERATION_PARAMS.steps,
          guidance_scale: GENERATION_PARAMS.guidance_scale,
          n: 1
        }
      },
      {
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json'
        },
        timeout
      }
    );

    // 提取图片 URL 或 Base64
    const imageData = response.data.data[0];
    if (!imageData) {
      throw new Error('API 返回数据中没有图片');
    }

    // 下载或保存图片
    if (imageData.url) {
      // 从 URL 下载
      console.log(`📥 下载图片: ${imageData.url}`);
      const imageResponse = await axios.get(imageData.url, {
        responseType: 'arraybuffer',
        timeout: 30000
      });
      fs.writeFileSync(outputPath, imageResponse.data);
    } else if (imageData.b64_json) {
      // 从 Base64 保存
      console.log('💾 保存 Base64 图片...');
      const buffer = Buffer.from(imageData.b64_json, 'base64');
      fs.writeFileSync(outputPath, buffer);
    } else {
      throw new Error('API 返回数据格式不支持');
    }

    console.log(`✅ 图片已保存: ${outputPath}`);
    console.log(`   大小: ${(fs.statSync(outputPath).size / 1024).toFixed(2)} KB`);

    return outputPath;

  } catch (error: any) {
    if (error.response) {
      console.error('API 错误:', error.response.data);
      throw new Error(`API 调用失败: ${error.response.data.message || error.message}`);
    }
    throw error;
  }
}

/**
 * 批量生成自拍
 */
export async function generateBatch(scenes: string[], outputDir: string): Promise<string[]> {
  const results: string[] = [];

  for (let i = 0; i < scenes.length; i++) {
    const scene = scenes[i];
    const outputPath = path.join(outputDir, `clawra-${i + 1}.png`);

    console.log(`\n[${i + 1}/${scenes.length}] 处理场景: ${scene}`);

    try {
      await generateSelfie({ scene, outputPath });
      results.push(outputPath);
    } catch (error) {
      console.error(`❌ 场景 "${scene}" 生成失败:`, error);
    }

    // 避免请求过快
    if (i < scenes.length - 1) {
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }

  return results;
}

/**
 * 生成自拍并发送到 OpenClaw
 */
export async function generateAndSend(
  scene: string,
  channel: string,
  message?: string
): Promise<string> {
  // 生成自拍
  const imagePath = await generateSelfie({ scene });

  // 发送到 OpenClaw
  const caption = message || `📸 ${scene}`;

  // 使用 message 工具发送
  // 这里可以调用 OpenClaw 的 message API
  console.log(`📤 发送到 ${channel}: ${caption}`);
  console.log(`   图片: ${imagePath}`);

  // 实际发送逻辑需要通过 OpenClaw 的工具
  return imagePath;
}
