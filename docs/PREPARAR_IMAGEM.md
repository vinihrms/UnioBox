# Guia de Preparação e Manutenção da Imagem (BTV B13)

Este guia é destinado aos mantenedores do projeto que precisam gerar, reduzir, validar e publicar novas versões da imagem clonada do cartão microSD na aba **Releases** do GitHub.

---

## 1. Por que reduzir a imagem de 16 GB antes de publicar?

Ao clonar o cartão microSD bruto com `dd` (dividido para caber em pendrive FAT32):

```bash
sudo dd if=/dev/mmcblk0 bs=4M status=progress | split -b 3500M - /mnt/pendrive/backup_part_
```

Os arquivos `backup_part_*` concatenados formam uma imagem `.img` bootável completa (pronta para BalenaEtcher, Raspberry Pi Imager ou `dd`), **porém** com o tamanho bruto integral do cartão de origem (ex.: 16 GB). Isso causa dois problemas:

1. **Incompatibilidade entre marcas de cartão:** um microSD de "16 GB" de outro fabricante pode ter alguns megabytes a menos que o cartão original, fazendo a gravação falhar no final.
2. **Download e gravação mais lentos:** grava gigabytes de espaço vazio sem necessidade.

A solução é juntar as partes em um `.img`, encolher a partição `ext4` com o **[PiShrink](https://github.com/Drewsif/PiShrink)** e só então compactar com `gzip` para publicar.

---

## 2. Recombinar as partes do backup bruto em um `.img`

Em um computador **Linux** (com pelo menos ~25 GB livres no disco local — não faça dentro do pendrive FAT32, pois arquivos maiores que 4 GB falham em FAT32):

```bash
cat /mnt/pendrive/backup_part_* > ~/sistema_tvbox_b13.img
ls -lh ~/sistema_tvbox_b13.img
```

*(Como o backup foi feito sem `gzip`, o resultado já é o arquivo bruto `sistema_tvbox_b13.img` pronto para o PiShrink.)*

---

## 3. Reduzir a imagem com PiShrink (`-s`)

### Instalar o PiShrink (uma única vez, em um PC Linux)

```bash
wget https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh
chmod +x pishrink.sh
sudo mv pishrink.sh /usr/local/bin/
```

*(Dependências comuns no Debian/Ubuntu: `sudo apt install parted e2fsprogs gzip`.)*

### Encolher a imagem

> [!IMPORTANT]
> **Use obrigatoriamente a flag `-s` (`skip autoexpand`)!**
> Sem `-s`, o PiShrink tenta injetar scripts de auto-expansão específicos do Raspberry Pi OS (`/etc/rc.local`), que podem falhar ou não funcionar em imagens Debian ARM genéricas (Amlogic). Como o cartão microSD é usado apenas em modo Live para rodar `aml-install-to-emmc.sh` — que já particiona e ocupa toda a eMMC da TV Box —, não precisamos de auto-expansão no cartão SD.

```bash
sudo pishrink.sh -s sistema_tvbox_b13.img uniobox_b13.img
```

Ao final, o arquivo `uniobox_b13.img` terá apenas o tamanho real dos dados instalados + uma pequena margem de segurança (normalmente entre **4 GB e 6 GB**, cabendo facilmente em qualquer cartão microSD de 8 GB ou 16 GB).

---

## 4. Compactar e preparar para o GitHub Releases

Compacte a imagem reduzida com `gzip` (compatível nativamente com BalenaEtcher e Raspberry Pi Imager):

```bash
gzip -9 -k uniobox_b13.img
ls -lh uniobox_b13.img.gz
```

Verifique o tamanho do arquivo `.img.gz` gerado:

### Caso A — Arquivo menor ou igual a 2 GB *(cenário ideal)*

O GitHub Releases aceita anexos de até **2 GB por arquivo**. Basta gerar o checksum e publicar o `.img.gz` diretamente como **arquivo único**:

```bash
sha256sum uniobox_b13.img.gz > SHA256SUMS.txt
```

### Caso B — Arquivo maior que 2 GB

Divida o `.img.gz` em partes de **1,5 GB** (`1500M`) e gere o checksum de tudo:

```bash
split -b 1500M -d uniobox_b13.img.gz uniobox_b13.img.gz.part
sha256sum uniobox_b13.img.gz.part* uniobox_b13.img.gz > SHA256SUMS.txt
```

---

## 5. Checklist de Validação antes de Publicar a Release

Antes de tornar a versão pública no GitHub, valide em uma TV Box **BTV B13** real:

- [ ] Se houver partes, testar a reconstrução com `scripts/juntar-imagem.sh` / `.bat` e conferir `sha256sum -c SHA256SUMS.txt`.
- [ ] Gravar `uniobox_b13.img.gz` em um cartão microSD usando BalenaEtcher ou Raspberry Pi Imager.
- [ ] Dar boot na BTV B13 segurando o botão `update` com um clipe.
- [ ] Verificar idioma `pt-BR`, teclado `ABNT2` e montagem automática ao plugar um pendrive.
- [ ] Abrir o terminal e executar `./aml-multiboot-setup.sh` e `./aml-install-to-emmc.sh`.
- [ ] Desligar, remover o microSD, ligar novamente e confirmar boot direto pela memória interna (eMMC).
- [ ] Atualizar no `README.md` o tamanho mínimo do microSD, as credenciais padrão de login e (se desejar) adicionar fotos em `docs/img/`.
- [ ] Criar a **Release** no GitHub (ex.: `v1.0.0`) anexando o(s) arquivo(s) da imagem e `SHA256SUMS.txt`.
