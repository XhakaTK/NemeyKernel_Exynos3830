# PegasusKernel — Exynos 850 (A12s / M12)

Kernel Linux 5.10.273 para Samsung Galaxy A12s (SM-A127F) e Galaxy M12 (SM-M127F), baseado no Exynos 850 (s5e3830). O 273 e um mini-upstream: so os commits do stable que caem em subsistema que este kernel compila.

## Requisitos

- Linux x86_64
- Toolchain do repo [`XhakaTK/toolchains`](https://github.com/XhakaTK/toolchains) (clang r614150, LLVM 23.0.1), baixada em `toolchains/`
- Dependências de host: `bison`, `flex`, `bc` e OpenSSL (o `extract-cert` já suporta OpenSSL 3 e 4)

## Compilando

Clone o repositório e busque a toolchain:

```bash
git clone https://github.com/XhakaTK/PegasusKernel_Exynos3830.git
cd PegasusKernel_Exynos3830
bash build.sh --fetch-toolchains
```

O `toolchains/` não é mais submódulo: o clang tem ~3,8 GB e arquivos acima de
100 MB, que o git do GitHub recusa, então ele é distribuído como asset de
Release e o `build.sh` baixa e extrai localmente.

Rode o script de build:

```bash
bash build.sh                     # A12s (SM-A127F)
DEVICE_TARGET=m12 bash build.sh   # M12  (SM-M127F)
```

`DEVICE_TARGET` (default `a12s`) forma o `DEFCONFIG` `exynos850-<alvo>_defconfig`, e o script aplica esse defconfig antes de rodar o `make -j`. Também dá para passar o defconfig direto:

```bash
bash build.sh exynos850-a12s_defconfig   # A12s
bash build.sh exynos850-m12_defconfig    # M12
```

Opcionalmente, dê permissão de execução para usar `./build.sh`:

```bash
chmod +x build.sh
```

O kernel gerado fica em `arch/arm64/boot/Image`.

## Observação

Não rode `make clean`, `make mrproper` nem `make distclean` neste repositório: vários arquivos gerados são versionados e seriam apagados.
