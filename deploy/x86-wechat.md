# x86 微信启动验证

在 x86_64 Linux 上，使用 QEMU 的 ARM64 整机模拟运行 Ubuntu ARM64，再在客体中运行 ARM64 ReDroid 14。原版微信 8.0.79 的两次屏幕采样均成功保存，其中确认欢迎页显示了 `Log In` 和 `Sign Up`。Android 报告 ABI 为 `arm64-v8a`，Native Bridge 为 `0`。

测试环境为 QEMU 10.0.13、Cortex-A76、4 个虚拟核、8 GiB 客体内存、Ubuntu 24.04 的 `6.8.0-147-generic` 内核及 4 KiB 页。ReDroid 使用软件渲染，首次导入、启动和安装合计花了数十分钟。

验证覆盖离线启动到微信欢迎页。点击登录、联网授权、乐动力联动和完整项目流程仍待验证。ReDroid 14 的 Android 设置页在一次采样中仍是黑屏。

## 准备 ARM64 客体

准备带可用控制台账号的 Ubuntu 24.04 ARM64 系统盘和 ARM64 UEFI 固件。为虚拟机准备独立的可写 UEFI 变量文件。将下列环境变量设为对应文件的绝对路径后，在 x86_64 宿主运行。命令使用实测的 CPU 和内存配置。固件启动可参照 [Ubuntu 的 ARM64 QEMU 说明](https://ubuntu.com/server/docs/how-to/virtualisation/qemu/#arm64-vms-on-qemu) 和 [QEMU Arm 文档](https://www.qemu.org/docs/master/system/target-arm.html)。

```bash
qemu-system-aarch64 \
  -machine virt,gic-version=3 -cpu cortex-a76 \
  -accel tcg,thread=multi,tb-size=512 -smp 4 -m 8192 -nographic \
  -drive "if=pflash,format=raw,readonly=on,file=${UEFI_CODE:?}" \
  -drive "if=pflash,format=raw,file=${UEFI_VARS:?}" \
  -drive "if=virtio,format=qcow2,file=${ARM64_DISK:?}" \
  -netdev user,id=net0 -device virtio-net-pci,netdev=net0,romfile=
```

在客体里安装 Docker Engine、Docker Compose v2 和 Git LFS。确认下面的检查通过。Ubuntu 的 `binder_linux` 模块可由与当前内核匹配的 `linux-modules-extra-$(uname -r)` 包提供。

```bash
test "$(uname -m)" = aarch64
test "$(getconf PAGE_SIZE)" = 4096
sudo modprobe binder_linux
grep -w binder /proc/filesystems
test -c /dev/dma_heap/system
```

## 启动和验证微信

在 **ARM64 客体内**克隆本仓库的 `x86` 分支并进入仓库目录。单独的 Compose 配置使用固定摘要的原版镜像和独立数据卷，Android 容器关闭网络。

```bash
git lfs pull
sha256sum -c apks/SHA256SUMS
smoke=(docker compose -f compose.x86-wechat.yaml)
"${smoke[@]}" up -d
"${smoke[@]}" exec -T android getprop sys.boot_completed
"${smoke[@]}" exec -T android service check package
```

等到上述最后两个命令分别输出 `1` 和 `Service package: found`，再安装并打开微信。

```bash
"${smoke[@]}" cp apks/wechat.apk android:/data/local/tmp/wechat.apk
"${smoke[@]}" exec -T android pm install -r /data/local/tmp/wechat.apk
"${smoke[@]}" exec -T android input keyevent KEYCODE_WAKEUP
"${smoke[@]}" exec -T android wm dismiss-keyguard
"${smoke[@]}" exec -T android am start -n com.tencent.mm/.ui.LauncherUI
```

等待几分钟后截图。以实际看到欢迎页按钮为准。若首次截图为空或仍是启动画面，稍后重试。

```bash
capture_dir=$(mktemp -d)
"${smoke[@]}" exec -T android /system/bin/screencap -p /data/local/tmp/wechat.png
"${smoke[@]}" cp android:/data/local/tmp/wechat.png "$capture_dir/wechat.png"
printf '%s\n' "$capture_dir/wechat.png"
```

检查结束后运行 `"${smoke[@]}" down`。数据卷会保留，下一次启动可复用已安装的 APK。
