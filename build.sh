#!/usr/bin/env bash

# Build + empacotamento do NemeyKernel (Exynos 850 / a12s): ponto de entrada
# unico. Carrega dependencia e toolchain, compila, gera os .br e fecha o tar e
# o zip em kernel_build/. O comportamento sai de variaveis de ambiente:
# VARIANT (e|p), DEFCONFIG, JOBS, CLANG_DIR, BOOT_IMG, BOOTLOADER_PREFIX,
# XY_TAG e DEVICE_TARGET.

set -e

SECONDS=0
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="$ROOT_DIR/out"
TC_DIR="$ROOT_DIR/pronton-toolchains"
PKG_DIR="$ROOT_DIR/kernel_build"
PKG_STAGE="$OUT_DIR/pkg"
# Um clang posto ao lado da arvore (../clang-r450784d) tem prioridade; sem
# ele, cai no pronton-toolchains.
PARENT_CLANG="$(dirname "$ROOT_DIR")/clang-r450784d"
TOOLS_DIR="$TC_DIR/build/kernel/build-tools/path/linux-x86"
[ -n "$CLANG_DIR" ] || {
    if [ -x "$PARENT_CLANG/bin/clang" ]; then
        CLANG_DIR=$PARENT_CLANG
    else
        CLANG_DIR="$TC_DIR/clang/host/linux-x86/clang-r416183b"
    fi
}

DEVICE_TARGET=${DEVICE_TARGET:-"a12s"}
DEFCONFIG=${DEFCONFIG:-"exynos850-${DEVICE_TARGET}_defconfig"}
JOBS=${JOBS:-$(nproc --all)}
CODENAME=$(cat "$ROOT_DIR/codename" 2>/dev/null || echo "Nemey")
# e = selinux enforcing, p = permissive (o defconfig salvo ja vem permissive).
VARIANT=${VARIANT:-"p"}
# Prefixo de ro.boot.bootloader usado pelo flasher para aceitar o pacote.
BOOTLOADER_PREFIX=${BOOTLOADER_PREFIX:-"A127F"}

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
        aptitude bc bison brotli ccache cpio curl flex git kmod libelf-dev
        libssl-dev lz4 perl python-is-python3 python3 tar unzip wget
        zlib1g-dev zip zstd
        gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
        gcc-arm-linux-gnueabi binutils-arm-linux-gnueabi
    )
    sudo apt update -y
    sudo apt install "${deps[@]}" -y
}

# --- Toolchain (pronton-toolchains, branch A12-Port) ---
# O gitlink do pai esta atrasado e o .gitmodules cita uma branch que nao
# existe no remoto, entao o --fetch-toolchains clona a tip em vez de rodar
# 'submodule update'.
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

# --- Variante do selinux ---
# Mexe no defconfig salvo do trabalho: deixe o arquivo limpo depois de
# construir uma variante (git checkout -- arch/arm64/configs/<defconfig>).
apply_variant() {
    local conf="arch/arm64/configs/$DEFCONFIG" permissive=y
    case "$VARIANT" in
        e|enforcing) VARIANT_SLUG=en; permissive=n ;;
        p|permissive) VARIANT_SLUG=per ;;
        *) error "VARIANT invalido: $VARIANT (use e ou p)" ;;
    esac
    if [ "$permissive" = y ]; then
        "$ROOT_DIR/scripts/config" --file "$conf" -e SECURITY_SELINUX_ALWAYS_PERMISSIVE
    else
        "$ROOT_DIR/scripts/config" --file "$conf" -d SECURITY_SELINUX_ALWAYS_PERMISSIVE
    fi
}

export PATH="$CLANG_DIR/bin:$TOOLS_DIR:$PATH"

# mold nao le linker script de kernel: o "man mold" diz que ele implementa só o
# minimo de SECTIONS/INPUT que o libc.so precisa, e o primeiro link do build
# aborta com "unknown linker script token". Ele entra entao no link das
# ferramentas de build, que passam pelo driver do clang; o kernel fica no lld.
HOST_LD=ld.lld
HOST_LD_FLAGS=
if command -v ld.mold >/dev/null 2>&1; then
    HOST_LD=ld.mold
    HOST_LD_FLAGS=-fuse-ld=mold
fi

MAKE_ARGS="ARCH=arm64 CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm \
OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip \
HOSTCC=clang HOSTCXX=clang++ HOSTAR=llvm-ar HOSTLD=$HOST_LD \
HOSTLDFLAGS=$HOST_LD_FLAGS \
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
export ARCH=arm64
export SUBARCH=arm64
export TARGET_SOC=s5e3830
export PLATFORM_VERSION=13
export ANDROID_MAJOR_VERSION=t
export CC=clang
export LD=ld.lld
export LLVM=1
export LLVM_IAS=1
export CROSS_COMPILE=aarch64-linux-gnu-
export CLANG_TRIPLE=aarch64-linux-gnu-
export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

