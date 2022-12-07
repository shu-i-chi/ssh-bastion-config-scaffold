#!/bin/bash

# 秘密鍵の拡張子（'.'抜き）
private_key_ext="pem"

# ------------------------------------------------------------

# Gitリポジトリの中（＝このdeploy.shと同じディレクトリ）に移動
cd $(dirname $0)

ssh_dirpath="${HOME}/.ssh"
repository_dirpath=$(pwd)

echo "Start to deploy ${ssh_dirpath}/config."

# 0. 余計なファイルが~/.sshディレクトリ配下に含まれていないかどうかの確認
disallowed_files=$(find ${ssh_dirpath} -type f \
                        \( ! -name authorized_keys \) \
                        -and \( ! -name "*.${private_key_ext}" \) \
                        -and \( ! -name "known_hosts*" \))

## 余計なファイルが含まれている場合は中止
if [ "${disallowed_files}" != "" ]; then
  echo -e "[\e[31mERROR\e[m] Please remove these files from ${ssh_dirpath}:"
  echo ${disallowed_files} | tr " " "\n" \
    | xargs -I @ echo "  x @"

  echo "Deployment canceled."
  exit 1
fi

# 1. 既存のSSHのキー（authorized_keysファイルと秘密鍵）、
#    known_hosts, known_hosts.oldを、このGitリポジトリのディレクトリに移動
echo "[1] Moved existing files:"

## authorized_keys
mv ${ssh_dirpath}/authorized_keys ./

echo "  * ${ssh_dirpath}/authorized_keys -> ${repository_dirpath}/authorized_keys"

## 秘密鍵
find ${ssh_dirpath} -type f -name \*.${private_key_ext} \
  | while read fullpath; do

    sed_script="s|^$(echo ${ssh_dirpath} | sed -r 's|\.|\\.|g')/?(.*)?$|\1|"
    subdirpath=$(dirname $(echo ${fullpath}) | sed -r "${sed_script}")

    # 秘密鍵がサブディレクトリにある場合は、サブディレクトリを作成
    if [ "${subdirpath}" != "" ] && [ ! -d ./${subdirpath} ]; then
      mkdir -p ./${subdirpath}
    fi

    mv ${fullpath} ./${subdirpath}

    filename=$(basename ${fullpath})
    echo "  * ${fullpath} -> ${repository_dirpath}/${subdirpath}/${filename}" | tr -s /
  done

## known_hosts*
find ${ssh_dirpath} -type f -name 'known_hosts*' \
  | while read fullpath; do
    mv ${fullpath} ./

    filename=$(basename ${fullpath})
    echo "  * ${fullpath} -> ${repository_dirpath}/${filename}"
  done

# 2. ~/.sshディレクトリを削除
rm -rf ${ssh_dirpath}

echo "[2] Removed ${ssh_dirpath}/ directory."

# 3. このGitリポジトリを~/.sshディレクトリに
mv ${repository_dirpath} ${ssh_dirpath}

echo "[3] Moved ${repository_dirpath}/ as a new ${ssh_dirpath}/ directory."

echo "Mission Accomplished!"
