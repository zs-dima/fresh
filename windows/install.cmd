
setx /M PATH "%PATH%;%CD%\scripts"
setx ChocolateyToolsLocation "c:\dev\tool" /M

# Fonts
# choco install firacode
# choco install nerd-fonts-hack
choco install nerd-fonts-firacode

# Shell tools
choco install fzf
choco install zoxide
# choco install bat
choco install msys2

# choco list > list.txt

# curl, wget, git, ffmpeg, hwinfo, dart-sdk, dbeaver, android-sdk, adb, jre8, jdk8, nodejs, protoc, qbittorrent, steam, slack, vlc, vscode, telegram