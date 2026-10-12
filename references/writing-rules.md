# 项目写作规则

本规则将 [Kiterlin/anti-defensive-writing](https://github.com/Kiterlin/anti-defensive-writing) 集成到 Jiaojie 的文档维护和交付流程。完整技能内置在 [anti-defensive-writing.md](anti-defensive-writing.md)，起草／修改正文时读取，许可见 [anti-defensive-writing.LICENSE](anti-defensive-writing.LICENSE)。初始化后这些文件可离线使用。

内置原文取自 2026-10-12 读取的 [上游版本](https://github.com/Kiterlin/anti-defensive-writing/blob/c7edf8fc91ae9c4f7e58345bd12934bb4cf41c46/SKILL.md)，许可 Copyright (c) 2026 Kiterlin。原文单独保留，项目扩展写在本文件。

- 先讲问题、方法、结果和判断。直接说明做了什么、证据支持什么、下一步是什么。
- 删除不提供事实、范围、推理或使用条件的免责、道歉、反复自我否定和层层保留。
- 用具体条件界定结论；保留影响准确性、方法理解、安全、法律、伦理及读者使用的限制。重要限制在相关结论附近说明一次。
- 保留影响核心结论的不利结果；说明条件、指标、实际变化。原因未知就如实说明，不编造解释，也不把一个指标落后泛化为方法失败。
- 区分已证实问题、待核实疑问和可选改进，不把每个假想审查意见变成任务或前置条件。
- 使用自然中文和领域通用术语，必要术语首次简释。用户采用稿及 `.ai/writing-preferences.md` 中的偏好优先。

## 最终产物及包装

遵守 AGENTS.md 的“写作与最终产物”条款。标题、文件名、正文、注释、标签、commit、PR、交付说明、元数据和 hook 改写均面向没看过会话的读者，从最终目标和实际结果重新组织。会话中的否决与措辞纠正仅用于控制本次工作。

按每个交付面的需要保留真实的基线变化、外部操作、技术名称、诊断、测试、快照和兼容性信息。阅读全部最终内容，内容发生变化后重新核对。文档核对使用判断，不建立关键词门禁。
