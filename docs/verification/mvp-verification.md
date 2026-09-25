# Focus MVP 验收记录

日期：2026-09-08。Windows / Flutter 3.47.1 / Dart 3.13.1。

## 自动验证

- flutter test：53 项测试全部通过。
- flutter analyze：No issues found。
- 格式检查覆盖 lib / test：20 个文件，0 个需要调整。
- Web release 构建成功：flutter build web --no-web-resources-cdn（最终构建 62.4 秒）。

测试分为 14 项纯 Domain 测试、8 项 Application / Mock Platform 测试、30 项 UI / 导航 / 布局测试、1 项显示精度回归测试。

指定余额案例全部通过：

| 场景 | 结果 |
| --- | --- |
| 初始 60 分钟，成功完成 30 分钟 | 90 分钟 |
| 初始 40 分钟，提前解除时剩余 20 分钟 | 20 分钟 |
| 初始 10 分钟，剩余 20 分钟尝试解除 | 拒绝，仍为 10 分钟且 Session Active |

额外覆盖：精确相等与微秒边界、到期与提前解除竞争、重复结算与旧 Session 重放、平台 start/stop 失败、并发点击、跨午夜与跨月、每日 Rule 防重复触发、编辑/停用不解除现有 Session、重叠规则与迟到启动不补发过去时间。

UI 测试已走通：

- Home → Setup → Active → Completion Result → Time Pool。
- Home → Setup → Active → Early Exit → Early Exit Result → Home。
- 余额不足时确认按钮禁用。
- Rule 创建 → 编辑 → 自动运行 → 停用后当前 Session 继续。
- Settings 模拟时钟通过相同 Domain 结算。
- 兑换入口不改变余额或金币。
- 四种 Home 状态 × 320 / 360 / 390 / 430 / 1280 宽度。
- Setup / Rule / Active / Early Exit / Time Pool 的 320 宽度与 1.5 倍文字。

## 修正记录

- 保留原 Home、Theme、组件和导航基础；替换旧场景选择器及只读 MockHomeSource。
- 结算使用报价 → 平台停止成功 → Domain 提交，避免失败扣款或入账。
- 以唯一 Session 与每日 occurrence 防止重复结算和重新触发。
- 改善窄屏 Home 标题；扩充常用中文字库支持自定义 Rule 名称。
- 浏览器验收发现小数秒直接截断会让显示金额看似差 1 秒；非整秒值标注“约”，Domain 仍按完整精度结算。
- 修正 UI 测试的嵌套滚动定位，并等待输入框焦点稳定后再点击保存。

## 浏览器验收

使用本地 release Web 页面、390 × 844 手机视口，实际点击走通：

- Home → 选择 TikTok / 30 分钟 → 开始 → Active；Home 切换为正在限制的主视觉。
- 时间池为零时，提前解除显示余额不足且确认按钮禁用。
- Settings 模拟推进到结束 → Home 完成事件 → 结果 +30 分钟 → Time Pool 余额 30 分钟及一条完成流水。
- 再创建 15 分钟限制 → 提前解除 → 确认扣款 → 结果 → Time Pool；存在一条收入和一条支出，无提前解除奖励。
- 以上流程捕获的 window error / unhandledrejection 均为空，未请求 Google Fonts。

截图保存在本地忽略目录 .dart_tool/mvp-*.png；Rule CRUD、调度、各宽度与大字号的详细验收由上述自动测试覆盖。

## 产品边界

仍是 Mock 系统执行与内存状态；未构建或验收 Android / iOS 真机。不声称后台真实阻止了其他 App。金币兑换、任务奖励、连续记录/成就、持久化与真实平台适配有意延后。

## Constitution

两份文件均未修改，SHA-256 与开始时一致：

- Product：05D506EB5B498EA9C6ACF030E95765DE4EF59905C88BA092C888042CDE08C3CB
- Design：DCADF3AB3A94FD2B89CCF5387BB644E50E2C87952DB64B06ADD23A5EDFB26460
