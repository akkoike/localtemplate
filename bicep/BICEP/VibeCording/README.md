# Azure 標準化環境 - Bicep テンプレート# Azure 標準化環境 Bicepテンプレート



このリポジトリには、Azure標準化環境をHub-Spokeトポロジーで構築するためのBicepテンプレートが含まれています。このリポジトリには、Azure上に標準化されたHub-Spokeネットワークトポロジー + Workspace VNetを構築するためのBicepテンプレートが含まれています。



## 📋 概要## 概要



このテンプレートは、以下のリソースを含むエンタープライズグレードのAzure環境を構築します:このテンプレートは以下の構成を自動的にデプロイします：



### ネットワーク構成### ネットワーク構成

- **4つのVirtual Network**- **Hub Virtual Network** (10.0.0.0/16)

  - Hub VNet (10.0.0.0/16) - ゲートウェイ、ファイアウォール、Bastion用  - GatewaySubnet: 10.0.0.0/24

  - Workspace VNet (10.1.0.0/16) - Private Endpoint用  - AzureFirewallSubnet: 10.0.1.0/26

  - Spoke-1 VNet (192.168.0.0/16) - アプリケーションとDB用  - AzureBastionSubnet: 10.0.2.0/26

  - Spoke-2 VNet (172.16.0.0/16) - VM用

- **VNet Peering** - Hub-Spokeトポロジー- **Workspace Virtual Network** (10.1.0.0/16)

- **Network Security Groups (NSG)** - 各サブネット用  - private-endpoint-subnet: 10.1.0.0/24

- **Route Tables** - Azure Firewall経由のルーティング

- **Spoke Virtual Network 1** (192.168.0.0/16)

### セキュリティとコンプライアンス  - AppSubnet: 192.168.0.0/24

- **Azure Firewall** - ネットワークセキュリティ  - DBSubnet: 192.168.1.0/24

- **Azure Bastion** - セキュアなVM接続

- **Azure Key Vault** - シークレット管理- **Spoke Virtual Network 2** (172.16.0.0/16)

- **Private Endpoints** - Azure Storage用  - VMSubnet: 172.16.0.0/24

- **Azure Monitor Private Link Scope (AMPLS)** - Log Analytics用

- **VNet ピアリング**

### コンピューティングとストレージ  - Hub から各Spokeへのピアリング

- **Virtual Machines** - 各SpokeVNetに2台ずつ(可用性ゾーン分散)  - 各Spoke から Hubへのピアリング

  - サイズ: Standard_D4s_v3

  - OS: Ubuntu 20.04 LTS### データ・ログ基盤

  - Azure Monitor Agent統合- **Storage Account** (Private Endpoint経由)

- **Storage Account** - Private Endpoint経由  - Workspace VNetからプライベート接続

- **Recovery Services Vault** - VMバックアップ(30日保持)  - Blob Storage対応



### 監視とログ- **Log Analytics Workspace** (Private Endpoint経由)

- **Log Analytics Workspace** - 90日保持  - 統合ログ収集基盤

- **Diagnostic Settings** - 全リソース対象  - 環境別のログ保持期間設定



## 🏗️ アーキテクチャ## ファイル構成



``````

Hub VNet (10.0.0.0/16)VibeCording/

├── GatewaySubnet (10.0.0.0/24)├── main-standard.bicep                    # メインテンプレート

├── AzureFirewallSubnet (10.0.1.0/26) - Azure Firewall├── dev-standard.bicepparam               # 開発環境パラメータ

└── AzureBastionSubnet (10.0.2.0/26) - Azure Bastion├── stag-standard.bicepparam              # 検証環境パラメータ

         |├── prod-standard.bicepparam              # 本番環境パラメータ

         | VNet Peering├── Deploy-AzureStandardization.sh        # デプロイメントシェル

         |├── modules/

         ├─────────────────────────────────────┐│   ├── vnet.bicep                        # VNetモジュール

         |                                     |│   ├── vnet-peering.bicep               # VNetピアリングモジュール

