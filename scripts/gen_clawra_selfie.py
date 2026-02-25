#!/usr/bin/env python3
"""
Clawra Selfie Generator - Alibaba Cloud Bailian (通义万相)
Usage: python3 gen_clawra_selfie.py "<prompt>" "[output_path]"
"""
import urllib.request
import json
import time
import sys
import os

# Load API key from .env
def load_api_key():
    env_path = "/root/.openclaw/workspace/.env"
    with open(env_path, 'r') as f:
        for line in f:
            if line.startswith('ALIYUN_BAILIAN_API_KEY='):
                return line.strip().split('=', 1)[1]
    return None

API_KEY = load_api_key()
if not API_KEY:
    print("❌ Error: ALIYUN_BAILIAN_API_KEY not found in .env")
    sys.exit(1)

def generate_selfie(prompt, output_path="/tmp/clawra-selfie.png"):
    """Generate selfie using Alibaba Cloud Bailian Wanx model"""
    
    print(f"🎨 Generating Clawra selfie...")
    print(f"   Prompt: {prompt[:60]}...")
    
    # Step 1: Create generation task
    url = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text2image/image-synthesis"
    
    data = {
        "model": "wanx-v1",
        "input": {
            "prompt": prompt
        },
        "parameters": {
            "style": "<auto>",
            "size": "1024*1024",
            "n": 1
        }
    }
    
    try:
        req = urllib.request.Request(
            url,
            data=json.dumps(data).encode(),
            headers={
                'Authorization': f'Bearer {API_KEY}',
                'Content-Type': 'application/json',
                'X-DashScope-Async': 'enable'
            }
        )
        
        with urllib.request.urlopen(req, timeout=30) as response:
            result = json.loads(response.read().decode())
            task_id = result['output']['task_id']
            print(f"   Task ID: {task_id}")
            
    except Exception as e:
        print(f"❌ Failed to create task: {e}")
        return None
    
    # Step 2: Poll for completion
    print("   Waiting for generation...")
    query_url = f"https://dashscope.aliyuncs.com/api/v1/tasks/{task_id}"
    max_wait = 60
    waited = 0
    
    while waited < max_wait:
        try:
            req = urllib.request.Request(
                query_url,
                headers={'Authorization': f'Bearer {API_KEY}'}
            )
            with urllib.request.urlopen(req, timeout=10) as response:
                status_result = json.loads(response.read().decode())
                status = status_result['output']['task_status']
                
                if status == 'SUCCEEDED':
                    img_url = status_result['output']['results'][0]['url']
                    
                    # Download image
                    img_req = urllib.request.Request(img_url, headers={'User-Agent': 'Mozilla/5.0'})
                    with urllib.request.urlopen(img_req, timeout=30) as img_response:
                        img_data = img_response.read()
                        with open(output_path, 'wb') as f:
                            f.write(img_data)
                    
                    print(f"✅ Image saved: {output_path} ({len(img_data)} bytes)")
                    return output_path
                    
                elif status == 'FAILED':
                    print(f"❌ Generation failed: {status_result}")
                    return None
                else:
                    time.sleep(5)
                    waited += 5
                    
        except Exception as e:
            time.sleep(5)
            waited += 5
    
    print("⚠️ Timeout, but task may still be processing")
    return None

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 gen_clawra_selfie.py <prompt> [output_path]")
        print("Example: python3 gen_clawra_selfie.py 'anime selfie at a cafe'")
        sys.exit(1)
    
    prompt = sys.argv[1]
    output = sys.argv[2] if len(sys.argv) > 2 else "/tmp/clawra-selfie.png"
    
    result = generate_selfie(prompt, output)
    if result:
        print(f"\n📸 Selfie ready: {result}")
    else:
        sys.exit(1)
