# x86_64 Linux Docker 部署

在 x86_64 Linux 上，`./ldl-x86` 为 Android 12 / Houdini 加载独立的 Compose 配置。需要 Docker Engine、Compose v2、Python 3.11+，以及提供 Binder、DMA-BUF system heap、IPv6 和 4 KiB 页的宿主内核。

```sh
python3 deploy/fetch_apks.py
python3 deploy/fetch_apks.py --verify-only
./ldl-x86 doctor
./ldl-x86 compose up -d --build
./ldl-x86 install-apks
./ldl-x86 compatibility
./ldl-x86 open-app
```

控制台默认监听 <http://127.0.0.1:16080/>。在浏览器中完成本人账号登录后，用 `./ldl-x86 setup` 初始化，再用 `./ldl-x86 check` 查询作业。

Compose 项目名默认是 `ldl-automation-x86`，默认数据目录是仓库旁的 `../ldl-automation-x86-data/`。备份和更新时保留其中的 `android/` 和 `controller/`。此方案使用 ARM32 微信 8.0.42，请使用独立的数据目录。

可在调用前设置以下环境变量：

| 变量 | 用途 |
|---|---|
| `LDL_X86_UI_PORT` | 控制台端口，默认 `16080` |
| `LDL_X86_PROJECT_NAME` | Compose 项目名 |
| `LDL_X86_DATA_DIR` | x86 数据目录 |
| `LDL_X86_APK_DIR` | 已校验 APK 的目录，默认 `./apks` |
| `LDL_X86_IMAGE` | Android 基础镜像，默认使用固定的 Android 12 / Houdini 镜像摘要 |

使用过贡献者早期的 `li-dong-le` Compose 版本，可以先停止旧服务、备份数据，再把 `LDL_X86_DATA_DIR` 指向原来的 `../li-dong-le-data/`。用 `./ldl-x86 compose config` 核对宿主目录后再启动。

现有 `x86` 分支的 ARM64 ReDroid 14 属于另一种方案，两者使用不同架构的 Android 镜像。切换方案时请用新的数据目录，保留旧目录供回退。

作者验证的运行组合见 [验证记录](VALIDATION.md)。通用命令与数据说明见 [运维文档](OPERATIONS.md)。
