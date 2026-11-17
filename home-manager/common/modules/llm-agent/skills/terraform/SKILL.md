---
name: terraform
description: Terraformのコードを書く・直すときの書き方のルール。.tfファイルを新しく書くとき、リソースやprovider、backend、variable、outputを足すとき、Terraformの版を上げるとき、checkovの指摘を直すとき、またはユーザーが「Terraformで作って」「tfを直して」と言ったときに、ユーザーがルールに触れなくても必ず使う。Rules for writing and editing Terraform code.
---

# Terraform

## ファイルの分け方

ルートのディレクトリでは、ブロックの種類ごとに次の名前のファイルへ書く。

| ファイル | 書くもの |
|---|---|
| `provider.tf` | `terraform` ブロックと、aliasのものを含むすべての `provider` ブロック |
| `backend.tf` | `backend` ブロック |
| `locals.tf` | `locals` ブロック |
| `variables.tf` | `variable` ブロック |
| `data.tf` | `data` ブロック |
| `iam.tf` | IAMのポリシーと `aws_iam_policy_document` |
| `output.tf` | `output` ブロック |
| `<まとまり>.tf` | それ以外のリソース。`network.tf`、`database.tf` のように、まとまりごとに分ける |

- ファイル名
    - 単語をアンダースコアでつなぐ
        - `vpc_endpoint.tf`

## 版の固定

版は最新を使い、完全に固定する。

```hcl
terraform {
  required_version = "= 1.17.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.73.0"
    }
  }
}
```

- `required_version`
    - `= x.y.z` で書く
- `required_providers` の `version`
    - `= x.y.z` で書く
- `.terraform.lock.hcl`
    - コミットする
- Terraformから使う外部の依存
    - 版とダイジェストで固定する
        - Dockerのベースイメージの例
            - `FROM <image>:<version>@sha256:<digest>`
- CIのワークフローで使うaction
    - コミットのSHAで固定する
        - `uses: actions/checkout@<commit-sha> # vX.Y.Z`

## backend

`key` は `backend.tf` に書き、バケット名は環境変数から `TF_CLI_ARGS_init` で渡す。

```hcl
terraform {
  backend "s3" {
    key          = "my-app/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

```bash
# .envrc
export TF_CLI_ARGS_init="-backend-config=bucket=${TF_BACKEND_BUCKET}"
```

`terraform init` は引数を付けずに打つ。

## justfile

- justfileに置くコマンド
    - デプロイのように何度も打つもの

## provider

- AWSのprofile
    - デフォルトのprofileを使う
- Google Cloudのproject
    - 環境変数から取る
        - `GOOGLE_PROJECT`
        - `GOOGLE_CLOUD_PROJECT`
- リージョンの違い
    - aliasのproviderで分ける
    - aliasのproviderに書く引数
        - `alias`
        - `region`

```hcl
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}
```

## 値の置き場所

- localsに書くもの
    - ドメイン名
    - 予算の額
    - タグの中身
    - ラベルの中身
- dataで取るもの
    - アカウントID
        - `data.aws_caller_identity.current.account_id`
    - リージョン
        - `data.aws_region.<名前>.region`
    - Google Cloudのプロジェクト
        - `data.google_project.current`
    - 請求先アカウント
        - `data.google_project.current.billing_account`
- variableにするもの
    - localsにもdataにも置けない値だけ
- variableの `description`
    - 必ず書く

## output

outputは、ほかのプログラムが参照するときだけ書く。参照するコードを書く変更で、そのoutputも一緒に足す。

- ほかのプログラム
    - justfile
    - lambroll
    - スクリプト
    - もう一方のTerraformのディレクトリ
- `description`
    - 参照する側の名前を書く

```hcl
output "app_bucket" {
  description = "Read by just deploy"
  value       = aws_s3_bucket.app.bucket
}
```

## タグとラベル

- 中身を置くlocals
    - `local.common_tags`
    - `local.common_labels`
- 各リソースに書くもの
    - タグを受け付けるリソース
        - `tags = local.common_tags`
    - ラベルを受け付けるリソース
        - `labels = local.common_labels`
    - どちらも受け付けないリソース
        - `checkov:skip` に理由を1行で書く
- 付け忘れ
    - checkovのカスタムルールで落とす
    - ルールは `terraform/checkov/` に置く

```hcl
resource "aws_iam_role_policy" "app" {
  # checkov:skip=CKV_EXAMPLE_1:Resource does not support tags
  name   = "my-app"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.app.json
}
```

## S3のバケット

S3のバケットはaccount regional namespaceで作り、名前の末尾を `-<アカウントID>-<リージョン>-an` にする。

```hcl
resource "aws_s3_bucket" "app" {
  bucket           = format("my-app-%s-%s-an", data.aws_caller_identity.current.account_id, data.aws_region.current.region)
  bucket_namespace = "account-regional"

  tags = local.common_tags
}
```

- リージョン
    - バケットを作るproviderの `data "aws_region"` から取る

## リソースの書き方

- ローカル名
    - snake_caseで書く
    - 役割で名付ける
        - `app_bucket`
        - `deploy_role`
- クラウド上の名前
    - 先頭にプロジェクト名を付ける
        - `name = "my-app-api"`
- 繰り返し
    - `for_each` を使う
- IAMのポリシー
    - `aws_iam_policy_document` で書く
    - `iam.tf` に置く

## コメント

コード内のコメントには、コードから読み取れない理由を書く。英語で1行に収める。

## アカウントの詳細と別のプロジェクト

コード、コメント、PR、issue、コミットメッセージでは、アカウントの詳細と別のプロジェクトに触れない。

- アカウントの詳細
    - アカウントID
    - backendのバケット名
    - メールアドレス
- 別のプロジェクト
    - 別のリポジトリの名前
    - 別のリポジトリのリソース

## 検査

GitHub ActionsのワークフローをCIとして `.github/workflows/` に置き、ルートのディレクトリごとに次を走らせる。

- `terraform fmt -check`
- `terraform init -backend=false` のあとの `terraform validate`
- `checkov --external-checks-dir terraform/checkov`
