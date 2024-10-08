pacman -S git
pacman -S zsh mingw-w64-ucrt-x86_64-starship
pacman -S mingw-w64-ucrt-x86_64-fzf mingw-w64-ucrt-x86_64-zoxide mingw-w64-ucrt-x86_64-bat

# msys64 shell

# https://github.com/zdharma-continuum/zinit?tab=readme-ov-file#install
bash -c "$(curl --fail --show-error --silent \
    --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

# Windows Defender add zsh, starship, etc