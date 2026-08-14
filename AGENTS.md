# AGENTS.md · 深色设计风格手册

> 给 AI / 未来的你:先读这个文件再动手改。

**文档基线**:2026-08-15(首次发布)。

## 技术栈

- 纯 HTML + CSS + JS,**零依赖、零构建**。一个 `index.html` 完成全部。
- 无 npm / 无框架 / 无 CDN;字体用系统栈(sans/serif/mono)。
- 浏览器要求:支持 `color-mix()`、`clip-path`、`backdrop-filter`、`background-clip:text`(现代 Chrome/Edge/Firefox 即可)。

## 核心架构(数据驱动)

1. **`STYLES` 数组**(脚本顶部)= 全部风格数据。每项含:
   - `layout` — 主页模板键(mockHTML 的 `T` 对象里的键名)
   - `extra` — 延伸页类型(`features/dashboard/article/pricing/gallery/form`)
   - `vars` — CSS 变量(`--bg/--elev/--inset/--border/--text/--dim/--accent/--accent2/--accent3/--radius/--font`)
   - `ui` — 界面要点(含 `proportion` hero 占比,展示于速查表)
   - `palette` — 色板(名称+hex,点击复制)
2. **`mockHTML(s)`** — 按 `s.layout` switch 出 28 种**互不相同**的主页模板(`mk-*` 类)。
3. **`extraHTML(s)`** — 通用区块(导航/hero/统计/图表/表格/卡片/引文/表单/画廊/页脚)拼装延伸页,区块全部用风格 CSS 变量自适应。
4. **`cmpHTML(s)`** — 组件样式预览(按钮/输入/开关/徽章/进度条)。
5. **fx 系统** — `fx` 字段声明特效类(`glow/grid/scan/aurora/stars/noise/print/glitch/brutal/neumorph/term/glass`),挂在 `.tab-bodies` 上,同时作用于首页/延伸页/组件。

## 约定

- **风格 = 布局/比例/材质/字体/装饰的差异,不是换色**。新增风格必须先想清楚布局骨架与别的风格不同。
- 每个 `layout` 键必须有唯一主页模板;每个风格必须有 `extra`。
- 模板 HTML 标签必须平衡(div/span/i 配平);校验脚本会查。
- 文案中文化;色板值用 hex 或 rgba。
- 卡片布局:`sc-preview`(全宽主页图在上)+ `sc-info`(参数双列在下)。

## 如何新增一种风格(清单)

1. `STYLES` 数组追加对象(`id/name/en/cat/layout/extra/tags/desc/traits/font/cases/refs/fx/onAccent/ui/vars/palette`)
2. `mockHTML` 的 `T` 对象追加 `layout` 模板(注意:上一个键若没有尾逗号要补 `,`)
3. `<style>` 追加 `mk-{layout}` CSS 段(编号注释递增)
4. 选型指南 `<ul>` 相应提及
5. `CHANGELOG.md` 追加;`README.md` 总览表同步;`AGENTS.md` 基线日期更新
6. 校验:`node` 提取 `<script>` 跑 `new Function()` 查语法 + 模板标签平衡

## 关键坑(一坑一条)

- 数组元素之间漏逗号 → `Unexpected token`。新增对象若在数组中间,结尾要 `},`。
- 模板对象 `T` 的**最后一个键无尾逗号**,后面再插入键必须先补逗号。
- 校验模板平衡时 `<i` 会误匹配 `<input`,要用 `<i[ >]`。
- `color-mix()`/`clip-path` 的浏览器兼容按现代内核处理,不做降级。
- fx 类若同时想作用于延伸页,需要在 CSS 里显式加 `.ex-*`/`.mock-*` 选择器。
- 删除风格时,数据对象、`T` 模板、CSS 段、选型指南、文案数字(如 28 种)五处要一起改。

## 常用命令

无构建。校验语法:`node -e "new Function(require('fs').readFileSync('index.html','utf8').match(/<script>([\s\S]*?)<\/script>/)[1])"`
