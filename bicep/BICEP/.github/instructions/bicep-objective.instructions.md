---
applyTo: "/Users/akkoike/Desktop/TEST/bicep/BICEP/VibeCording/**"
---

# 役割
- Bicep テンプレートを使った Azure 環境の標準化を求められた場合に、テンプレート作成時に準拠する条件を定義します。
# 目的
- Azure の標準化環境を構築するための Bicep テンプレートの作成条件を明確にします。
# コーディング規約
- Bicep テンプレートのコーディング規約は、.github/instructions/bicep-cordingrule.instructions.md に従ってください。
# Bicep テンプレートを作成する際の命名規則と構成要素
- 以下に示すAzureのベストプラクティスに従ってください。
  - リソース命名規則(https://docs.microsoft.com/ja-jp/azure/architecture/best-practices/naming-conventions)
  - タグ付けポリシー(https://docs.microsoft.com/ja-jp/azure/azure-resource-manager/management/tag-resources?tabs=json)
    - タグでは、環境(env)、プロジェクト(project)を必須とします。
    - メールアドレスは akkoike@microsoft.com とします。
# デプロイする Azure のリソースは以下のリソースとします。記載のないリソースは利用しません。
  - Azure Virtual Network と Subnet
  - Azure VNet Peering
  - Azure Network Security Group
  - Azure User Defined Route
  - Azure DNS Zone
  - Azure Storage Account
  - Azure Log Analytics Workspace
  - Azure Diagnostic Settings
  - Azure Virtual Machine
  - Azure VM Extension
  - Azure Firewall
  - Azure Bastion
  - Azure Key Vault
  - Azure Private Endpoint
  - Azure Backup
# bicep テンプレートのモジュール構成
- main-standard.bicepをルートモジュールとして作成します。
  - modules フォルダを作成し、その中にbicepモジュールを配置します。
    - vnet.bicep: Azure Virtual Network と Subnet を作成するモジュール
    - vnet-peering.bicep: VNet Peering を構成するモジュール
  - main-standard.bicep から上記モジュールを呼び出して、必要なリソースをデプロイします。
- 環境ごとのパラメータファイルを作成します。
  - dev-standard.bicepparam: 開発環境用パラメータ
  - stag-standard.bicepparam: 検証環境用パラメータ
  - prod-standard.bicepparam: 本番環境用パラメータ
- デプロイメントシェルスクリプトを作成します。
  - Deploy-AzureStandardization.sh: Bicepテンプレートをデプロイするためのシェルスクリプト
# ファイル構成

```
VibeCording/
├── main-standard.bicep                     # メインテンプレート
├── dev-standard.bicepparam                 # 開発環境パラメータ
├── stag-standard.bicepparam                # 検証環境パラメータ
├── prod-standard.bicepparam                # 本番環境パラメータ
├── Deploy-AzureStandardization.sh          # デプロイメントシェル
├── modules/
│   ├── vnet.bicep                          # VNetモジュール
│   ├── vnet-peering.bicep                  # VNetピアリングモジュール
│   ├── azfw.bicep                          # Azure Firewall モジュール
│   ├── bastion.bicep                       # Azure Bastion モジュール
│   ├── storageaccnt.bicep                  # ストレージアカウントモジュール
│   ├── keyvault.bicep                      # Key Vault モジュール
│   ├── loganalytics.bicep                  # Log Analytics ワークスペースモジュール
│   ├── vm.bicep                            # Virtual Machine モジュール
│   ├── backup.bicep                        # Backup モジュール
│   ├── asr.bicep                           # Site Recovery モジュール
│   ├── rbac.bicep                          # RBAC モジュール
│   └── diagnostics.bicep                   # Diagnostics モジュール
└── README.md                               # Readmeファイル
```

# ネットワーク構成要件
- .github/instructions/bicep-network.instructions.md に記載のネットワーク構成要件に従ってください。
# ログ収集要件
- .github/instructions/bicep-log.instructions.md に記載のログ収集要件に従ってください。
# コンピューティングリソース要件
- .github/instructions/bicep-compute.instructions.md に記載のコンピューティングリソース要件に従ってください。
# セキュリティ要件
- .github/instructions/bicep-security.instructions.md に記載のセキュリティ要件に従ってください。
# AI 要件
- .github/instructions/bicep-ai.instructions.md に記載のAI要件に従ってください。