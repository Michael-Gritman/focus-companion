# Home MVP 验证记录

这是第一阶段 Home 页的历史记录。当前完整 MVP 的验证见 [mvp-verification.md](mvp-verification.md)。

日期：2026-09-08。环境：Windows，Flutter 3.47.1 / Dart 3.13.1。

## 结果

- `flutter analyze`：No issues found。
- `flutter test`：21 项全部通过。
- `flutter build web --no-web-resources-cdn`：成功生成 `build/web`。
- `dart format --output=none --set-exit-if-changed lib test`：12 个文件，无待格式化变更。
- 实际浏览器：本地 Web 构建能打开，检查了无 Rule、待机与运行态；主 CTA 可打开 Setup 并返回，Settings 可切换场景。
- 浏览器检查了 390 × 844 和 320 × 740；窄屏内容可换行、滚动，底部导航保留。
- 最终构建的 Home / Setup / 运行态检查未捕获 JS error 或 unhandled rejection；阻断外部字体服务时中文正常，当前页面外部字体请求为 0，本地 FocusUI 字体已加载。
- 首轮发现卡片背景遮挡 ListTile 点击反馈，改用 Material 后通过；外部字体阻断检查发现 FilledButton 字体未继承，补上集中字体 token 后通过。

## 测试范围

- Rule 跨夜时间与关闭状态；临时 Session 不依赖 Rule；开始与结束时间边界。
- 场景重置、跨后台的时间推进、到期不伪造奖励与余额。
- Home → Setup / Rules / Settings / 当前限制详情，及三项底部导航。
- 三种状态 × 320 / 360 / 390 / 430 / 1280 宽度。
- 320 宽度下 1.5 倍文字；未来事件卡的条件展示与回调。

## Constitution 完整性

开始与结束时 SHA-256 相同：

- Product：`05D506EB5B498EA9C6ACF030E95765DE4EF59905C88BA092C888042CDE08C3CB`
- Design：`DCADF3AB3A94FD2B89CCF5387BB644E50E2C87952DB64B06ADD23A5EDFB26460`

## 验证边界

此次验证的是 Web 构建与模拟状态；未做 Android / iOS 真机构建、真实系统 App Blocking 或持久化验证。Setup、Rule 编辑、Time Pool、奖励与赎回逻辑仍按任务范围保留占位。
