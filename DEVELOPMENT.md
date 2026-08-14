# DEVELOPMENT.md · 深色设计风格收集库

> 开发者笔记:架构说明 + 关键问题一坑一篇。

## 架构总览

当前主页面 `dark-homepage-designs.html`(28 种深色主页风格);后续新主题各自独立 HTML + 同名 md 速查。

```
dark-homepage-designs.html
├── <style>  ── shell(顶栏/搜索/收藏) + 28 个 mk-* 主页模板 + fx 特效 + 延伸页区块 + 组件 + 信息区
└── <script>
    ├── CATS / STYLES      ── 风格数据(唯一数据源)
    ├── mockHTML(s)        ── 28 种主页模板(按 layout 分发)
    ├── extraHTML(s)       ── 6 种延伸页类型(通用区块拼装)
    ├── cmpHTML(s)         ── 组件样式
    ├── chipHTML(no,s)     ── 渲染整张卡片(预览全宽在上 + 参数双列在下)
    ├── renderCards / renderCompare ── 列表与速查表(过滤/搜索/收藏)
    └── 交互(复制/收藏/Tab 切换/分类筛选)
```

数据流:`STYLES` → `chipHTML` → 卡片;所有颜色/圆角/字体经 CSS 变量注入卡片作用域(`style="--bg:...;--accent:..."`),模板与延伸页消费同一套变量。

## 关键设计决策

### 1. 为什么预览是全宽主页图(而非缩略卡)
用户诉求是"做出主页设计才能体现风格"。因此每个风格的主页模板是 520px 高的完整页面稿(导航+hero+内容+页脚),`hero 占比`(ui.proportion)各不相同:全屏型(分屏/终端/HUD/电影)、沉浸型(玻璃/蒸汽波/深空/全息)、内容型(杂志/Bento/数据/书页)。

### 2. 怎么保证 28 种风格"不像换色"
按五维度差异化:①布局骨架 ②比例结构 ③组件形态 ④材质纹理 ⑤字体装饰。每种主页的模板 HTML 结构本身就不同(网格/报纸/砖块/分屏/终端/HUD/浮雕/几何/拱门/气泡/书页/金属/虹彩…),而不是同一模板换色板。

### 3. fx 特效系统
`fx` 字段 = 空格分隔的类名,挂到 `.tab-bodies`(包含首页+延伸+组件的容器),使同一套风格变量下的三视图都带上同一种"质感"(如 `glow` 发光、`scan` 扫描线、`aurora` 光斑、`noise` 噪点、`print` 纸纹、`stars` 星点、`glitch` RGB 错位)。若新特效想作用于延伸页,需显式扩展选择器(如 `.fx-brutal .mock-card`)。

### 4. 延伸页 = 通用区块 + 风格变量
6 种页面类型(features/dashboard/article/pricing/gallery/form)由区块(nav/hero/stats/chart/table/cards/quote/body/form/gallery/footer)拼装,区块全部用 `var(--xxx)`,因此换一套风格变量就是换一种视觉。这是"风格可迁移"的关键。

## 关键问题(一坑一篇)

### P1:数组/对象尾逗号
- `STYLES` 数组中非末位的对象必须以 `},` 结尾,否则 `}\n{` 报 `Unexpected token '{'`。
- 模板对象 `T` 的最后一个键无尾逗号;在其后插入新键时**必须先在原键后补逗号**(曾因此报 `Unexpected identifier 'vapor'`)。

### P2:模板标签平衡校验
`<i` 会误匹配 `<input>`(自闭合,无配对),导致误报。校验正则用 `<i[ >]`(带空格或 `>`),div/span 同理用 `<div[ >]`/`<span[ >]`。

### P3:脚本改文件的安全姿势
用 node 脚本做字符串替换时,`fail()` 分支要 `process.exit(1)` 且**在所有替换完成前不要 writeFileSync**——失败时磁盘文件保持原样,可安全重试。锚点正则必须按文件实际文本(如编号注释 `/* 20 数据大屏:指挥中心 */` 而非假设的 `/* ===== 数据大屏 ===== */`)。

### P4:proportion 注入
`ui.proportion`(hero 占比)由脚本按 id 注入到 `ui:{ proportion:'...', layout:... }` 开头,注入后出现双空格(`ui:{ proportion:'...',  layout:`),精确匹配字符串时注意。

### P5:删除一个风格要动五处
数据对象、`T` 模板、CSS 段(含编号注释重排)、选型指南、文案数字(如 "28 种")。漏一处就残留。

## 版本速查

- v1:23 种色板手册 → v4:按视觉语言重构 15 种 → v6:扩到 23 种 → v7:完整主页稿 → v9:等距=纪念碑谷 → v10:新增版式/效果类,共 28 种。
- 详见 CHANGELOG.md。
