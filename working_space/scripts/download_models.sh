#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ ! -x "$WORK/conda_envs/dms_py310/bin/python" ]]; then
  echo "python environment is missing: $WORK/conda_envs/dms_py310" >&2
  echo "run working_space/scripts/setup_python_env.sh first" >&2
  exit 2
fi

source "$WORK/scripts/activate_env.sh"

export HF_HUB_OFFLINE=0
export TRANSFORMERS_OFFLINE=0
export QWEN_MODEL_ID="${QWEN_MODEL_ID:-Qwen/Qwen2.5-VL-7B-Instruct}"
export EMBED_MODEL_ID="${EMBED_MODEL_ID:-sentence-transformers/all-MiniLM-L6-v2}"
export EMBED_DIR="${EMBED_DIR:-$WORK/model_cache/modelscope/AI-ModelScope/all-MiniLM-L6-v2}"

python - <<'PY'
from __future__ import annotations

import os
from pathlib import Path

from huggingface_hub import snapshot_download

hf_home = Path(os.environ["HF_HOME"]).resolve()
qwen_model_id = os.environ["QWEN_MODEL_ID"]
embed_model_id = os.environ["EMBED_MODEL_ID"]
embed_dir = Path(os.environ["EMBED_DIR"]).resolve()

hf_home.mkdir(parents=True, exist_ok=True)
embed_dir.parent.mkdir(parents=True, exist_ok=True)

print(f"downloading_qwen={qwen_model_id}")
snapshot_download(
    repo_id=qwen_model_id,
    cache_dir=str(hf_home),
)

print(f"downloading_embedder={embed_model_id}")
snapshot_download(
    repo_id=embed_model_id,
    local_dir=str(embed_dir),
    local_dir_use_symlinks=False,
)

print(f"hf_home={hf_home}")
print(f"embed_dir={embed_dir}")
PY
