# Solução de Problemas (Troubleshooting)

Guia rápido para resolver os problemas mais comuns durante a instalação e o uso do sistema na **TV Box BTV B13**.

---

## 1. A TV Box inicia no Android em vez de abrir o Debian (microSD)

Causas mais comuns e como resolver:

1. **Botão `update` não foi pressionado corretamente:**
   - Desconecte o cabo de energia antes de começar.
   - Insira o clipe de papel suavemente até sentir o **clique físico** do botão interno.
   - Mantenha pressionado **enquanto** pluga a fonte de energia e continue segurando por **5 a 7 segundos** após ligar.
2. **Cartão microSD gravado incorretamente:**
   - Certifique-se de que a imagem foi gravada com um gravador de imagens (**BalenaEtcher**, **Raspberry Pi Imager** ou `dd`), e **não** apenas copiada como arquivo para dentro do cartão.
   - Se baixou a imagem em partes, confira a integridade com `SHA256SUMS.txt` antes de gravar.
3. **Cartão microSD com mau contato ou incompatível:**
   - Teste limpar os contatos do cartão ou utilizar outro cartão microSD (preferencialmente Classe 10 / UHS-I).

---

## 2. Erro de "espaço insuficiente" ao gravar a imagem no microSD

Cartões de mesma capacidade nominal (por exemplo, dois cartões de "16 GB") podem ter diferenças pequenas no número real de setores dependendo do fabricante.

- **Solução:** utilize um cartão microSD com capacidade ligeiramente maior (ex.: 32 GB) ou baixe a versão reduzida da imagem na aba **Releases**.

---

## 3. A instalação na eMMC falhou ou deu erro de permissão

Certifique-se de estar executando os dois comandos a partir do diretório onde os scripts estão localizados (ou como `root` / com `sudo`):

```bash
sudo ./aml-multiboot-setup.sh
sudo ./aml-install-to-emmc.sh
```

> [!NOTE]
> Se o terminal informar `Arquivo ou diretório inexistente`, verifique com `ls -la ~` ou `ls -la /root` onde os scripts `aml-*.sh` estão localizados no sistema Live.

---

## 4. Aplicativos KDE / Qt não abrem na sessão Wayland

O ambiente gráfico utiliza **XFCE4 sobre Wayland**. Alguns aplicativos baseados em Qt5 ou Qt6 exigem os plugins de plataforma Wayland para abrir corretamente.

Os pacotes abaixo já vêm instalados na imagem; caso você instale novos apps educacionais depois e algum deles não abra, verifique se ambos continuam presentes:

```bash
sudo apt update
sudo apt install -y qt6-wayland qtwayland5
```

---

## 5. Teclado sem acentos ou sem `ç` (layout ABNT2)

A imagem já vem configurada para **Português do Brasil (ABNT2)**. Caso um teclado USB diferente seja conectado e não reconheça o layout imediatamente:

- Abra **Configurações → Teclado → Disposição (Layout)** no menu do XFCE4 e selecione **Português (Brasil)**.

---

## 6. Pendrive não aparece automaticamente

A imagem possui montagem automática (*automount*) configurada. Se um pendrive específico não montar:

1. Teste outra porta USB da TV Box.
2. Verifique se o pendrive não está formatado com um sistema de arquivos corrompido (comum quando removido sem ejetar no Windows).
3. Abra o gerenciador de arquivos (**Thunar**) e clique diretamente no dispositivo listado na barra lateral esquerda.

---

## 7. O sistema está sem som (limitação conhecida)

O **áudio nativo da BTV B13 não funciona** nesta versão da descaracterização (limitação de suporte ao hardware de áudio do aparelho no sistema base).

- Não se trata de erro de instalação ou configuração.
- Por esse motivo, aplicativos educacionais que dependem essencialmente de som (como o *KLettres*) foram deixados de fora da seleção padrão.

---

## 8. Quero rodar direto pelo cartão microSD (sem instalar na eMMC) e falta espaço em disco

Se a imagem foi reduzida com `PiShrink -s`, a partição do cartão microSD fica compacta por padrão (já que o objetivo principal é instalar na eMMC).

Caso deseje usar o sistema permanentemente a partir do próprio cartão microSD, você pode expandir a partição `ext4` manualmente usando o **GParted** em outro computador Linux ou via `parted` + `resize2fs` na partição raiz do cartão.

---

## 9. Tela de boas-vindas do Armbian piscando várias vezes antes de iniciar a interface

Quando a TV Box é desligada incorretamente (por exemplo, retirando o cabo de energia diretamente da tomada sem encerrar o sistema pelo menu ou com `poweroff`), o sistema pode apresentar várias piscadas na tela de boas-vindas do **Armbian** durante a inicialização seguinte antes de carregar a área de trabalho.

- **Solução:** desligue a TV Box e ligue-a novamente para normalizar a inicialização.
- **Prevenção:** sempre encerre o aparelho pelo menu do sistema ou executando `poweroff` no terminal antes de desconectar a alimentação.
