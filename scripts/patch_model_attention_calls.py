#!/usr/bin/env python3
"""
Permanent fix for the flash-attn AssertionError crash.
Redirects model.py's 4 direct calls to flash_attention() to the
SDPA-capable attention() dispatcher already defined in attention.py,
which falls back to torch.nn.functional.scaled_dot_product_attention
when flash-attn isn't installed.
"""
import re
from pathlib import Path

MODEL_PY = Path("/workspace/Wan2.1/wan/modules/model.py")

content = MODEL_PY.read_text()
before_count = content.count("flash_attention(")

if before_count == 0:
    print("No flash_attention( calls found — already patched or file differs from expected base.")
else:
    new_content = re.sub(r"\bflash_attention\(", "attention(", content)
    MODEL_PY.write_text(new_content)
    after_count = new_content.count("flash_attention(")
    print(f"Replaced {before_count - after_count} flash_attention( calls with attention( in model.py")
