#!/usr/bin/env bash
# ----------------------------- VARIÁVEIS ----------------------------- #
PPA_LUTRIS="ppa:lutris-team/lutris"

URL_WINE_KEY="https://dl.winehq.org/wine-builds/winehq.key"
URL_PPA_WINE="https://dl.winehq.org/wine-builds/ubuntu/"
URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
URL_INSYNC="https://d2t3ff60b2tol4.cloudfront.net/builds/insync_3.0.27.40677-bionic_amd64.deb"
URL_AZURE_DATA_STUDIO="https://go.microsoft.com/fwlink/?linkid=2113344"

DIRETORIO_DOWNLOADS="$HOME/Downloads/programas"
FONTS_DIR="$HOME/.local/share/fonts"
SETTINGSJSON_DIR="$HOME/.config/Code/User"

PROGRAMAS_PARA_INSTALAR=(
  jq
  moreutils
  flatpak
  gnome-software-plugin-flatpak
  git
  python3
  python-pip
  wine
  docker
  docker-compose
  build-essential
  libssl-dev
  snapd
  guvcview
  virtualbox
  flameshot
  steam-installer
  lutris
  synaptic
  gnome-tweaks
  dconf-editor
  curl
  dconf-cli
)
# ---------------------------------------------------------------------- #

# ----------------------------- REQUISITOS ----------------------------- #
## Removendo travas eventuais do apt ##
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock

## Adicionando/Confirmando arquitetura de 32 bits ##
sudo dpkg --add-architecture i386

## Atualizando o repositório ##
sudo apt update -y

## Adicionando repositórios de terceiros e suporte a Snap (Lutris e Wine)##
sudo add-apt-repository "$PPA_LUTRIS" -y
wget -nc "$URL_WINE_KEY"
sudo apt-key add winehq.key
sudo apt-add-repository "deb $URL_PPA_WINE bionic main"
# ---------------------------------------------------------------------- #

# ----------------------------- EXECUÇÃO ----------------------------- #
## Atualizando o repositório depois da adição de novos repositórios ##
sudo apt update -y

## Download e instalaçao de programas externos ##
mkdir "$DIRETORIO_DOWNLOADS"
wget -c "$URL_GOOGLE_CHROME"       -P "$DIRETORIO_DOWNLOADS"
wget -c "$URL_INSYNC"              -P "$DIRETORIO_DOWNLOADS"
wget -c "$URL_AZURE_DATA_STUDIO"              -P "$DIRETORIO_DOWNLOADS"

## Instalando pacotes .deb baixados na sessão anterior ##
sudo dpkg -i $DIRETORIO_DOWNLOADS/*.deb

# Instalar programas no apt
for nome_do_programa in ${PROGRAMAS_PARA_INSTALAR[@]}; do
  if ! dpkg -l | grep -q $nome_do_programa; then # Só instala se já não estiver instalado
    apt install "$nome_do_programa" -y
  else
    echo "[INSTALADO] - $nome_do_programa"
  fi
done
sudo apt install --install-recommends winehq-stable wine-stable wine-stable-i386 wine-stable-amd64 -y

## Adicionando repositório Flathub ##
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 

## Instalando pacotes Flatpak ##
sudo flatpak install flathub com.sublimetext.three -y

## Instalando pacotes Snap ##
sudo snap install slack --classic
sudo snap install skype --classic
sudo snap install code --classic
#sudo snap install --edge node --classic
sudo snap install insomnia
sudo snap install wps-office-multilang
# ---------------------------------------------------------------------- #

# ----------------------------- PÓS-INSTALAÇÃO ----------------------------- #
## Instalação da font family Fira Code ##
if [ ! -d "${FONTS_DIR}" ]; then
    echo "mkdir -p $FONTS_DIR"
    mkdir -p "${FONTS_DIR}"
else
    echo "Found fonts dir $FONTS_DIR"
fi

for type in Bold Light Medium Regular Retina; do
    file_path="${HOME}/.local/share/fonts/FiraCode-${type}.ttf"
    file_url="https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-${type}.ttf?raw=true"
    if [ ! -e "${file_path}" ]; then
        echo "wget -O $file_path $file_url"
        wget -O "${file_path}" "${file_url}"
    else
	echo "Found existing file $file_path"
    fi;
done

echo "fc-cache -f"
fc-cache -f

## Configure VSCode ##
code --install-extension dracula-theme.theme-dracula
code --install-extension pkief.material-icon-theme
code --install-extension rocketseat.rocketseatreactjs
code --install-extension rocketseat.rocketseatreactnative
code --install-extension naumovs.color-highlight
code --install-extension ms-vscode.csharp
code --install-extension eamodio.gitlens
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-python.python

cd $SETTINGSJSON_DIR
jq '. + { "window.zoomLevel": 1 }' settings.json|sponge settings.json
jq '. + { "workbench.colorTheme": "Dracula" }' settings.json|sponge settings.json
jq '. + { "editor.fontFamily": "Fira Code" }' settings.json|sponge settings.json
jq '. + { "editor.fontLigatures": true }' settings.json|sponge settings.json
jq '. + { "editor.fontSize": 14 }' settings.json|sponge settings.json
jq '. + { "workbench.iconTheme": "material-icon-theme" }' settings.json|sponge settings.json
jq '. + { "editor.rulers": [110, 140] }' settings.json|sponge settings.json
jq '. + { "editor.renderLineHighlight": "gutter" }' settings.json|sponge settings.json
jq '. + { "editor.tabSize": 4 }' settings.json|sponge settings.json
jq '. + { "terminal.integrated.fontSize": 14 }' settings.json|sponge settings.json
jq '. + { "emmet.includeLanguages": { "javascript": "javascriptreact" } }' settings.json|sponge settings.json
jq '. + { "emmet.syntaxProfiles": { "javascript": "jsx" } }' settings.json|sponge settings.json
jq '. + { "javascript.updateImportsOnFileMove.enabled": "never" }' settings.json|sponge settings.json
jq '. + { "editor.parameterHints.enabled": false }' settings.json|sponge settings.json
jq '. + { "breadcrumbs.enabled": true }' settings.json|sponge settings.json
jq '. + { "javascript.suggest.autoImports": false }' settings.json|sponge settings.json
jq '. + { "terminal.integrated.shell.osx": "/bin/zsh" }' settings.json|sponge settings.json

## Finalização, atualização e limpeza##
cd $HOME
sudo apt update && sudo apt dist-upgrade -y
flatpak update
sudo apt autoclean
sudo apt autoremove -y
# ---------------------------------------------------------------------- #

echo "Finalizado"
echo "Lembre-se de configurar a fonte Fira Code em seu terminal."
echo "Instalar ZSH no link que abrirá"

google-chrome https://blog.rocketseat.com.br/terminal-com-oh-my-zsh-spaceship-dracula-e-mais/

## Instalando e configurando Oh My Zsh ##
##apt install zsh -y
##sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
##cd $HOME
##git clone https://github.com/dracula/gnome-terminal "$HOME"
##cd $HOME/gnome-terminal
##./install.sh
##git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
##ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
##sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/install.sh)"