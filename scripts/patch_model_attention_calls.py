#!/usr/bin/env python3
"""
Permanent fix for the flash-attn AssertionError crash.
Redirects model.py's 4 direct calls to flash_attention() to the
SDPA-capable attention() dispatcher already defined in attention.py,
which falls back to torch.nn.functional.scaled_dot_product_attention
when flash-attn isn't installed.

Also ensures model.py actually imports `attention` alongside
`flash_attention` — without this, the renamed calls raise
NameError: name 'attention' is not defined at generation time.
"""
import re
from pathlib import Path
MODEL_PY = Path("/workspace/Wan2.1/wan/modules/model.py")
content = MODEL_PY.read_text()

# --- Fix 1: redirect flash_attention( calls to attention( ---
before_count = content.count("flash_attention(")
if before_count == 0:
    print("No flash_attention( calls found — already patched or file differs from expected base.")
else:
    content = re.sub(r"\bflash_attention\(", "attention(", content)
    after_count = content.count("flash_attention(")
    print(f"Replaced {before_count - after_count} flash_attention( calls with attention( in model.py")

# --- Fix 2: ensure `attention` is actually imported ---
old_import = "from .attention import flash_attention"
new_import = "from .attention import flash_attention, attention"
if new_import in content:
    print("Import already includes `attention` — no change needed.")
elif old_import in content:
    content = content.replace(old_import, new_import)
    print("Added `attention` to the .attention import in model.py")
else:
    print("WARNING: expected import line not found — could not verify/fix `attention` import. Check model.py manually.")

MODEL_PY.write_text(content)
