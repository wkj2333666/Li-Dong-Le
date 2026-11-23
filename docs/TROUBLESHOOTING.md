# 故障排查

## 宿主检查失败

`./ldl doctor` 用于 ARM64，`./ldl-x86 doctor` 用于 x86_64 Linux。两条路线都需要 4 KiB 页、binderfs、DMA-BUF heap、IPv6 和可用的 Docker/Compose。缺少 `binder_linux` 时先确认当前内核是否提供对应模块，再由管理员加载。

## 下载与构建网络

APK 下载器支持 Python 标准 `HTTP_PROXY` / `HTTPS_PROXY` 环境变量，下载完成后校验固定 SHA256。也可把完全相同的原版包放入 `apks/` 后运行 `python3 deploy/fetch_apks.py --verify-only`。

Docker 拉取镜像和构建步骤可能用不同的代理配置。可提前拉取基础镜像。需要替换 Android 镜像时，ARM64 使用 `REDROID_IMAGE`，x86_64 使用 `LDL_X86_IMAGE`。请先核对本地镜像标签对应的摘要。

容器构建步骤中的 `127.0.0.1` 指向构建环境。需要构建代理时，请传入构建环境可达的代理地址。不要把含凭据的代理 URL 提交到仓库。

## 页面打不开或只看到 Android 桌面

- ARM64 用 `docker compose ps` 检查，控制台默认端口 6080。x86_64 用 `./ldl-x86 compose ps`，控制台默认端口 16080。
- 远程访问需要保持 SSH 转发运行；`localhost` 指的是当前打开浏览器的电脑。
- 页面若显示桌面，点击“打开微信”或“打开乐动力”。
- 应用退出时查看宿主剩余内存、`docker stats`、Android `dumpsys activity exit-info` 和 `logcat -b crash`。日志可能含个人信息，不要直接公开。

## 微信崩溃或无法登录

确认安装的是 ARM32 8.0.42，且 Android 使用匹配的 Android 12 / Houdini 配置。原仓库 ARM64 微信在本次 x86 环境验证失败。出现版本更新要求、授权失败或账号验证时，需要按应用实际页面处理；本项目不保证旧版本永久可用。

## 兼容层未就绪

确认乐动力版本为 10.14.2 / 10092，运行 `./ldl compatibility` 后重新打开乐动力。`./ldl status` 的 `network_compat.ready` 只代表当前进程的网络兼容钩子就绪，不代表账号登录或作业完成。

## 今天不能再次执行

查看 `./ldl check` 的服务端结果和当天本地回执。每日上限来自本人作业，本地额外按北京时间日期限制一次成功记录。等待下一允许时段，不要清除回执绕过防重复。
