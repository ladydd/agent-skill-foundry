# Agent Meta-Skill（Agent 入口）

完整指令请阅读 `INSTRUCTIONS.md`。

## 概要

本 skill 用来把需求说明、样例数据、旧脚本或运行日志产品化成成熟 Agent skill。重点是拆清楚 agent、CLI、可选远程能力和最终 artifact，而不是只写提示词。

## 关键边界

- 先读需求和样例，再设计，不要直接编码。
- 确定性计算、清洗、校验、HTML 生成优先放 CLI。
- agent 只做流程编排、语义判断、公开网页证据整理。
- Go CLI 默认打四个平台二进制到 `tools/bin/`。
- 公开文档不得暴露私有实现细节、敏感配置、真实凭据或内部服务路径。
- 必须做真实 agent 测试，不能只靠本地 CLI 成功。

## 优先动作

1. 读取 `INSTRUCTIONS.md`。
2. 根据当前任务读取对应 reference。
3. 如果要创建新 skill，先定目录和架构，再写文件。
4. 如果要验收已有 skill，按 `references/qa-release-checklist.md` 检查。
