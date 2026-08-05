#!/usr/bin/env bash

set -Eeuo pipefail

#设置dotfils文件变量名
dotfile_dir="$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)"
packagesFile="$dotfile_dir/packages.txt"

#获取包名列表
mapfile -t packages < <(
	sed -E 's/[[:space:]]*#.*//' "$packagesFile" | awk 'NF'
)

#检查升级并安装指定的工具包
echo "Updating APT package index..."
sudo apt-get update

echo "Installing required packages..."
sudo apt-get install -y "${packages[@]}"

#将配置文件link到dotfils文件夹(如果原机器已经有则将其改名备份)
link_dotfile() {
	local target_file="$1"
	local file_name="$2"

	if [[ ! -e "$target_file" ]];then
		printf 'Source file does not exist : %s\n' "$target_file" >&2
		return 1
	fi

	if [[ -e "$file_name" && ! -L "$file_name" ]];then
		local file_backup
		file_backup="$file_name$(date +%Y%m%d%H%M%S).backup"
		printf 'move %s to %s \n' "$file_name" "$file_backup"
		mv -- "$file_name" "$file_backup"
	fi

	ln -sTnf -- "$target_file" "$file_name"
}

link_dotfile "$dotfile_dir/git/.gitconfig" "$HOME/.gitconfig"
link_dotfile "$dotfile_dir/tmux/.tmux.conf" "$HOME/.tmux.conf"
link_dotfile "$dotfile_dir/bash/.bashrc" "$HOME/.bashrc"
