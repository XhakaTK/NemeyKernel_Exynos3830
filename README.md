# NemeyKernel — Exynos 850 (A12s / M12)

Kernel Linux 5.10.271 para Samsung Galaxy A12s (SM-A127F) e Galaxy M12 (SM-M127F), baseado no Exynos 850 (s5e3830).

## Requisitos

- Linux x86_64
- Toolchain do submódulo `pronton-toolchains` (clang r416183b)
- Dependências de host: `bison`, `flex`, `bc` e OpenSSL (o `extract-cert` já suporta OpenSSL 3 e 4)

## Compilando

Clone o repositório com o submódulo da toolchain:

```bash
git clone https://github.com/XhakaTK/NemeyKernel_Exynos850_A12s-M12.git
cd NemeyKernel_Exynos850_A12s-M12
git submodule update --init
```

Rode o script de build:

```bash
bash build.sh
```

Ele mostra o menu para escolher o dispositivo:

```
==============================
   NemeyKernel - Exynos 850
==============================
  1) A12s (exynos850-a12s_defconfig)
  2) M12  (exynos850-m12_defconfig)

Escolha o dispositivo [1]:
```

Digite `1` ou `2` e aperte Enter. O script aplica o defconfig escolhido e em seguida roda `make -j4`.

Também dá para pular o menu passando o defconfig direto:

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
