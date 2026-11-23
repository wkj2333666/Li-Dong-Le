# Windows 常见问题

## AVD 型号不匹配或 `adb root` 失败

通常是 API 版本、CPU 架构或镜像类型有误，或者当前 AVD 不是 `ldl_win_x64`。检查：

```powershell
adb -s emulator-5556 emu avd name
adb -s emulator-5556 shell getprop ro.build.version.sdk
adb -s emulator-5556 shell getprop ro.product.cpu.abi
adb -s emulator-5556 root
```

应看到 AVD 名称 `ldl_win_x64`、API 版本 `30`、架构 `x86_64`，并且 `adb root` 能重启 adbd。镜像不兼容时，先按 [备份说明](WINDOWS-DATA.md) 保存数据，再手动重建 Google APIs AVD。

## WHPX 不可用或启动很慢

检查 BIOS 的 VT-x/AMD-V 和 Windows Hypervisor Platform。重启后运行：

```powershell
& "$env:ANDROID_SDK_ROOT\emulator\emulator.exe" -accel-check
```

如果使用了第三方虚拟机、旧版 Hyper-V 配置或关闭了 Windows 虚拟化功能，先恢复 WHPX，再启动 AVD。

## `controller_not_ready`

确认 16081 没被占用：

```powershell
Get-NetTCPConnection -LocalPort 16081 -ErrorAction SilentlyContinue
```

查看 `runtime\controller.log` 和 `runtime\emulator.log`。控制台只监听本机回环地址，不要把端口映射到公网。

## `frida_download_checksum_mismatch`

删除未完成的 `runtime\frida-server-16.7.19-android-x86_64.xz` 后重新执行 `start`。不要手动替换为其他架构的 Frida server。

## 应用打不开或 ARM 库加载失败

确认使用的是 Android 11 API 30 x86_64 Google APIs 镜像，并重新安装两个 APK：

```powershell
.\ldl-windows.ps1 install-apks
.\ldl-windows.ps1 open-app
```

Windows ARM 主机、Google Play 镜像和 Android 12+ x86_64 镜像不属于当前验证组合。

## 登录失效

不要删除 `private\state` 或 AVD 数据。先在模拟器中重新打开微信和乐动力并完成登录，再运行：

```powershell
.\ldl-windows.ps1 setup
.\ldl-windows.ps1 check
```