Workspace VNet (10.1.0.0/16)        Spoke-1 VNet (192.168.0.0/16)│   ├── storageaccount.bicep             # ストレージアカウントモジュール

└── PE Subnet (10.1.0.0/24)         ├── AppSubnet (192.168.0.0/24)│   └── loganalytics.bicep               # Log Analytics ワークスペースモジュール

    ├── Storage PE                  └── DBSubnet (192.168.1.0/24)└── README.md                            # このファイル

    └── Log Analytics PE                 └── VM x2 (Zone 1, 2)```

                                              |

                                    Spoke-2 VNet (172.16.0.0/16)## 前提条件

                                    └── VMSubnet (172.16.0.0/24)

                                         └── VM x2 (Zone 1, 2)### 必要なツール

```- Azure PowerShell モジュール

- Azure CLI（オプション）

## 📦 ファイル構成- Bicep CLI



```### インストール手順

VibeCording/

├── main-standard.bicep              # メインテンプレート1. **Azure PowerShell モジュールのインストール**

├── dev-standard.bicepparam          # 開発環境パラメータ   ```powershell

├── stag-standard.bicepparam         # ステージング環境パラメータ   Install-Module -Name Az -Repository PSGallery -Force

├── prod-standard.bicepparam         # 本番環境パラメータ   ```

└── modules/                         # 再利用可能なモジュール

    ├── vnet.bicep                   # Virtual Network2. **Bicep CLIのインストール**

    ├── vnet-peering.bicep           # VNet Peering   ```powershell

    ├── nsg.bicep                    # Network Security Group   # Azure CLIを使用する場合

    ├── routetable.bicep             # Route Table   az bicep install

    ├── loganalytics.bicep           # Log Analytics Workspace   

    ├── storageaccount.bicep         # Storage Account with PE   # または直接インストール

    ├── keyvault.bicep               # Key Vault   winget install Microsoft.Bicep

    ├── vm.bicep                     # Virtual Machine   ```

    └── backup.bicep                 # Recovery Services Vault

```## デプロイ手順



## 🚀 デプロイ手順### 1. Azure認証



### 前提条件```bash

# Azureにログイン

1. Azure CLI または Azure PowerShell がインストールされていることaz login

2. Azureサブスクリプションへのアクセス権限

3. 適切なRBACロール (Contributor以上)# サブスクリプションを確認

az account list --output table

### デプロイコマンド

# 適切なサブスクリプションを設定

#### Azure CLI を使用する場合az account set --subscription "your-subscription-id"

```

```bash

# リソースグループを作成### 2. シェルスクリプトによるデプロイ

az group create --name rg-azstd-dev --location japaneast

#### 開発環境のデプロイ

# VM管理者パスワードを環境変数に設定```bash

export VM_ADMIN_PASSWORD="YourSecurePassword123!"chmod +x Deploy-AzureStandardization.sh

./Deploy-AzureStandardization.sh -e dev -s "your-subscription-id"

# デプロイを実行```

az deployment group create \

  --resource-group rg-azstd-dev \#### 検証環境のデプロイ

  --template-file main-standard.bicep \```bash

  --parameters dev-standard.bicepparam \./Deploy-AzureStandardization.sh -e stag -s "your-subscription-id"

  --parameters VmAdminPassword=$VM_ADMIN_PASSWORD```

```

#### 本番環境のデプロイ（確認プロンプト付き）

#### Azure PowerShell を使用する場合```bash

./Deploy-AzureStandardization.sh -e prod -s "your-subscription-id"

```powershell```

# リソースグループを作成

New-AzResourceGroup -Name rg-azstd-dev -Location japaneast#### What-Ifによる事前確認

```bash

# VM管理者パスワードをSecureStringに変換./Deploy-AzureStandardization.sh -e prod -s "your-subscription-id" -w

$securePassword = ConvertTo-SecureString "YourSecurePassword123!" -AsPlainText -Force```



# デプロイを実行### 3. Azure CLIによるデプロイ（代替手段）

