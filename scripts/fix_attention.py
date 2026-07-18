path = "/workspace/Wan2.1/wan/modules/attention.py"
with open(path, "r") as f:
    src = f.read()

old_block = '''    else:
        import torch.nn.functional as _F
        q_t = q.permute(0, 2, 1, 3)
        k_t = k.permute(0, 2, 1, 3)
        v_t = v.permute(0, 2, 1, 3)
        out = _F.scaled_dot_product_attention(
            q_t, k_t, v_t,
            scale=softmax_scale,
            dropout_p=float(dropout_p) if dropout_p else 0.0)
        return out.permute(0, 2, 1, 3)'''

new_block = '''    else:
        import torch.nn.functional as _F
        q_splits = torch.split(q, q_lens.tolist(), dim=0)
        k_splits = torch.split(k, k_lens.tolist(), dim=0)
        v_splits = torch.split(v, k_lens.tolist(), dim=0)
        outs = []
        for qi, ki, vi in zip(q_splits, k_splits, v_splits):
            qi_t = qi.unsqueeze(0).permute(0, 2, 1, 3)
            ki_t = ki.unsqueeze(0).permute(0, 2, 1, 3)
            vi_t = vi.unsqueeze(0).permute(0, 2, 1, 3)
            oi = _F.scaled_dot_product_attention(
                qi_t, ki_t, vi_t,
                scale=softmax_scale,
                is_causal=bool(causal),
                dropout_p=float(dropout_p) if dropout_p else 0.0)
            oi = oi.permute(0, 2, 1, 3).squeeze(0)
            outs.append(oi)
        x = torch.cat(outs, dim=0).unflatten(0, (b, lq))
        return x.type(out_dtype)'''

if old_block not in src:
    print("OLD BLOCK NOT FOUND")
    raise SystemExit(1)

src = src.replace(old_block, new_block, 1)
with open(path, "w") as f:
    f.write(src)
print("Patched successfully.")
