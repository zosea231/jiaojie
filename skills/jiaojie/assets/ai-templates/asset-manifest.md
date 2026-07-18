# Asset Manifest（生成资产清单）

> 图片、视频等非代码产出物的完整留痕与验收记录。输出统一放在
> `assets/generated/`；自动检查只负责存在性、格式和规格，内容质量由审查者记录。

## 状态约定
- `pending`：已分配或已生成，等待审查
- `accepted`：内容验收通过
- `rejected`：已打回，理由记录在本条目中

## 资产记录

暂无记录。生成资产时复制下面的模板，并保留完整 prompt；不能用对话链接或摘要
代替 prompt 正文。

### ASSET-YYYYMMDD-NN
- 生成 Agent：
- 资产类型：`image` / `video` / `other`
- 输出路径：`assets/generated/<filename>`
- 规格来源：`.ai/plan.md` 中的章节或明确尺寸、格式、时长要求
- 自动检查：`pending` / `passed` / `failed`（附结果）
- 验收状态：`pending` / `accepted` / `rejected`
- 审查者：
- 验收意见：

#### 完整生成 prompt

```text
在此保存交给生成 Agent 的自包含 prompt，包括必要上下文和验收标准。
```
