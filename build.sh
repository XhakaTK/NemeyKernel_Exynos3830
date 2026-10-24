#!/usr/bin/env bash

# Build + empacotamento do NemeyKernel (Exynos 850 / a12s).
# O CI nao faz nada sozinho: chama este script, que carrega dependencia,
# toolchain, compila e gera o zip flashavel.

set -e

SECONDS=0
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="$ROOT_DIR/out"
TC_DIR="$ROOT_DIR/pronton-toolchains"
CLANG_DIR="$TC_DIR/clang/host/linux-x86/clang-r416183b"
TOOLS_DIR="$TC_DIR/build/kernel/build-tools/path/linux-x86"
ANYKERNEL_DIR="$ROOT_DIR/external/anykernel3"

DEVICE_TARGET=${DEVICE_TARGET:-"a12s"}
DEFCONFIG=${DEFCONFIG:-"exynos850-${DEVICE_TARGET}_defconfig"}
JOBS=${JOBS:-$(nproc --all)}
CODENAME=$(cat "$ROOT_DIR/codename" 2>/dev/null || echo "Nemey")

export TERM=xterm
red='\033[0;31m'
green='\033[0;32m'
blue='\033[0;34m'
reset='\033[0m'

msg() { echo -e "${blue}INFO: ${reset}$1"; }
error() {
    echo -e "${red}ERROR: ${reset}$1"
    exit 1
}

# --- Dependencias do host ---
setup_deps() {
    local deps=(
        aptitude bc bison ccache cpio curl flex git kmod libelf-dev
        libssl-dev lz4 perl python-is-python3 python3 tar wget zip zlib1g-dev
        gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
        gcc-arm-linux-gnueabi binutils-arm-linux-gnueabi
    )
    sudo apt update -y
    sudo apt install "${deps[@]}" -y
}

# --- Toolchain (pronton-toolchains, branch A12-Port) ---
# O gitlink do pai esta atrasado e o .gitmodules cita uma branch que nao
# existe no remoto, entao o CI nunca usa 'submodule update': clona a tip.
_setup_toolchain() {
    msg "Clonando pronton-toolchains (A12-Port)..."
    rm -rf "$TC_DIR"
    git clone --depth 1 --single-branch -b A12-Port \
        https://github.com/XhakaTK/pronton-toolchains.git "$TC_DIR" \
        || error "Falha ao clonar o toolchain."
    [ -x "$CLANG_DIR/bin/clang" ] || error "clang nao esta em $CLANG_DIR/bin."
    msg "Toolchain pronta em $TC_DIR"
}

setup_toolchain() {
    if [ "$UPDATE_TOOLCHAINS" = "true" ]; then
        msg "Limpando cache antigo do toolchain.."
        rm -rf "$TC_DIR"
        [ -d ~/.ccache ] && rm -rf ~/.ccache
    fi
    if [ ! -x "$CLANG_DIR/bin/clang" ]; then
        _setup_toolchain
    else
        msg "Toolchain ja existe em $TC_DIR"
    fi
}

# --- Regenerar o defconfig salvo ---
regen_defconfig() {
    msg "Gerando defconfig minimo para $DEVICE_TARGET..."
    make $MAKE_ARGS "$DEFCONFIG"
    make $MAKE_ARGS savedefconfig
    msg "defconfig gerado em $(pwd)/defconfig (compare com arch/arm64/configs/${DEFCONFIG})"
}

MAKE_ARGS="ARCH=arm64 CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm \
OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip \
HOSTCC=clang HOSTCXX=clang++ HOSTAR=llvm-ar HOSTLD=ld.lld \
CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_COMPAT=arm-linux-gnueabi- \
CLANG_TRIPLE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1"

case "$1" in
"--setup-deps")
    setup_deps
    exit 0
    ;;
"--fetch-toolchains")
    setup_toolchain
    exit 0
    ;;
"--clean")
    msg "Limpando..."
    rm -rf "$OUT_DIR"
    make $MAKE_ARGS clean
    exit 0
    ;;
"--regen-defconfig")
    regen_defconfig
    exit 0
    ;;
"")
    ;;
*)
    DEFCONFIG=$1
    ;;
esac

# --- Ambiente de build ---
export KBUILD_BUILD_USER="NemeyKernel"
export KBUILD_BUILD_HOST="nemey-lab"
export PATH="$CLANG_DIR/bin:$TOOLS_DIR:$PATH"
export ARCH=arm64
export SUBARCH=arm64
export TARGET_SOC=s5e3830
export PLATFORM_VERSION=13
export ANDROID_MAJOR_VERSION=t
export CC=clang
export LD=lld
export LLVM=1
export LLVM_IAS=1
export CROSS_COMPILE=aarch64-linux-gnu-
export CLANG_TRIPLE=aarch64-linux-gnu-
export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

# Menu local: o CI sempre passa DEFCONFIG pelo ambiente, entao nunca cai aqui.
if [ -z "$1" ] && [ -t 0 ]; then
    echo
    echo "=============================="
    echo "   ${CODENAME} - Exynos 850"
    echo "=============================="
    echo "  1) A12s (exynos850-a12s_defconfig)"
    echo
    read -r -p "Escolha o dispositivo [1]: " OPT
    case "${OPT:-1}" in
        1) DEVICE_TARGET=a12s ;;
        *) error "Opcao invalida: $OPT" ;;
    esac
    DEFCONFIG="exynos850-${DEVICE_TARGET}_defconfig"
fi

COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "untracked")
BUILD_DETAILS="${CODENAME}-${DEVICE_TARGET}-$(date +%Y%m%d)_${COMMIT_HASH}-NIGHTLY"
[ -z "$CI_ZIPNAME" ] && ZIPNAME="${BUILD_DETAILS}.zip" || ZIPNAME=$CI_ZIPNAME

msg "Compilando $DEFCONFIG para $DEVICE_TARGET com $JOBS jobs..."
mkdir -p "$OUT_DIR/arch/arm64/boot"

make $MAKE_ARGS "$DEFCONFIG"
make $MAKE_ARGS -j"$JOBS"
# dtb.img/dtbo.img nao sao alvo de 'all', mas o workflow de flash precisa deles
make $MAKE_ARGS dtbs dtb.img dtbo.img

[ -f arch/arm64/boot/Image ] || error "Compilacao falhou! Image nao encontrado."

msg "Kernel compilada! Empacotando..."
cp arch/arm64/boot/Image arch/arm64/boot/Image.gz \
    arch/arm64/boot/dtb.img arch/arm64/boot/dtbo.img "$OUT_DIR/arch/arm64/boot/"
cp System.map "$OUT_DIR/"
cp .config "$OUT_DIR/.config"

[ -d "$ANYKERNEL_DIR" ] || error "AnyKernel3 nao esta em $ANYKERNEL_DIR"

rm -f "$ANYKERNEL_DIR/Image"* "$ROOT_DIR/$ZIPNAME"
cp arch/arm64/boot/Image "$ANYKERNEL_DIR/"

pushd "$ANYKERNEL_DIR" >/dev/null
zip -r9q "$ROOT_DIR/$ZIPNAME" ./*
popd >/dev/null

MD5_CHECK=$(md5sum "$ROOT_DIR/$ZIPNAME" | cut -d' ' -f1)

echo -e "\n${green}Build concluido em $((SECONDS / 60)) minuto(s)!${reset}"
msg "Zip flashavel: $ZIPNAME (md5 $MD5_CHECK)"
msg "Artefatos:     $OUT_DIR/arch/arm64/boot"
