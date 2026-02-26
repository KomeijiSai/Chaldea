/**
 * 测试脚本
 */

import { generateSelfie } from './index';
import * as path from 'path';

require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

async function test() {
  console.log('🧪 Clawra ModelScope 测试\n');

  // 测试场景
  const testCases = [
    '在咖啡厅喝拿铁',
    '在家里工作',
    '戴着帽子在公园',
    '在海边看日落'
  ];

  for (const scene of testCases.slice(0, 1)) {  // 只测试第一个
    console.log(`\n测试场景: ${scene}`);
    console.log('-'.repeat(50));

    try {
      await generateSelfie({
        scene,
        outputPath: `/tmp/clawra-test-${Date.now()}.png`
      });
      console.log('✅ 成功');
    } catch (error: any) {
      console.error('❌ 失败:', error.message);
    }
  }

  console.log('\n测试完成！');
}

test();