# Menu local: quem passa DEFCONFIG pelo ambiente ou o alvo na linha de comando
# nunca cai aqui.
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

apply_variant

# boot.br so faz sentido a partir de um boot.img inteiro (ramdisk + dtb do
# aparelho): a arvore nao tem alvo boot.img, entao a base vem por BOOT_IMG.
# Checa aqui para nao queimar duas horas de build em cima de um caminho errado.
BOOT_IMG_SRC=${BOOT_IMG:-"$PKG_DIR/base/boot.img"}
if [ -f "$BOOT_IMG_SRC" ]; then
    [ "$(head -c 8 "$BOOT_IMG_SRC")" = "ANDROID!" ] ||
        error "$BOOT_IMG_SRC nao e um boot.img (cabecalho sem ANDROID!)."
fi

COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "untracked")
# A tag vem do 'git describe'; sem tag nenhuma, o nome do pacote usa o sha
# curto. XY_TAG no ambiente sobrescreve.
XY_TAG=${XY_TAG:-$(git describe --tags --abbrev=0 2>/dev/null || echo "$COMMIT_HASH")}
BUILD_DETAILS="${CODENAME}-${DEVICE_TARGET}-$(date +%Y%m%d)_${COMMIT_HASH}-NIGHTLY"
PKG_NAME="${CODENAME}@${DEVICE_TARGET}-${XY_TAG}${VARIANT_SLUG}"

msg "Compilando $DEFCONFIG para $DEVICE_TARGET com $JOBS jobs (kernel: ld.lld, tools: $HOST_LD, variante $VARIANT_SLUG)..."
mkdir -p "$OUT_DIR/arch/arm64/boot" "$PKG_DIR"

make $MAKE_ARGS "$DEFCONFIG"
make $MAKE_ARGS -j"$JOBS"
# dtb.img/dtbo.img nao sao alvo de 'all', mas o empacotamento .br depende deles
make $MAKE_ARGS dtbs dtb.img dtbo.img

[ -f arch/arm64/boot/Image ] || error "Compilacao falhou! Image nao encontrado."

msg "Kernel compilada! Coletando artefatos..."
cp arch/arm64/boot/Image arch/arm64/boot/Image.gz \
    arch/arm64/boot/dtb.img arch/arm64/boot/dtbo.img "$OUT_DIR/arch/arm64/boot/"
cp System.map "$OUT_DIR/"
cp .config "$OUT_DIR/.config"

# --- Empacotamento: .br + tar + zip ---
# Os .br vao na raiz e o manifest do flasher em META-INF/com/google/android/,
# que e o leiaute que as linhas "flash_compressed" abaixo esperam.
SFF_DIR="$PKG_STAGE/META-INF/com/google/android"
rm -rf "$PKG_STAGE"
mkdir -p "$SFF_DIR"
brotli -q 11 -f -o "$PKG_STAGE/dtbo.br" arch/arm64/boot/dtbo.img

# boot.br so sai do boot.img inteiro validado antes do build.
BOOT_COMMENT="# "
if [ -f "$BOOT_IMG_SRC" ]; then
    brotli -q 11 -f -o "$PKG_STAGE/boot.br" "$BOOT_IMG_SRC"
    BOOT_COMMENT=""
else
    msg "Sem boot.img em $BOOT_IMG_SRC: pacote sem boot.br."
fi

sed -e "s|@BOOTLOADER_PREFIX@|$BOOTLOADER_PREFIX|" \
    -e "s|@BOOT@|$BOOT_COMMENT|" \
    "$PKG_DIR/update-commands.template" > "$SFF_DIR/update-commands"

members=()
if [ -f "$PKG_STAGE/boot.br" ]; then members+=(boot.br); fi
members+=(dtbo.br META-INF/com/google/android/update-commands)

rm -f "$PKG_DIR/$PKG_NAME.tar" "$PKG_DIR/$PKG_NAME.zip"
tar -cf "$PKG_DIR/$PKG_NAME.tar" -C "$PKG_STAGE" "${members[@]}" \
    -C "$OUT_DIR/arch/arm64/boot" Image Image.gz dtb.img dtbo.img \
    -C "$OUT_DIR" System.map .config
(cd "$PKG_STAGE" && zip -r9q "$PKG_DIR/$PKG_NAME.zip" "${members[@]}")

for f in Image Image.gz dtb.img dtbo.img; do
    printf '%-10s %12s bytes\n' "$f" "$(stat -c %s "$OUT_DIR/arch/arm64/boot/$f")"
done
for f in "$PKG_DIR/$PKG_NAME.tar" "$PKG_DIR/$PKG_NAME.zip"; do
    printf '%-10s %12s bytes\n' "$(basename "$f")" "$(stat -c %s "$f")"
done

echo -e "\n${green}Build $BUILD_DETAILS concluido em $((SECONDS / 60)) minuto(s)!${reset}"
msg "Artefatos: $OUT_DIR/arch/arm64/boot"
msg "Pacotes:   $PKG_DIR/$PKG_NAME.{tar,zip}"