New-AzResourceGroupDeployment `

  -ResourceGroupName rg-azstd-dev `#### 開発環境

  -TemplateFile .\main-standard.bicep ````bash

  -TemplateParameterFile .\dev-standard.bicepparam `az deployment group create \

  -VmAdminPassword $securePassword  --resource-group azstd-dev-rg \

```  --template-file main-standard.bicep \

  --parameters dev-standard.bicepparam

### What-If デプロイ (変更プレビュー)```



デプロイ前に変更内容を確認できます:#### 検証環境

```bash

```bashaz deployment group create \

az deployment group what-if \  --resource-group azstd-stag-rg \

  --resource-group rg-azstd-dev \  --template-file main-standard.bicep \

  --template-file main-standard.bicep \  --parameters stag-standard.bicepparam

  --parameters dev-standard.bicepparam \```

  --parameters VmAdminPassword=$VM_ADMIN_PASSWORD

```#### 本番環境

```bash

## 🔐 セキュリティに関する注意事項az deployment group create \

  --resource-group azstd-prod-rg \

1. **VM管理者パスワード**  --template-file main-standard.bicep \

   - パラメータファイルにパスワードを直接記述しないでください  --parameters prod-standard.bicepparam

   - 環境変数またはAzure Key Vaultから取得することを推奨します```

   - 強力なパスワードを使用してください(最低12文字、大小英字+数字+記号)

## パラメータカスタマイズ

2. **Key Vault アクセス**

   - デプロイ後、Key Vault RBACロールを適切に設定してください環境固有の設定を変更するには、対応する `.bicepparam` ファイルを編集してください：

   - VM管理者認証情報はKey Vaultのシークレットとして保存されます

### 開発環境 (dev-standard.bicepparam)

3. **ネットワークセキュリティ**```bicep

   - NSGルールは最小権限の原則に基づいて構成されていますparam Environment = 'dev'

   - 必要に応じてルールをカスタマイズしてくださいparam Location = 'japaneast'

param ProjectName = 'azstd'

## 📊 デプロイ時間param AdminEmail = 'akkoike@microsoft.com'

```

- 開発環境: 約30-40分

- ステージング環境: 約30-40分### カスタマイズ可能な項目

- 本番環境: 約35-45分 (GRS ストレージのため)- **Environment**: 環境識別子 (dev/stag/prod)

- **Location**: Azureリージョン

## 🔧 カスタマイズ- **ProjectName**: プロジェクト名（3-10文字）

- **AdminEmail**: 管理者メールアドレス

### VM サイズの変更

## 標準化機能

`main-standard.bicep` の VM モジュール呼び出し部分で `vmSize` パラメータを変更:

### リソース命名規則

```bicep- パターン: `{ProjectName}-{Environment}-{ResourceType}`

module vmSpoke1Zone1 './modules/vm.bicep' = {- 例: `azstd-dev-hub-vnet`

  params: {

    vmSize: 'Standard_D8s_v3'  // サイズを変更### タグ戦略

    // ...自動的に以下のタグが適用されます：

  }- **env**: 環境識別子

}- **project**: プロジェクト名

```- **owner**: 管理者メールアドレス

- **managedBy**: Bicep

### Log Analytics 保持期間の変更

### セキュリティ機能

`main-standard.bicep` の変数定義で `retentionInDays` を変更:- Private Endpoint経由のストレージアクセス

- Private DNS Zone統合

```bicep- VNetピアリングによる適切なネットワーク分離

var LogAnalyticsConfig = {- 環境別のアクセス制御準備

  name: '${ResourcePrefix}-law'- TLS 1.2以上の強制

  retentionInDays: 180  // 90日から180日に変更- パブリックアクセスの制限

}

```## 出力値



## 📝 タグ戦略デプロイ完了後、以下の情報が出力されます：



すべてのリソースには以下のタグが自動的に付与されます:- **HubVNetId**: Hub VNetのリソースID

- **HubVNetName**: Hub VNet名

- `env`: 環境識別子 (dev/stag/prod)- **WorkspaceVNetId**: Workspace VNetのリソースID

- `project`: プロジェクト名 (azstd)- **WorkspaceVNetName**: Workspace VNet名

