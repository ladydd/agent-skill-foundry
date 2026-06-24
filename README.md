# Agent Meta-Skill

把一个模糊的需求、想法或旧流程，锻造成可运行、可验证、可分发的 Agent Skill。

这是一个 meta-skill：用 skill 的形式，沉淀如何设计、实现、打包、验收其它 Agent Skills。

这个仓库不是业务模板，也不是提示词合集。它沉淀的是一套工程方法：如何把“让 agent 做一件复杂事”变成稳定的软件交付。

## 为什么需要它

很多 agent workflow 一开始都很顺：写提示词、跑样例、看起来能用。真正的问题通常出现在交付之后：

- 用户换一台机器就跑不起来。
- 依赖 Python 环境、相对路径、隐藏模块，打包后缺文件。
- agent 临时手算指标，下一次结果就变了。
- HTML 看板是临时拼出来的，数字追不回原始数据。
- 多阶段任务找错上一次的目录。
- 本地源码、运行产物、用户包、远程部署混在一起。
- 私有能力、账号、上游接口或内部路径不小心写进了公开文档。

Agent Meta-Skill 的目标，是把这些坑提前变成结构、契约和检查脚本。

## 核心主张

1. Agent 负责编排和判断，不负责手算核心结果。
2. CLI 负责确定性：输入识别、清洗、计算、校验、渲染。
3. 每次运行必须创建独立目录，所有过程文件可追溯。
4. HTML 是产品界面，不是日志转储，也不是聊天内容的复制。
5. 多 Skill 接力必须靠显式 `PROJECT_ROOT`，不能靠“最新目录”。
6. 用户包、开发源码、远程部署、运行产物必须分层。
7. 公开包不能暴露任何私有实现细节。

一句话：让 agent 保持聪明，但让交付结果可复现。

## 适合做什么

- 从需求说明、样例文件或旧流程设计一个新的 Agent Skill。
- 把旧脚本整理成可分发的 Skill。
- 把原型迁移成跨平台 Go CLI。
- 设计离线 HTML 报告和 `report_data.json`。
- 设计多阶段 Skill 接力。
- 验收一个 Skill 是否能交给真实用户。
- 检查公开包里有没有混入源码、运行目录、私有配置或旧二进制。

## 标准形态

一个成熟 Skill 通常由四层组成：

```text
Agent instructions
  -> local deterministic CLI
  -> optional remote enrichment capability
  -> offline artifacts and trace files
```

对应目录边界：

| 分发表面 | 放什么 | 不放什么 |
| --- | --- | --- |
| Runtime skill package | `SKILL.md`、`INSTRUCTIONS.md`、`references/`、`tools/bin/`、runtime assets | Go 源码、需求草稿、真实样例、运行产物、私有配置 |
| Development source repo | 需求说明、Go 源码、测试、build 脚本、合成样例 | 真实凭据、未脱敏用户数据 |
| Remote capability deployment | 私有远程能力、路由、上游账号配置、运维配置 | 公开文档、用户 HTML、开源包 |
| Generated run/project output | HTML、JSON、CSV、XLSX、manifest、trace files | 源码、安装包、部署配置 |

## 运行目录原则

单次执行结束的 Skill，使用 `RUN_DIR`：

```text
domain_report_YYYYMMDD_HHMMSS/
  01_input_manifest.json
  02_cleaned_data.json
  03_analysis.json
  report_data.json
  final_report.html
```

多阶段接力的 Skill，使用 `PROJECT_ROOT`：

```text
project_YYYYMMDD_HHMMSS/
  project_manifest.json
  stage_one/
  stage_two/
```

上游最终回复必须明确输出：

```text
本次项目目录：<absolute_project_dir>
PROJECT_ROOT=<absolute_project_dir>
```

下游只能从当前上下文读取 `PROJECT_ROOT`。如果缺失，就停止；不能扫描本地目录找“最新项目”。

## Go CLI 分发原则

如果 Skill 要给真实用户跑，且涉及文件解析、计算、校验或 HTML 生成，优先做 Go CLI。

标准四平台产物：

```text
tools/bin/<cli-prefix>-linux-amd64
tools/bin/<cli-prefix>-darwin-amd64
tools/bin/<cli-prefix>-darwin-arm64
tools/bin/<cli-prefix>-windows-amd64.exe
```

macOS 首次运行提示：

```bash
xattr -dr com.apple.quarantine ./tools/bin 2>/dev/null || true
chmod +x ./tools/bin/<cli-prefix>-darwin-amd64 ./tools/bin/<cli-prefix>-darwin-arm64 2>/dev/null || true
```

## HTML 报告原则

HTML 必须从结构化数据渲染：

```text
source files
  -> cleaned JSON
  -> analysis JSON
  -> report_data.json
  -> fixed HTML template
```

要求：

- 单文件离线打开。
- 图表、表格、结论能追溯到过程文件。
- agent 判断必须留下 workspace 和 output。
- 可选联网证据只能辅助解释，不能覆盖结构化数据。
- 修改模板后必须重新生成真实 HTML，而不是只看模板源码。

## 自带检查

```bash
scripts/check_skill_package.sh <skill_dir> [cli-prefix]
scripts/check_forbidden_terms.sh <skill_dir_or_run_dir>
scripts/check_run_artifact.sh <run_or_project_dir>
```

这些检查用于发现：

- `tools/bin` 多余文件、缺失四平台二进制、不可执行文件。
- 不应公开的文本、异常编码、私有路径、可疑凭据。
- HTML 产物缺少 `report_data.json`、JSON 不可解析、加载外部运行资源。

## 如何使用

把仓库作为一个 Skill 目录放到你的 agent runtime skills 目录中：

```bash
mkdir -p ~/.agent/skills
cp -R agent-meta-skill ~/.agent/skills/
```

如果你的运行环境使用不同的 skills 目录，把它复制到对应位置即可。

然后让 agent 使用 `agent-meta-skill` 来设计、实现或验收新的 Skill。

## 这个项目不包含什么

- 业务代码
- 私有远程服务实现
- 真实用户数据
- 真实凭据
- 上游账号细节
- 运行产物

它只公开方法、契约和检查工具。

## License

MIT
