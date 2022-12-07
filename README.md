# ssh-bastion-config-scaffold

SSH踏み台ホストに設置する~/.ssh/configファイルを管理するGitリポジトリの雛形です。
デプロイや変更が容易にできるように工夫しています。

> **Note**  
> SSH踏み台ホスト上で必要になる「踏み台ホストから他のホストにSSH接続するための秘密鍵」は、セキュリティの観点から管理対象に含めません。別の方法で管理・デプロイする想定です。

## 前提

~/.ssh/ディレクトリ配下に、以下のファイル**のみ**が含まれているものとします：

* authorized_keys（踏み台ホストにSSH接続するための、踏み台ホストの公開鍵）
* known_hosts
* known_hosts.old
* 踏み台ホストから他のホストにSSH接続するための秘密鍵

### 秘密鍵の置き場所について

「踏み台ホストから他のホストにSSH接続するための秘密鍵は、~/.ssh/配下のどこかに置いてある」という想定です。つまり、独自の専用のサブディレクトリ（深さ問わず）に秘密鍵を集めていても大丈夫です。

```bash
# OKな例その1
~/.ssh/
├── authorized_keys
├── known_hosts
├── known_hosts.old
├── foo.pem
└── bar.pem
```

```bash
# OKな例その2
~/.ssh/
├── authorized_keys
├── known_hosts
├── known_hosts.old
└── private_keys/
    ├── foo.pem
    └── bar.pem
```

## 使い方

### 新規デプロイ

SSH踏み台ホストにログインしてください。

1. 適当なディレクトリで、このリポジトリを`git clone`します：

   ```bash
   git clone https://github.com/shu-i-chi/ssh-bastion-config-scaffold.git ssh-bastion-host-config
   ```

2. **（秘密鍵の拡張子が、pemではない場合）**

   もし、踏み台ホストからその先へSSH接続するための秘密鍵の拡張子が、**pemではない**場合は、deploy.shの冒頭のシェル変数を編集してください：

   ```bash
   vim ./ssh-bastion-host-config/deploy.sh
   ```

   > ```bash
   > # 秘密鍵の拡張子（'.'抜き）
   > private_key_ext="pem"
   > ```

3. シェルスクリプトdeploy.shを実行します：

   ```bash
   ./ssh-bastion-host-config/deploy.sh
   ```

   これで、以下のようになります：

   * ~/.ssh/ディレクトリがGitリポジトリになる
   * ~/.ssh/configを配置
   * ~/.ssh/配下に元々あったSSHのキー関係はそのまま
   * `git clone`してできたssh-bastion-host-config/ディレクトリを削除（掃除）

   > **Warning**  
   > スクリプト実行時に、[前提](#前提)の項に挙げられているもの**以外**のファイルが含まれていた場合は、エラーメッセージを出して処理を中止します。
   > エラーメッセージで列挙されたファイルを、~/.ssh/ディレクトリ配下から移動して、再度deploy.shを実行してください。

#### rootユーザとしてローカルユーザのデプロイを行う場合

rootユーザが、デプロイを実施する場合は、手順に以下の変更があります：

* 環境変数`HOME`に、ローカルユーザのホームディレクトリを指定してdeploy.shを実行
* デプロイしてできた.sshディレクトリの所有者を変更

```bash
git clone https://github.com/shu-i-chi/ssh-bastion-config-scaffold.git ssh-bastion-host-config

vim ./ssh-bastion-host-config/deploy.sh # 秘密鍵の拡張子がpem以外の場合

HOME=/home/<user-name> ./ssh-bastion-host-config/deploy.sh

chown -R <user-name>:<user-group> /home/<user-name>/.ssh
```

### リモートGitリポジトリの設定

デプロイが完了したら、~/.ssh/ディレクトリに移動し、リモートGitリポジトリを自分のものに変更してください：

```bash
cd ~/.ssh

git remote set-url origin <your-remote-git-repository-url>

git remote -v # 確認
```

### configファイルの更新

1. ~/.ssh/ディレクトリに移動する
2. ~/.ssh/configファイルを直接編集する
3. 変更した~/.ssh/configファイルを`git add`＆`git commit`する
4. リモートGitリポジトリに`git push`する

### 最新の~/.ssh/configに更新（自分のリモートGitリポジトリから）

~/.ssh/ディレクトリ配下にて`git pull`します：

```bash
cd ~/.ssh/

git pull
```

SSHのキー関係のファイルには影響ありません。

> **Warning**  
> コミットしていない変更や、ファイル変更のコンフリクトがある場合は、当然`git pull`に失敗します。
> 原因を解消してから、再度`git pull`してください。
