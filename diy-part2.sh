#!/bin/bash
# 描述: 编译前执行，用于修改系统默认配置和修复底层环境

# 1. 物理抹除被污染的云端依赖缓存
rm -rf ./dl/go-mod-cache ./dl/*go*.tar.* ./dl/*rust*.tar.*

# 2. 物理销毁可能存在的残留 Filebrowser-go 源码 (绝杀 Error 255)
rm -rf feeds/luci/applications/luci-app-filebrowser-go
rm -rf feeds/packages/net/filebrowser-go
sed -i '/filebrowser-go/d' .config || true

# 3. 破解 Go 离线编译限制，允许 Go 自动向公网修复缺失依赖
find feeds/ -type f -name "golang-package.mk" -exec sed -i 's/GOPROXY=off/GOPROXY=https:\/\/goproxy.io,direct/g' {} +
find feeds/ -type f -name "golang-package.mk" -exec sed -i 's/-mod=vendor/-mod=mod/g' {} +
find feeds/ -type f -name "golang-package.mk" -exec sed -i 's/-mod=readonly/-mod=mod/g' {} +

# 4. 修复 Rust 交叉编译下载工具链报错的问题
rustup target add aarch64-unknown-linux-musl || true
sed -i 's/download-ci-llvm.*/download-ci-llvm = false/g' feeds/packages/lang/rust/Makefile || true
find feeds/packages/lang/rust/ -type f -name "*.toml" -exec sed -i 's/download-ci-llvm.*/download-ci-llvm = false/g' {} + || true

# 5. 修改路由器默认后台 IP 为 192.168.2.1
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
