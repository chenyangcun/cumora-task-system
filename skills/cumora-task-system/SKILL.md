---
name: cumora-task-system
description: Use when dispatching, claiming, or reporting Cumora tasks. Standard workflow and CLI for Cumora task system.
version: 1.1.0
author: 知夏 (PM-Agent)
license: MIT
metadata:
  hermes:
    tags: [cumora, task-system, gateway, multi-agent, workflow, telemetry, triage]
    related_skills: [hermes-agent]
---

# Cumora 任务系统与网关交互指南 (Cumora Task System)

本技能为所有智能体（知夏、承序、求索、修远、靖安等）提供在 Cumora 协作网络中进行**任务分发、两阶段认领、心跳遥测、异常熔断与工件交付**的标准规范与开箱即用 CLI 工具。

---

## 一、免 ID 语法与任务标识规则 (Task ID & Upsert)

为打通 GitHub Issue 与内部网关任务生命周期，系统全面支持**外部免 ID 语法**：
1. **GitHub Issue 外部任务**：无需预先查询网关内部 ID，直接使用 `issue-<编号>`（如 `issue-43`）作为 `<taskId>` 传入所有 CLI 子命令（`claim` / `progress` / `block` / `complete` / `status`）。
2. **网关自动建档 (Upsert)**：首次针对 `issue-xx` 上报进度或执行认领时，网关底层将自动创建/关联对应任务卡片，永不报 404。
3. **原生内部任务**：通过 `cumora-task call` 动态派发的任务，直接使用返回的 `gw_task_xxx` 标识。

---

## 二、CLI 核心命令速查

在任何 Hermes 节点终端中，已内置 `cumora-task` 命令行工具（或通过 `~/.local/bin/cumora-task` 访问）：

### 1. 跨 Agent 派发任务 (Dispatch)
```bash
cumora-task call --to xiuyuan --msg "修复 Issue #43: 补齐 x-company-id 请求头"
# 输出: Task ID: gw_task_xxx，自动向目标 Agent 投递任务
```

### 2. 两阶段接单认领 (Claim Handshake)
```bash
cumora-task claim gw_task_xxx
# 或直接认领外部 GitHub Issue:
cumora-task claim issue-43
# 输出: 认领成功！任务进入 DOING 状态，并返回防伪签名 Receipt
```

### 3. 中间进度与心跳遥测 (Progress Telemetry)
*在编码、构建或测试期间，必须定期上报以重置 10 分钟看门狗时钟，并让任务看板展示呼吸灯：*
```bash
cumora-task progress issue-43 --percent 50 --stage coding --msg "正在修改 src/admin/api.ts"
cumora-task progress issue-43 --percent 80 --stage testing --msg "正在运行单测套件"
```

### 4. 遭遇受阻挂起与协助人分诊 (Block & Triage)
```bash
# 场景 A: 命中触发矩阵，指定具体责任人挂起
cumora-task block issue-43 --reason "502 Bad Gateway: 统一网关端口 5181 拒绝连接" --helper jingan
cumora-task block issue-43 --reason "TS2304: Cannot find name 'AdminPayload' 编译失败" --helper qiusuo
cumora-task block issue-43 --reason "PRD 第 3.2 节关于租户隔离的规格歧义" --helper zhixia

# 场景 B: 复合或未明错误，留空触发 Jev 智能分诊派生解阻子工单
cumora-task block issue-43 --reason "第三方 Webhook 鉴权偶发性失败，需联合定位"
```

### 5. 完成任务交付与反向唤醒 (Complete Callback)
```bash
cumora-task complete issue-43 --result "PR #44 已通过测试并合并"
# 提交交付成果，触发网关原子 CAS 防重结项，并通过逆向 A2A Webhook 自动唤醒调用方 Agent！
```

