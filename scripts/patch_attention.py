#!/usr/bin/env python3
"""
Patch Wan2.1 attention.py to use PyTorch native SDPA instead of flash_attn.
PyTorch 2.0+ F.scaled_dot_product_attention achieves near-identical performance.
Works on any CUDA version without compilation.
"""
import re, sys

f = '/workspace/Wan2.1/wan/modules/attention.py'
lines = open(f).readlines()
new_lines = []
patched = False

for i, line in enumerate(lines):
    # Find the assert line regardless of indentation
    if not patched and re.match(r'\s+assert FLASH_ATTN_2_AVAILABLE\s*$', line):
        indent = len(line) - len(line.lstrip())
        sp = ' ' * indent
        # Replace with PyTorch native attention fallback
        new_lines.append(f'{sp}import torch.nn.functional as _F\n')
        new_lines.append(f'{sp}q_t = q.permute(0, 2, 1, 3)\n')
        new_lines.append(f'{sp}k_t = k.permute(0, 2, 1, 3)\n')
        new_lines.append(f'{sp}v_t = v.permute(0, 2, 1, 3)\n')
        new_lines.append(f'{sp}out = _F.scaled_dot_product_attention(\n')
        new_lines.append(f'{sp}    q_t, k_t, v_t,\n')
        new_lines.append(f'{sp}    scale=softmax_scale,\n')
        new_lines.append(f'{sp}    dropout_p=float(dropout_p) if dropout_p else 0.0)\n')
        new_lines.append(f'{sp}return out.permute(0, 2, 1, 3)\n')
        patched = True
        print(f'Line {i+1}: Patched with PyTorch SDPA (indent={indent})')
    else:
        new_lines.append(line)

if patched:
    open(f, 'w').writelines(new_lines)
    print('SUCCESS: attention.py patched - PyTorch F.scaled_dot_product_attention active')
else:
    print('ERROR: assert FLASH_ATTN_2_AVAILABLE not found')
    for j, l in enumerate(lines[105:125], 106):
        print(f'{j}: {repr(l.rstrip())}')
    sys.exit(1)