- `owner`: 管理者メールアドレス- **SpokeVNet1Id**: Spoke VNet 1のリソースID

- `managedBy`: リソース管理方法 (Bicep)- **SpokeVNet1Name**: Spoke VNet 1名

- **SpokeVNet2Id**: Spoke VNet 2のリソースID

## 🐛 トラブルシューティング- **SpokeVNet2Name**: Spoke VNet 2名

- **LogAnalyticsWorkspaceId**: Log Analytics WorkspaceのリソースID

### デプロイエラー- **LogAnalyticsWorkspaceName**: Log Analytics Workspace名

- **StorageAccountId**: Storage AccountのリソースID

1. **リソース名の重複**- **StorageAccountName**: Storage Account名

   - Storage Account名は全Azure環境で一意である必要があります- **AppliedTags**: 適用されたタグ情報

   - `ProjectName` パラメータを変更してください- **ResourcePrefix**: 使用されたリソースプレフィックス



2. **クォータ不足**## トラブルシューティング

   - VM vCPU クォータを確認してください

   - 必要に応じてクォータ引き上げリクエストを送信してください### よくある問題



3. **権限エラー**1. **権限不足エラー**

   - デプロイ実行ユーザーに `Contributor` ロールが付与されているか確認してください   - Azure サブスクリプションの共同作成者権限が必要です

   - `Get-AzRoleAssignment` でロール割り当てを確認してください

### 既知の制限事項

2. **リージョン制限エラー**

- Azure Firewall と Azure Bastion は現在、テンプレートに含まれていません(既存のモジュールを統合予定)   - 指定したリージョンで利用できないリソースがある場合があります

- AMPLS (Azure Monitor Private Link Scope) の統合は今後のバージョンで実装予定   - `Location` パラメータを別のリージョンに変更してください



## 📚 参考資料3. **命名規則エラー**

   - リソース名が既に使用されている場合があります

- [Azure Bicep 公式ドキュメント](https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/bicep/)   - `OrganizationPrefix` または `ProjectName` を変更してください

- [Azure Hub-Spoke ネットワークトポロジー](https://learn.microsoft.com/ja-jp/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)

- [Azure ベストプラクティス](https://learn.microsoft.com/ja-jp/azure/cloud-adoption-framework/ready/azure-best-practices/)### ログ確認



## 📄 ライセンス```bash

# デプロイメント履歴の確認

このテンプレートは MIT ライセンスの下で提供されています。az deployment group list --resource-group "azstd-dev-rg" --output table



## 👥 貢献者# 詳細なエラー情報の確認

az deployment group show \

- Akira Koike (akkoike@microsoft.com) - プロジェクトオーナー  --resource-group "azstd-dev-rg" \

  --name "デプロイメント名" \

---  --query properties.error

```

**注意**: このテンプレートは開発・検証用です。本番環境で使用する前に、組織のセキュリティポリシーとコンプライアンス要件を満たしていることを確認してください。

## 拡張とカスタマイズ

### 新しいモジュールの追加

1. `modules/` ディレクトリに新しい `.bicep` ファイルを作成
2. `main-standard.bicep` でモジュールを参照
3. 必要に応じてパラメータファイルを更新

### ネットワーク構成の変更

1. `main-standard.bicep` の変数セクションでアドレス空間を修正
2. `modules/vnet.bicep` でサブネット構成を調整

## サポートとコントリビューション

### 問題報告
Issues セクションで問題を報告してください。

### コントリビューション
1. フォークを作成
2. フィーチャーブランチを作成
3. 変更をコミット
4. プルリクエストを作成

## ライセンス

MIT License

## 更新履歴

- **v1.0.0** (2025-11-11): 初回リリース
  - Hub-Spoke VNetトポロジー
  - Workspace VNetによるPrivate Endpoint統合
  - Storage Account (Private Endpoint対応)
  - Log Analytics Workspace
  - 環境別パラメータファイル (dev/stag/prod)
  - 自動デプロイシェルスクリプト
  - 標準化されたタグ戦略