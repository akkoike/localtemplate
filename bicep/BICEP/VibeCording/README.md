# Azure 標準化テンプレート

このプロジェクトは、Azureの標準化環境を構築するためのBicepテンプレート集です。

## 概要

このテンプレートは、以下のAzureリソースをデプロイし、エンタープライズグレードのクラウドインフラストラクチャを構築します。

### デプロイされるリソース

- **ネットワーク**
  - Azure Virtual Network (Hub-VNet, Workspace-VNet, Spoke-VNet-1, Spoke-VNet-2)
  - VNet Peering (Hub-and-Spoke構成)
  - Azure Firewall (アウトバウンドトラフィック制御)
  - Azure Bastion (セキュアなVM接続)
  - Network Security Group (NSG) - VMサブネット用
  - User Defined Route (UDR) - Spoke VNet用
  - Network Watcher (ネットワーク監視)
  - NSG Flow Logs (トラフィック分析)

- **コンピューティング**
  - Azure Virtual Machines (Ubuntu 20.04 LTS、可用性ゾーン対応)
  - Azure VM Extensions (Azure Monitor エージェント)

- **セキュリティ**
  - Azure Key Vault (シークレット管理)
  - User Assigned Managed Identity
  - RBAC (Role-Based Access Control)
  - Azure Policy (コンプライアンス管理)
  - Private Endpoint (Storage Account, Log Analytics Workspace)

- **監視とログ**
  - Azure Log Analytics Workspace (Private Link経由)
  - Azure Monitor Private Link Scope (AMPLS)
  - Azure Storage Account (診断ログ保存)
  - Azure Monitor Alert Rules (CPU、メモリ、ネットワーク監視)
  - 診断設定 (全リソース対応)

- **バックアップ**
  - Azure Recovery Services Vault
  - VM バックアップポリシー (日次バックアップ、30日間保持)

## 前提条件

- Azure CLI がインストールされていること
- Azure サブスクリプションへのアクセス権があること
- 適切な権限 (Contributor 以上) があること

## ファイル構成

```
VibeCording/
├── main-standard.bicep                     # メインテンプレート
├── dev-standard.bicepparam                 # 開発環境パラメータ
├── stag-standard.bicepparam                # 検証環境パラメータ
├── prod-standard.bicepparam                # 本番環境パラメータ
├── Deploy-AzureStandardization.sh          # デプロイメントスクリプト
├── modules/                                # Bicepモジュール
│   ├── vnet.bicep                          # VNetモジュール
│   ├── vnet-peering.bicep                  # VNetピアリングモジュール
│   ├── nsg.bicep                           # Network Security Groupモジュール
│   ├── routetable.bicep                    # Route Tableモジュール
│   ├── nsgflowlog.bicep                    # NSG Flow Logモジュール
│   ├── azfw.bicep                          # Azure Firewall モジュール
│   ├── bastion.bicep                       # Azure Bastion モジュール
│   ├── nwatcher.bicep                      # Network Watcher モジュール
│   ├── storageaccount.bicep                # ストレージアカウントモジュール
│   ├── keyvault.bicep                      # Key Vault モジュール
│   ├── loganalytics.bicep                  # Log Analytics ワークスペースモジュール
│   ├── ampls.bicep                         # Azure Monitor Private Link Scopeモジュール
│   ├── amplsscopedresource.bicep           # AMPLS Scoped Resourceモジュール
│   ├── privateendpoint.bicep               # Private Endpointモジュール
│   ├── vm.bicep                            # Virtual Machine モジュール
│   ├── backup.bicep                        # Backup モジュール
│   ├── policy.bicep                        # Policy モジュール
│   ├── rbac.bicep                          # RBAC モジュール
│   ├── u-managedid.bicep                   # User Managed Identity モジュール
│   └── alertrule.bicep                     # Alert Rule モジュール
└── README.md                               # このファイル
```

## ネットワーク構成

### Hub-VNet (10.0.0.0/16)
- GatewaySubnet: 10.0.0.0/24
- AzureFirewallSubnet: 10.0.1.0/26
- AzureBastionSubnet: 10.0.2.0/26