### 6. 查询任务详情与状态 (Status)
```bash
cumora-task status issue-43
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

## 三、错误类型与触发矩阵 (Trigger Matrix)

在多 Agent 协作网络中，**严禁越权排查与跨界救火**。发生异常时，严格对照下表进行分诊与挂起：

| 异常分类 | 典型错误关键字 / 场景 | 铁律约束与动作 | 强制指定协助人 (`--helper`) |
| :--- | :--- | :--- | :--- |
| **业务依赖 / 编译 / 代码报错** | `Cannot find package`, `Module not found`, `TS2304`, `SyntaxError`, 单测挂掉, 类型定义缺失 | **100% 强制交由 Dev 处理**<br>• 严禁运维（靖安）或 PM（知夏）跨界修改业务源码<br>• 严禁 Dev 本地自转循环死试 | `--helper qiusuo` (后端/Node/Go/Python)<br>`--helper xiuyuan` (前端/React/Vue/UI) |
| **基础设施 / 网络 / 端口 / 容器** | `502 Bad Gateway`, `Connection refused`, `ECONNREFUSED`, Docker/容器崩溃, 端口占用 (5432/5181), SSL/TLS 证书, Nginx 5xx | **100% 强制交由 DevOps 处理**<br>• 严禁 Dev 或 PM 擅自修改线上 DB、执行 DDL、或随意启停生产容器 | `--helper jingan` (运维) |
| **PRD 歧义 / 需求范围 / 验收失败** | 需求规格不明确、业务逻辑冲突、黑盒验收不通过、超出当前版本范围 (Scope Creep) | **100% 强制交由 PM 处理**<br>• 严禁 Dev 擅自脑补设计或私自变更交互规范<br>• PM 专注黑盒验收与范围界定 | `--helper zhixia` (产品经理) |
| **任务依赖死锁 / 资源调度** | 上游依赖未交付、环形依赖死锁、负责 Agent 长期失联、计算/存储资源配额不足 | 挂起并触发任务编排协调 | `--helper chengxu` (任务管理)<br>`--helper zechuan` (资源) |
| **未明异常 / 复合多因** | 无法立即判定边界的复杂故障、多端联合异常 | 留空 `--helper` 参数，交由网关 Jev 决策模型毫秒级智能推荐协助人 | *(不传 `--helper`，自动 Jev 分诊)* |

---

## 四、快速响应与熔断 SOP 铁律 (Fast ACK & Circuit Breaker)

多 Agent 协同网络中，执行确定性高于一切，严禁“假死失联”与“无休止自转”。所有 Agent 必须无条件遵守以下三条 SOP 铁律：

### 1. 30 秒内接单首句回执 (30s Fast ACK)
- **动作要求**：收到 A2A 派发通知或 GitHub Issue 指派后，必须在 **30 秒内**物理执行 `cumora-task claim <taskId>`，同时在对应群聊或会话中回执首句结构化消息（例如：`“收到任务，已物理签收 issue-43，正在分析代码上下文”`）。
- **红线**：严禁仅在心里认知却无 CLI 物理认领动作，拒绝口头接单。

### 2. 高频遥测刷新心跳 (2~3 分钟心跳上报)
- **动作要求**：凡耗时超过 2 分钟的任务，执行 Agent 必须每 **2~3 分钟**主动调用一次 `cumora-task progress <taskId> --percent <N> --stage <stage> --msg "..."`。
- **机制保障**：
  - 重置网关 10 分钟看门狗时钟，避免被系统误判为 `STALLED` 并强杀；
  - 实时驱动任务看板呼吸灯，向全队同步当前子阶段（如 `analyzing`, `coding`, `testing`, `verifying`）。

### 3. 60 秒 / 1 次重试熔断防死跑 (60s Circuit Breaker)
- **动作要求**：
  - 任何 Agent 在本地编码或调试遭遇错误时，**单次自我排查上限为 60 秒**；
  - 遇到重试失败超过 1 次，或者遭遇任何跨领域阻碍（如网络不通、缺包未装、规格不明），**绝对禁止继续自转死磕**！
  - 必须立即执行 `cumora-task block <taskId> --reason "..." [--helper xxx]` 将任务挂起，并根据触发矩阵呼叫对口协助人。
- **红线**：绝对禁止任何 Agent 在群内或后台静默长跑 10+ 分钟（避免锁死单轮推理队列并触发下游级联阻塞）。
