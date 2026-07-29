# Guia de Instalação do Fedora Workstation

Guia rápido, conciso e direto para instalação e configuração inicial do **Fedora Workstation**.

---

## 💾 1. Preparação (Download & Pendrive)

1. **Baixar a ISO Oficial:**
   - Download: [fedoraproject.org/workstation/download](https://fedoraproject.org/workstation/download)
   - Escolha a versão **Fedora Workstation (64-bit)**.

2. **Criar Pendrive Bootável (Mínimo 8 GB):**
   - **No Linux/Ubuntu:** Use o aplicativo *Gravador de Imagem de Disco* (Disk Image Writer) ou BalenaEtcher.
   - **No Windows:** Use BalenaEtcher ou Rufus.

3. **Backup:**
   - Salve seus arquivos pessoais da pasta `/home` em um disco externo ou nuvem.

---

## ⚙️ 2. Instalação

1. Insira o pendrive e reinicie o computador.
2. Acesse o menu de boot (`F12`, `F11`, `F8` ou `F2`) e escolha o pendrive.
3. Selecione **"Start Fedora Workstation Live"**.
4. Clique em **"Install to Hard Drive"**.
5. Selecione o idioma e o layout do teclado.
6. Em **Destino da Instalação**, escolha o SSD/HD de destino.
7. Clique em **Iniciar Instalação** e reinicie após a conclusão.

---

## 🚀 3. Pós-Instalação (Checklist Inicial)

Após entrar no Fedora pela primeira vez, abra o terminal (`Ctrl + Alt + T`) e rode os comandos abaixo:

### A. Atualizar o Sistema
```bash
sudo dnf upgrade --refresh -y
```

### B. Ativar Repositórios RPM Fusion (Codecs & Drivers)
```bash
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

### C. Instalar Codecs de Áudio e Vídeo (MP4, H.264, etc.)
```bash
sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
```

### D. (Opcional) Driver NVIDIA
*Apenas para placas de vídeo NVIDIA:*
```bash
sudo dnf install -y akmod-nvidia
```

---

## ✅ Pronto!
Seu Fedora estará 100% atualizado, leve e pronto para uso diário.
