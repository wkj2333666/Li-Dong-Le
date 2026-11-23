# Windows 环境准备

## 适用机器

- 64 位 Windows 10/11。
- Intel VT-x 或 AMD-V 已在 BIOS 开启。
- 建议至少 16 GB 内存和 20 GB 可用 SSD 空间。
- 当前适配目标是 Intel/AMD x86_64 Windows；Windows ARM 不在验证范围内。

## 安装软件

安装以下组件：

1. 64 位 Python 3.11 或更高版本，并确认 `py -3` 可用。
2. Android Studio。
3. Android SDK Command-line Tools。

在 Windows 功能中启用 **Windows Hypervisor Platform**，然后重启。Android Emulator 在 Windows 上使用 WHPX 加速；不要同时关闭 Hyper-V 又依赖 WHPX。

## 创建 AVD

在仓库根目录打开 PowerShell：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\setup-windows.ps1
```

脚本安装以下 SDK 包：

- `platform-tools`
- `emulator`
- `platforms;android-30`
- `system-images;android-30;google_apis;x86_64`

首次执行会创建名为 `ldl_win_x64` 的 AVD，重复执行会复用已有实例。启动时会检查 Android API 30、x86_64 和 `adb root`。如果已有实例的镜像不兼容，请先备份数据，再按 [迁移说明](WINDOWS-DATA.md) 手动重建。

`ldl-windows.ps1` 会为项目的 Python 虚拟环境安装 Frida、证书包和 `tzdata`，支持 Python 3.11 及以上。

## 准备 APK

将已获得的两个 APK 放在：

```text
apks\ledongli.apk
apks\wechat-official-arm32.apk
```

推荐直接下载并校验：

```powershell
py -3 deploy\fetch_apks.py
py -3 deploy\fetch_apks.py --verify-only
```

默认 ARM64 部署使用仓库已有的 Git LFS APK。这条 Windows 路线另外下载 ARM32 微信包。请勿提交本机下载的兼容包、登录态、Cookie 或 `private\` 目录。
