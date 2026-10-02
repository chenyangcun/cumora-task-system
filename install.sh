#!/usr/bin/env bash
set -e

# ==============================================================
# Cumora Task System 一键安装脚本
# 支持在任意 Hermes Agent 节点 / 研发工作区自动安装 CLI 与 Skill
# ==============================================================

INSTALL_DIR="${HOME}/.local/bin"
SKILLS_DIR="${HOME}/.skills/cumora-task-system"
REPO_RAW="https://raw.githubusercontent.com/chenyangcun/cumora-task-system/main"

echo "🚀 [Cumora] 开始安装 cumora-task CLI 与 Skill..."

# 1. 创建目标目录
mkdir -p "${INSTALL_DIR}"
mkdir -p "${SKILLS_DIR}"

# 2. 安装 cumora-task CLI 可执行脚本
echo "📦 正在安装 cumora-task CLI 至 ${INSTALL_DIR} ..."
if [ -f "$(dirname "$0")/bin/cumora-task" ]; then
    cp "$(dirname "$0")/bin/cumora-task" "${INSTALL_DIR}/cumora-task"
else
    curl -fsSL "${REPO_RAW}/bin/cumora-task" -o "${INSTALL_DIR}/cumora-task"
fi
chmod +x "${INSTALL_DIR}/cumora-task"

# 3. 安装 Skill 定义文件
echo "🧠 正在安装 cumora-task-system Skill 至 ${SKILLS_DIR} ..."
if [ -f "$(dirname "$0")/skills/cumora-task-system/SKILL.md" ]; then
    cp "$(dirname "$0")/skills/cumora-task-system/SKILL.md" "${SKILLS_DIR}/SKILL.md"
else
    curl -fsSL "${REPO_RAW}/skills/cumora-task-system/SKILL.md" -o "${SKILLS_DIR}/SKILL.md"
fi

# 4. PATH 环境变量友好提示
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
    echo "⚠️  注意: ${INSTALL_DIR} 尚未在您的 PATH 环境变量中。"
    echo "   建议在 ~/.bashrc 或 ~/.zshrc 中追加: export PATH=\"${INSTALL_DIR}:\$PATH\""
fi

echo "=================================================="
echo "🎉 安装完成！验证命令："
echo "   ${INSTALL_DIR}/cumora-task --help"
echo "   ${INSTALL_DIR}/cumora-task agents"
echo "=================================================="
