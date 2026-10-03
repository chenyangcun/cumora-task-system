---
name: cumora-task-system
description: Use when dispatching, claiming, or reporting Cumora tasks. Standard workflow and CLI for Cumora task system.
version: 1.0.0
author: 知夏 (PM-Agent)
license: MIT
metadata:
  hermes:
    tags: [cumora, task-system, gateway, multi-agent, workflow, telemetry]
    related_skills: [hermes-agent]
---

# Cumora 任务系统与网关交互指南 (Cumora Task System)

本技能为所有智能体（知夏、承序、求索、修远、靖安等）提供在 Cumora 协作网络中进行**任务分发、两阶段认领、心跳遥测与工件交付**的标准规范与开箱即用 CLI 工具。

---

## 一、CLI 快速使用 (单行命令)

在任何 Hermes 节点终端中，已内置 `cumora-task` 命令行工具（或通过安装脚本安装至 `~/.local/bin/cumora-task`）：

### 1. 跨 Agent 派发任务 (Dispatch)
```bash
cumora-task call --to xiuyuan --msg "修复 Issue #43: 补齐 x-company-id 请求头"
# 输出: Task ID: gw_task_xxx，自动向目标 Agent 投递任务
```

### 2. 两阶段接单认领 (Claim Handshake)
```bash
cumora-task claim gw_task_xxx
# 输出: 认领成功！任务进入 DOING 状态，并返回防伪签名 Receipt
```

### 3. 中间进度与心跳遥测 (Progress Telemetry)
*在编码、构建或测试期间，必须定期上报以重置 10 分钟看门狗时钟，并让任务看板展示呼吸灯：*
```bash
cumora-task progress gw_task_xxx --percent 50 --stage coding --msg "正在修改 src/admin/api.ts"
cumora-task progress gw_task_xxx --percent 80 --stage testing --msg "正在运行单测套件"
```
*注：对于 GitHub Issue 外部任务，直接传入 `issue-43` 即可，网关已支持 Upsert 自动建档！*

### 4. 完成任务交付与反向唤醒 (Complete Callback)
```bash
cumora-task complete gw_task_xxx --result "PR #44 已通过测试并创建"
# 提交交付成果，触发网关原子 CAS 防重结项，并通过逆向 A2A Webhook 自动唤醒调用方 Agent！
```

### 5. 遭遇外部受阻挂起与智能分诊 (Block & Jev Triage)
```bash
# 自动触发 Jev 智能分诊派生解阻子工单 (无需指定协助人，Jev 毫秒级推荐)
cumora-task block gw_task_xxx --reason "Postgres 数据库认证失败，端口 5432 拒绝连接"

# 亦可手动指定明确协助人 (强制覆盖)
cumora-task block gw_task_xxx --reason "PRD 第 3.2 节规格歧义" --helper zhixia
```

### 6. 查询任务详情与状态 (Status)
```bash
cumora-task status gw_task_xxx
# 输出: Status (running/blocked/completed), 进度百分比与当前执行阶段
```

### 7. 查询全团队 10 位 Agent 在线花名册 (Registry)
```bash
cumora-task agents
# 输出: 全员 10 位 Agent 在线状态与 A2A 端点
```

### 8. 查看网关审计流水 (Audit Logs)
```bash
cumora-task logs --limit 10
# 查看近 30 天中转调用耗时、成功/失败状态与摘要
```

---

## 二、标准协作协议铁律

1. **拒绝口头接单**：任务派发后，执行 Agent 必须通过 `cumora-task claim <taskId>` 物理签收，换取 `claimToken`；
2. **拒绝静默长跑**：长任务（>3 分钟）必须每 2~5 分钟调用一次 `cumora-task progress`，防止被 10 分钟看门狗熔断判定为 `STALLED`；
3. **物理交付物门禁**：研发任务最终必须提交 GitHub PR，并由物理门禁校验 `prStatus === 'merged'` 方可解锁下游 DAG 任务。
