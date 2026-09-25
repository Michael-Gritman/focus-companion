# Focus Companion · MVP

软件使用控制 App。保留原 Home 视觉，已打通本地业务与页面闭环。系统限制仍为 **Mock**，不会禁用设备上的其他 App。

## 运行

Flutter 3.47.1 / Dart 3.13.1。没有新增运行时第三方依赖。

```powershell
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5181
```

本机 SDK 不在 PATH 时：

```powershell
$flutter = 'C:/Users/admin/Documents/Codex/flutter-sdk-3.47.1/flutter/bin/flutter.bat'
# 只对当前 PowerShell 进程信任已检查的 SDK，不修改全局 Git 配置。
$env:GIT_CONFIG_COUNT = '1'
$env:GIT_CONFIG_KEY_0 = 'safe.directory'
$env:GIT_CONFIG_VALUE_0 = 'C:/Users/admin/Documents/Codex/flutter-sdk-3.47.1/flutter'
& $flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5181
```

已有静态预览地址为 http://127.0.0.1:5180/。端口被占用时换一个端口。

## 亲自跑通闭环

1. Home → 开始一次禁用 → 选择 TikTok 等模拟 App → 输入 30 分钟 → 开始模拟限制。
2. Active 页面显示 App、总时长、剩余时间和来源。首次时间池为零，提前解除会明确显示余额不足。
3. 返回 Home → Settings → 开发验证 → 模拟推进到本次结束。
4. 返回 Home → 查看完成结果：得到 30 分钟，可进入 Time Pool 查看余额和 earned 记录。
5. 再创建 20 分钟限制 → 提前解除 → 确认。按确认瞬间的剩余时长扣除，显示提前结束结果与 spent 记录。
6. Home → 设置 Rule / More → Rules：创建、编辑、启用或停用每日 Rule。开始结束使用 24 小时制 HH:mm。可以设置覆盖当前时间的时段，观察 Home 自动进入 ruleActive。

模拟推进只改变 MockClock；到期、奖励和扣款仍通过同一业务逻辑。正常等待、页面切换、恢复前台也按结束时间计算。

## 业务约束

- 一次只运行一个 RestrictionSession，Rule 是独立的重复计划。
- 正常完成：时间池增加 originalDuration，且只结算一次。
- 提前解除：余额必须大于等于当下 remainingDuration；平台结束成功后才按报价扣除。余额不足时不会调用平台解除。
- 金额以 Duration 的微秒精度保存；UI 展示到秒，解除费用向上显示、余额向下显示，实际扣除不做舍入。
- 关闭或编辑 Rule 只影响后续执行，不能绕过正在执行的限制。
- Rule 的同一每日 occurrence 不会因提前解除、开关切换或刷新重复启动。
- Rule 支持跨午夜。重叠时等当前限制结束；仍在时段内才执行剩余部分，只奖励实际安排的剩余时长。
- App 未运行时错过的整个 Rule 时段不会事后补发奖励。
- 结算先等待平台停止成功，再提交业务变更；失败保留原状态和余额，可重试。平台适配器按 session id 保证 start/stop 幂等。
- 奖励已在完成时入账；查看或重复打开结果页不会再次领取。

## 结构

```text
lib/
  app.dart                             装配、生命周期、底部导航与路由
  application/home_controller.dart     串行 Actions、每秒刷新、平台调用
  domain/home_state.dart               App 标识、Rule、Session、TimePool、流水、金币与结果
  domain/focus_domain.dart             调度、余额校验、幂等结算（纯 Dart）
  domain/restriction_platform.dart     RestrictionPlatform 与时钟接口
  platform/mock_restriction_platform.dart  模拟 App 目录、执行器、可推进时钟
  ui/home_page.dart                    保留原 Home，使用实际共享状态
  ui/restriction_setup_page.dart       局部 App 选择与时长表单
  ui/restriction_pages.dart            Active、提前解除、完成/解除结果
  ui/rules_pages.dart                  Rule 列表与创建/编辑
  ui/time_pool_page.dart               余额、流水、任务预览、兑换入口
  ui/secondary_pages.dart              Settings / More
  ui/components.dart / form_components.dart  复用组件与显示格式
  theme/focus_theme.dart              可替换设计 tokens
```

共享状态只有一个 FocusDomain，由原有 ChangeNotifier 方案对 UI 发布不可变快照。表单、输入控制器、选中 App 与当前 tab 留在页面本地。

## 当前边界

- Mock Platform 和 mock App 标识；尚未接入真实 App Picker / iOS / Android 屏蔽能力。
- 使用内存数据：刷新、关闭后重置规则、余额、会话与流水。没有持久化或后台 OS 调度。
- 已启动会话恢复前台后按时钟结算；新 Rule 只在运行/恢复时检查，不声称后台已限制。
- 时间池和金币从零开始。金币兑换仅有 UI 与 TimeCoinExchange 报价接口；未指定产品比例，不实际兑换。
- 每日/每周任务和成长信息是明确标注的静态预览，不参与结算。
- 没有角色、Rive、商城、Backend、Auth、云同步或复杂反馈系统。
- Android / iOS 保留基础宿主。本次构建验收使用 Web；未声称完成手机真机验证。
- 本地字体覆盖当前 UI 与 GB2312 常用汉字；更罕见字符由 Flutter 后备字体处理，详见 assets/fonts/README.md。

## 检查

```powershell
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
```

自动测试覆盖用户指定的三条余额规则、精确边界、重复结算、平台失败与并发、跨午夜调度、Rule 编辑、完整页面流、多个屏宽与大字号。验收记录见 docs/mvp-verification.md。

下一步：在目标手机平台验证最小真实 App Blocking 适配器（授权、选择 App、开始和解除、执行状态核对）。
