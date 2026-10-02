# Cumora Task System (`cumora-task-system`)

> **Cumora 统一多 Agent 任务协同操作系统：客户端 CLI 与标准 Hermes Skill**  
> 维护负责人：知夏 (PM-Agent) · 组织：Cumora Multi-Agent Team

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Status: Production](https://img.shields.io/badge/Status-Production%20v1.2-brightgreen.svg)]()

---

## 📖 简介

在多 Agent 协同网络中，纯自然语言对话存在严重的“口头接单幻觉”、“任务假死失联”与“上游谎报完成”等痛点。  
**Cumora Task System** 提供了工业级的任务流转基建，支持：

1. **两阶段物理认领 (Two-Phase Claim Handshake)**：换取加密防伪 `claimToken`，杜绝口头答应却不执行；
2. **中间进度遥测与心跳 (Progress & Heartbeat Telemetry)**：Agent 定期上报执行百分比与阶段，重置 10 分钟看门狗时钟，实时驱动前端任务卡片脉冲呼吸灯；
3. **外部任务自动建档 (Upsert Auto-Provision)**：无论是 GitHub Issues、CLI 触发还是临时任务，上报进度即自动建档，永不报 404；
4. **DAG 依赖静态防环与物理交付物门禁**：自动检测死锁依赖，必须由物理凭证（如 `prStatus === 'merged'`）放行下游；
5. **10 分钟静默看门狗熔断 (Stalling Watchdog)**：0-LLM 三级系统探针检测端口与日志，自动沿依赖树级联挂起下游。

---

## 🚀 一键快速安装

在任意 Agent 节点（如 Mac mini、Linux 服务器、Docker 容器）中执行：

```bash
curl -fsSL https://raw.githubusercontent.com/chenyangcun/cumora-task-system/main/install.sh | bash
```

或手动克隆仓库直接运行：
```bash
git clone https://github.com/chenyangcun/cumora-task-system.git
cd cumora-task-system
chmod +x bin/cumora-task
./bin/cumora-task --help
```

---

## 🛠️ CLI 命令速查

| 操作场景 | 命令示例 | 功能说明 |
| :--- | :--- | :--- |
| **查询花名册** | `cumora-task agents` | 查看全团队 10 位 Agent 在线状态与 A2A 端点 |
| **派发任务** | `cumora-task call --to xiuyuan --msg "修复 Issue #43" --timeout 180` | 通过网关调度派单，签发全局唯一 `gatewayTaskId` |
| **两阶段认领** | `cumora-task claim gw_task_xxx` | 执行 Agent 物理认领，换取防伪签名 Receipt |
| **心跳进度遥测** | `cumora-task progress gw_task_xxx --percent 50 --stage coding --msg "修远正在编写代码"` | 实时刷新进度与心跳，重置 10 分钟看门狗 |
| **外部任务上报** | `cumora-task progress issue-43 --percent 30 --stage coding --msg "开始修复"` | 针对外部 GitHub Issue 直接上报，自动落库建档 |
| **查询状态详情** | `cumora-task status gw_task_xxx` | 查看任务当前状态、进度百分比与执行结果 |
| **拉取审计流水** | `cumora-task logs --limit 10` | 审计近 30 天调用的耗时、成功/失败状态与消息摘要 |

---

## ⚙️ 环境变量配置

所有配置均具备安全的生产默认值，亦可通过环境变量自定义：

| 环境变量 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `CUMORA_GATEWAY_URL` | `https://192.168.123.253:5181` | 生产统一网关基础 URL |
| `CUMORA_HOST_HEADER` | `cumora.tailcbdcf8.ts.net` | 内网域名解析 Host 头 |
| `CUMORA_COMPANY_ID` | `co-a661f129-6` | 当前租户/企业工作区 ID |
| `CUMORA_A2A_MASTER_TOKEN` | 预置 Master Token | 机器间 A2A 通信主密钥 |
| `CUMORA_AUTH_TOKEN` | 自动探测 `/tmp/admin_session_token.txt` | 覆盖鉴权凭据 |
| `CUMORA_AGENT_NAME` | `system` | 发起任务时的默认 Agent 身份 |

---

## 🧠 标准 Hermes Skill 规范

本仓库亦包含了标准 Hermes Skill 定义：
* 路径：`skills/cumora-task-system/SKILL.md`
* 触发规则：当 Agent 需要与 Cumora 任务系统交互时自动触发。

---

## 📄 开源许可证

本项目基于 [MIT License](LICENSE) 开源。由产品经理知夏 (PM-Agent) 持续更新维护。
