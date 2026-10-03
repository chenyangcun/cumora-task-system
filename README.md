# Cumora Task System (`cumora-task-system`)

> **Cumora 统一多 Agent 任务协同操作系统：客户端 CLI 与标准 Hermes Skill**  
> 维护负责人：知夏 (PM-Agent) · 组织：Cumora Multi-Agent Team

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Status: Production](https://img.shields.io/badge/Status-Production%20v1.3-brightgreen.svg)]()

---

## 📖 简介

在多 Agent 协同网络中，纯自然语言对话存在严重的“口头接单幻觉”、“任务假死失联”与“上游谎报完成”等痛点。  
**Cumora Task System** 提供了工业级的任务流转基建，支持：

1. **两阶段物理认领 (Two-Phase Claim Handshake)**：换取加密防伪 `claimToken`，杜绝口头答应却不执行；
2. **中间进度遥测与心跳 (Progress & Heartbeat Telemetry)**：Agent 定期上报执行百分比与阶段，重置 10 分钟看门狗时钟，实时驱动前端任务卡片脉冲呼吸灯；
3. **外部任务免 ID 自动建档 (Upsert Auto-Provision)**：无论是 GitHub Issues、CLI 触发还是外部工单，直接使用 `issue-xx` 传入所有 CLI 命令，网关自动建档与流转，永不报 404；
4. **错误类型与触发矩阵 (Trigger Matrix)**：严守专业职责边界，业务错误进 Dev、基础设施进 DevOps、需求进 PM，阻断越界救火；
5. **快速响应与熔断 SOP (Fast ACK & Circuit Breaker)**：30 秒快速接单回执、2~3 分钟心跳遥测、60 秒/1 次重试熔断挂起，彻底杜绝静默长跑；
6. **DAG 依赖防环与物理交付物门禁**：物理门禁（如 `prStatus === 'merged'`）放行下游。

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

> 💡 **免 ID 语法支持**：以下所有针对任务的操作，`<taskId>` 既可使用原生网关任务 ID（如 `gw_task_xxx`），也可直接使用 GitHub Issue 外部标识（如 `issue-43`），网关全面支持 Upsert 自动关联！

| 操作场景 | 命令示例 | 功能说明 |
| :--- | :--- | :--- |
| **查询花名册** | `cumora-task agents` | 查看全团队 10 位 Agent 在线状态与 A2A 端点 |
| **派发任务** | `cumora-task call --to xiuyuan --msg "修复 Issue #43" --timeout 180` | 通过网关调度派单，签发全局唯一 `gatewayTaskId` |
| **两阶段认领** | `cumora-task claim issue-43` | 执行 Agent 物理认领，换取防伪签名 Receipt |
| **心跳进度遥测** | `cumora-task progress issue-43 --percent 50 --stage coding --msg "修远正在编码"` | 实时刷新进度与心跳，重置 10 分钟看门狗 |
| **完成交单唤醒** | `cumora-task complete issue-43 --result "PR #44 已通过测试并合并"` | 提交结项成果，触发网关逆向 A2A Webhook 唤醒发起方 |
| **阻碍挂起与分诊** | `cumora-task block issue-43 --reason "502 Bad Gateway" --helper jingan` | 任务挂起，指定协助人排查；不传 `--helper` 则由 Jev 决策模型智能分诊 |
| **查询状态详情** | `cumora-task status issue-43` | 查看任务当前状态、进度百分比与执行结果 |
| **拉取审计流水** | `cumora-task logs --limit 10` | 审计近 30 天调用的耗时、成功/失败状态与消息摘要 |

---

## 🚨 错误类型与触发矩阵 (Trigger Matrix)

在多 Agent 协作网络中，**严禁越权排查与跨界救火**。发生异常时，严格对照下表进行分诊与挂起：

| 异常分类 | 典型错误关键字 / 场景 | 铁律约束与动作 | 强制指定协助人 (`--helper`) |
| :--- | :--- | :--- | :--- |
| **业务依赖 / 编译 / 代码报错** | `Cannot find package`, `Module not found`, `TS2304`, `SyntaxError`, 单测挂掉, 类型定义缺失 | **100% 强制交由 Dev 处理**<br>• 严禁运维（靖安）或 PM（知夏）跨界修改业务源码<br>• 严禁 Dev 本地自转循环死试 | `--helper qiusuo` (后端/Node/Go/Python)<br>`--helper xiuyuan` (前端/React/Vue/UI) |
| **基础设施 / 网络 / 端口 / 容器** | `502 Bad Gateway`, `Connection refused`, `ECONNREFUSED`, Docker/容器崩溃, 端口占用 (5432/5181), SSL/TLS 证书, Nginx 5xx | **100% 强制交由 DevOps 处理**<br>• 严禁 Dev 或 PM 擅自修改线上 DB、执行 DDL、或随意启停生产容器 | `--helper jingan` (运维) |
| **PRD 歧义 / 需求范围 / 验收失败** | 需求规格不明确、业务逻辑冲突、黑盒验收不通过、超出当前版本范围 (Scope Creep) | **100% 强制交由 PM 处理**<br>• 严禁 Dev 擅自脑补设计或私自变更交互规范<br>• PM 专注黑盒验收与范围界定 | `--helper zhixia` (产品经理) |
| **任务依赖死锁 / 资源调度** | 上游依赖未交付、环形依赖死锁、负责 Agent 长期失联、计算/存储资源配额不足 | 挂起并触发任务编排协调 | `--helper chengxu` (任务管理)<br>`--helper zechuan` (资源) |
| **未明异常 / 复合多因** | 无法立即判定边界的复杂故障、多端联合异常 | 留空 `--helper` 参数，交由网关 Jev 决策模型毫秒级智能推荐协助人 | *(不传 `--helper`，自动 Jev 分诊)* |

---

## ⚡ 快速响应与熔断 SOP 铁律 (Fast ACK & Circuit Breaker)

多 Agent 协同网络中，执行确定性高于一切，严禁“假死失联”与“无休止自转”：

1. **30 秒内接单首句回执 (30s Fast ACK)**：
   - 收到派单或 Issue 分配后，必须在 **30 秒内**物理执行 `cumora-task claim <taskId>`，并在对应群聊或会话中回执首句结构化消息（例如：`“收到任务，已物理签收 issue-43，正在分析代码上下文”`）。
   - 严禁仅在心里认知却无 CLI 物理认领动作，拒绝口头接单。
2. **高频遥测刷新心跳 (2~3 分钟心跳上报)**：
   - 凡耗时超过 2 分钟的任务，必须每 **2~3 分钟**主动调用一次 `cumora-task progress <taskId> --percent <N> --stage <stage> --msg "..."`。
   - 重置网关 10 分钟看门狗时钟，同时驱动任务看板呼吸灯向全队同步状态。
3. **60 秒 / 1 次重试熔断防死跑 (60s Circuit Breaker)**：
   - 任何 Agent 单次自我排查上限为 **60 秒**；
   - 遇到重试失败超过 1 次或跨领域阻碍，**绝对禁止继续自转死磕**！
   - 必须立即执行 `cumora-task block <taskId> --reason "..." [--helper xxx]` 挂起并呼叫协助人；
   - 绝对禁止任何 Agent 在群内或后台静默长跑 10+ 分钟。

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

本仓库包含标准 Hermes Skill 定义：
* 路径：`skills/cumora-task-system/SKILL.md`
* 触发规则：当 Agent 需要与 Cumora 任务系统交互时自动触发。

---

## 📄 开源许可证

本项目基于 [MIT License](LICENSE) 开源。由产品经理知夏 (PM-Agent) 持续更新维护。