### Workspace-VNet (10.1.0.0/16)
- private-endpoint-subnet: 10.1.0.0/24

### Spoke-VNet-1 (192.168.0.0/16)
- AppSubnet: 192.168.0.0/24
- DBSubnet: 192.168.1.0/24

### Spoke-VNet-2 (172.16.0.0/16)
- VMSubnet: 172.16.0.0/24

## デプロイ手順

### 1. Azure CLIでログイン

```bash
az login
```

### 2. デプロイメントスクリプトを実行

```bash
# 開発環境へのデプロイ
./Deploy-AzureStandardization.sh -e dev -s <your-subscription-id>

# 検証環境へのデプロイ
./Deploy-AzureStandardization.sh -e stag -s <your-subscription-id>

# 本番環境へのデプロイ
./Deploy-AzureStandardization.sh -e prod -s <your-subscription-id>
```

### 3. デプロイメントの確認

```bash
az deployment sub show --name <deployment-name>
```

## パラメータのカスタマイズ

各環境のパラメータファイル (`dev-standard.bicepparam`, `stag-standard.bicepparam`, `prod-standard.bicepparam`) を編集して、以下のパラメータをカスタマイズできます。

- `Location`: デプロイ先のAzureリージョン (デフォルト: japaneast)
- `Environment`: 環境名 (dev, stag, prod)
- `ProjectName`: プロジェクト名
- `AdminEmail`: 管理者のメールアドレス (アラート通知先)
- `BackupRetentionDays`: バックアップ保持期間 (日数)
- `LogRetentionDays`: ログ保持期間 (日数)
- `CostBudgetAmount`: コスト予算アラート金額 (USD)

## セキュリティ考慮事項

- すべてのリソースには適切なタグが付与されます (`env`, `project`, `email`)
- Key Vaultは閉域接続のみ許可 (`publicNetworkAccess: Disabled`)
- Storage Accountは暗号化されたHTTPS通信のみ許可 (TLS 1.2以上)
- VMへのアクセスはAzure Bastion経由のみ (パブリックIPなし)
- すべてのアウトバウンドトラフィックはAzure Firewall経由
- User Assigned Managed Identityを使用した認証
- NSGによるサブネットレベルのトラフィック制御
- Private Endpointによる閉域接続 (Storage, Log Analytics)
- Log Analytics WorkspaceはPrivate Link経由でのみアクセス可能
- NSG Flow Logsによるネットワークトラフィックの可視化
- 全リソースの診断ログをLog AnalyticsとStorageに保存

## 監視とアラート

以下の条件でアラートが発生します:

- CPU使用率が80%を超えた状態が5分以上継続
- メモリ使用率が75%を超えた状態が5分以上継続
- ディスク使用率が85%を超えた状態が5分以上継続
- ネットワーク受信トラフィックが1分間に300MBを超過
- ネットワーク送信トラフィックが1分間に300MBを超過
- Azure Backupジョブが失敗

## コンプライアンス

このテンプレートは以下のコンプライアンス要件に準拠しています:

- Microsoft Cloud Security Benchmark (MCSB)
- 許可されたリージョンのみへのデプロイ (Japan East, Japan West)
- 必須タグの強制 (`env` タグ)

## トラブルシューティング

### デプロイメントが失敗する場合

1. Azure CLIのバージョンを確認
```bash
az --version
```

2. サブスクリプションの権限を確認
```bash
az role assignment list --assignee <your-email> --output table
```

3. デプロイメントログを確認
```bash
az deployment sub show --name <deployment-name> --query properties.error
```

### リソース名の競合

一部のリソース (Storage AccountやKey Vault) はグローバルに一意である必要があります。`ProjectName`パラメータを変更して再デプロイしてください。

## ライセンス

このプロジェクトはサンプルテンプレートです。本番環境で使用する前に、組織のセキュリティポリシーとコンプライアンス要件を確認してください。

## 作成者

- Email: akkoike@microsoft.com
- プロジェクト: Azure標準化テンプレート

## 更新履歴

- 2025-11-18: 初版作成
