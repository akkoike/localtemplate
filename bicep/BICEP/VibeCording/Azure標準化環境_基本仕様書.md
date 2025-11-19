# Azure 標準化環境 基本仕様書

## 文書情報

| 項目 | 内容 |
|------|------|
| 文書名 | Azure 標準化環境 基本仕様書 |
| 作成日 | 2025年11月18日 |
| 作成者 | akkoike@microsoft.com |
| バージョン | 1.0 |
| 対象プロジェクト | Azure標準化テンプレート |

---

## 1. 概要

### 1.1 目的
本文書は、Bicepテンプレートを使用したAzure環境の標準化構築における基本仕様を定義します。エンタープライズグレードのクラウドインフラストラクチャを構築するための要件、構成、および制約事項を明確にすることを目的とします。

### 1.2 適用範囲
本仕様書は、Azure標準化テンプレート（VibeCording）に適用され、開発環境、検証環境、本番環境のすべての環境に対して有効です。

### 1.3 対象リージョン
- **メインリージョン**: Japan East
- **セカンダリリージョン**: Japan West

---

## 2. デプロイするAzureリソース

以下のAzureリソースを標準環境としてデプロイします。記載されていないリソースは使用しません。

| カテゴリ | リソース名 | 用途 |
|---------|-----------|------|
| ネットワーク | Azure Virtual Network | 仮想ネットワーク |
| ネットワーク | Azure Subnet | サブネット |
| ネットワーク | Azure VNet Peering | VNet間接続 |
| ネットワーク | Azure Network Security Group | セキュリティグループ |
| ネットワーク | Azure User Defined Route | カスタムルート |
| ネットワーク | Azure DNS Zone | DNSゾーン |
| ネットワーク | Azure Firewall | ファイアウォール |
| ネットワーク | Azure Bastion | セキュアリモート接続 |
| ネットワーク | Azure Private Endpoint | プライベートエンドポイント |
| ストレージ | Azure Storage Account | ストレージアカウント |
| コンピューティング | Azure Virtual Machine | 仮想マシン |
| コンピューティング | Azure VM Extension | VM拡張機能 |
| 監視 | Azure Log Analytics Workspace | ログ分析ワークスペース |
| 監視 | Azure Diagnostic Settings | 診断設定 |
| セキュリティ | Azure Key Vault | シークレット管理 |
| セキュリティ | Azure Managed Identity | マネージドID |
| 管理 | Azure Backup | バックアップ |
| 管理 | Azure Site Recovery | ディザスタリカバリ |
| 管理 | Azure Policy | ポリシー管理 |

---

## 3. ネットワーク構成要件

### 3.1 仮想ネットワーク構成

#### 3.1.1 Hub-VNet
- **アドレス空間**: 10.0.0.0/16
- **サブネット構成**:
  - GatewaySubnet: 10.0.0.0/24
  - AzureFirewallSubnet: 10.0.1.0/26
  - AzureBastionSubnet: 10.0.2.0/26

#### 3.1.2 Workspace-VNet
- **アドレス空間**: 10.1.0.0/16
- **サブネット構成**:
  - private-endpoint-subnet: 10.1.0.0/24

#### 3.1.3 Spoke-VNet-1
- **アドレス空間**: 192.168.0.0/16
- **サブネット構成**:
  - AppSubnet: 192.168.0.0/24
  - DBSubnet: 192.168.1.0/24

#### 3.1.4 Spoke-VNet-2
- **アドレス空間**: 172.16.0.0/16
- **サブネット構成**:
  - VMSubnet: 172.16.0.0/24

### 3.2 VNet Peering構成
- Hub-VNetと各Spoke-VNet間でVNet Peeringを構成
- Hub-and-Spokeトポロジを採用
- 各Spoke-VNet間の直接通信は許可しない

### 3.3 Azure Firewall構成
- **配置場所**: Hub-VNet の AzureFirewallSubnet
- **パブリックIP**: 静的割り当て
- **ファイアウォールルール**:
  - 送信元: 各Spoke-VNetのアドレス空間
  - 宛先: *.azure.com (Azureサービス全般)
  - プロトコル: TCP
  - ポート: 443, 80
  - アクション: Allow
- **SKU**: Standard
- **可用性ゾーン**: Zone 1, 2, 3

### 3.4 Azure Bastion構成
- **配置場所**: Hub-VNet の AzureBastionSubnet
- **パブリックIP**: 静的割り当て
- **SKU**: Standard
- **用途**: Spoke-VNet内のVMへのRDP/SSHアクセス

### 3.5 閉域接続要件
- **Storage Account**: workspace-VNetのprivate-endpoint-subnet経由でPrivate Endpoint接続
- **Log Analytics Workspace**: workspace-VNetのprivate-endpoint-subnet経由でAzure Monitor Private Link Scope接続

### 3.6 ルーティング要件
- 各Spoke-VNetからのアウトバウンド通信は、Hub-VNetのAzure Firewall経由でデフォルトルート
- User Defined Route (UDR) を使用してトラフィックを制御

---

## 4. セキュリティ要件

### 4.1 コンプライアンス要件
- **準拠基準**: Microsoft Cloud Security Benchmark (MCSB)
- **Azure Policy適用**:
  - "Enforce tag and its value on resources"
  - "Allowed locations" (Japan East, Japan West のみ)
- **ポリシー違反時**: アラート生成および管理者通知
- **自動修復**: Azure Policyの自動修復機能を使用

### 4.2 ID管理要件
- **RBAC**: すべてのリソースに最小権限の原則を適用
- **所有者権限**: MOD Administrator に付与
- **マネージドID**: User Assigned Managed Identity を使用
- **権限スコープ**: 必要最小限の権限を適切なスコープに設定

### 4.3 シークレット管理要件
- **Key Vault配置**: Spoke-VNet内からアクセス可能
- **アクセスポリシー**: MOD Administrator に全権限
- **保存シークレット**:
  - 管理者ユーザー名: azureuser01
  - 管理者パスワード: p@ssw0rd1234!
- **暗号化**: Azure Storage Service Encryption (SSE)
- **公開アクセス**: 無効化 (Disabled)

### 4.4 ネットワークセキュリティ要件

#### 4.4.1 Network Security Group (NSG)
- **適用対象**: すべてのサブネット
- **VMSubnet インバウンドルール**:
  - ポート 22 (SSH): Azure Bastion経由のみ許可 (送信元: 10.0.2.0/26)
  - ポート 3389 (RDP): Azure Bastion経由のみ許可 (送信元: 10.0.2.0/26)
  - その他: すべて拒否

#### 4.4.2 Network Watcher
- **配置リージョン**: Japan East
- **NSG Flow Logs**: 有効化
- **ログ送信先**: Log Analytics Workspace
- **保存期間**: 90日
- **トラフィック分析**: 10分間隔

### 4.5 データ保護要件
- **通信暗号化**: TLS 1.2以上
- **保存時暗号化**: Azure Storage Service Encryption (SSE)

### 4.6 可用性および災害復旧要件
- **リージョン冗長**: サポートする場合は有効化
- **可用性ゾーン**: サポートするリソースは複数ゾーンに配置
- **ゾーン冗長**: サポートするサービスは有効化

---

## 5. コンピューティングリソース要件

### 5.1 Virtual Machine構成
- **配置場所**: Spoke-VNet-2の VMSubnet
- **VMサイズ**: Standard_D4s_v3
- **インスタンス数**: 2台
- **可用性ゾーン**: Zone 1, Zone 2 (それぞれ異なるゾーンに配置)
- **OS**: Ubuntu 20.04 LTS
- **認証方法**: パスワード認証
- **管理者認証情報**: Key Vault内のSecretを使用
- **パブリックIP**: 割り当てなし
- **ディスク**: Premium_LRS (128GB)

### 5.2 VM Extension
- **Azure Monitor Agent**: すべてのVMにインストール
- **接続先**: Log Analytics Workspace
- **収集データ**: 監視データおよびメトリック

### 5.3 バックアップ構成
- **サービス**: Azure Backup
- **バックアップ頻度**: 日次1回
- **保持期間**: 30日
- **バックアップ時刻**: 午前2時 (JST)
- **タイムゾーン**: Tokyo Standard Time

---

## 6. ログ収集および監視要件

### 6.1 Log Analytics Workspace
- **接続方法**: Azure Monitor Private Link Scope経由
- **パブリックエンドポイント**: 
  - データインジェスト: 無効
  - クエリアクセス: 有効
- **ログ保存期間**: 90日
- **価格レベル**: PerGB2018

### 6.2 診断設定
- **適用対象**: すべてのデプロイ済みリソース
- **ログ送信先**:
  - Azure Log Analytics Workspace
  - Azure Blob Storage
- **収集内容**:
  - すべてのログ (allLogs)
  - すべてのメトリック (AllMetrics)

### 6.3 Azure Monitor Private Link Scope (AMPLS)
- **配置**: Global
- **アクセスモード**:
  - Ingestion Access Mode: PrivateOnly
  - Query Access Mode: PrivateOnly
- **接続リソース**: Log Analytics Workspace

### 6.4 アラート通知要件

#### 6.4.1 通知先
- **メールアドレス**: akkoike@microsoft.com

#### 6.4.2 アラート条件

| アラート種別 | 閾値 | 期間 | 説明 |
|------------|------|------|------|
| CPU使用率 | 80%超過 | 5分以上継続 | CPU使用率高負荷 |
| メモリ使用率 | 75%超過 | 5分以上継続 | メモリ使用率高負荷 |
| ディスク使用率 | 85%超過 | 5分以上継続 | ディスク使用率高負荷 |
| ネットワーク受信 | 300MB超過 | 1分間 | 受信トラフィック異常 |
| ネットワーク送信 | 300MB超過 | 1分間 | 送信トラフィック異常 |
| バックアップ失敗 | - | 即時 | バックアップジョブ失敗 |

---

## 7. コスト最適化要件

### 7.1 リソースSKU選択
- **仮想マシン**: ワークロードに適したDシリーズを使用
- **ストレージ**: Standard_LRS (ローカル冗長ストレージ)
- **パフォーマンスと可用性**: 必要最小限のSKUを選択

### 7.2 自動スケーリング
- **適用対象**: Virtual Machine Scale Sets (将来拡張)
- **スケール条件**: 需要に応じた自動スケールアップ/ダウン

### 7.3 コスト監視
- **ツール**: Azure Cost Management + Billing
- **予算アラート**: $100/月
- **通知**: 予算超過時にメール通知

### 7.4 リソースライフサイクル管理
- **定期確認**: 使用されていないリソースを特定
- **対象リソース**:
  - 未使用の仮想マシン
  - アタッチされていないディスク
  - 未使用のパブリックIPアドレス
- **アクション**: 管理者への通知

---

## 8. Bicepテンプレート構成

### 8.1 ファイル構成

```
VibeCording/
├── main-standard.bicep                     # メインテンプレート
├── dev-standard.bicepparam                 # 開発環境パラメータ
├── stag-standard.bicepparam                # 検証環境パラメータ
├── prod-standard.bicepparam                # 本番環境パラメータ
├── Deploy-AzureStandardization.sh          # デプロイスクリプト
├── modules/
│   ├── vnet.bicep                          # VNetモジュール
│   ├── vnet-peering.bicep                  # VNetピアリング
│   ├── nsg.bicep                           # NSG
│   ├── routetable.bicep                    # Route Table
│   ├── nsgflowlog.bicep                    # NSG Flow Log
│   ├── azfw.bicep                          # Azure Firewall
│   ├── bastion.bicep                       # Azure Bastion
│   ├── nwatcher.bicep                      # Network Watcher
│   ├── storageaccount.bicep                # Storage Account
│   ├── keyvault.bicep                      # Key Vault
│   ├── loganalytics.bicep                  # Log Analytics
│   ├── ampls.bicep                         # AMPLS
│   ├── amplsscopedresource.bicep           # AMPLS Scoped Resource
│   ├── privateendpoint.bicep               # Private Endpoint
│   ├── vm.bicep                            # Virtual Machine
│   ├── backup.bicep                        # Backup
│   ├── policy.bicep                        # Policy
│   ├── rbac.bicep                          # RBAC
│   ├── u-managedid.bicep                   # Managed Identity
│   └── alertrule.bicep                     # Alert Rule
└── README.md                               # ドキュメント
```

### 8.2 コーディング規約

#### 8.2.1 命名規則
- **シンボリック名**: パスカルケース（例: myResourceGroup）
- **変数名**: アッパーキャメルケース（例: MyVariable）
- **定数**: 全て大文字とアンダースコア（例: MY_CONSTANT）
- **モジュール名**: 機能を明確に表す名前（例: NetworkModule.bicep）

#### 8.2.2 制約事項
- **@description**: 使用しない
- **Azure Verified Modules**: 使用しない
- **依存性**: dependsOn、parent、scopeを適切に使用
- **Output**: モジュール間の値の受け渡しのみに使用

### 8.3 タグ付けポリシー
すべてのリソースに以下のタグを必須で付与します:

| タグ名 | 説明 | 値の例 |
|--------|------|--------|
| env | 環境 | dev, stag, prod |
| project | プロジェクト名 | azurestandard |
| email | 管理者メールアドレス | akkoike@microsoft.com |

### 8.4 環境別パラメータ

| パラメータ | 開発環境 | 検証環境 | 本番環境 |
|-----------|---------|---------|---------|
| Location | japaneast | japaneast | japaneast |
| Environment | dev | stag | prod |
| ProjectName | azurestandard | azurestandard | azurestandard |
| AdminEmail | akkoike@microsoft.com | akkoike@microsoft.com | akkoike@microsoft.com |
| BackupRetentionDays | 30 | 30 | 30 |
| LogRetentionDays | 90 | 90 | 90 |

---

## 9. デプロイ手順

### 9.1 前提条件
- Azure CLI がインストールされていること
- Azure サブスクリプションへの適切なアクセス権（Contributor以上）
- Bicep CLI がインストールされていること

### 9.2 デプロイコマンド

```bash
# Azure CLIでログイン
az login

# デプロイスクリプトの実行
./Deploy-AzureStandardization.sh -e <環境> -s <サブスクリプションID>

# 例: 開発環境へのデプロイ
./Deploy-AzureStandardization.sh -e dev -s 00000000-0000-0000-0000-000000000000
```

### 9.3 デプロイ確認

```bash
# デプロイ状況の確認
az deployment sub show --name <デプロイ名>

# リソースグループの確認
az group list --tag env=dev
```

---

## 10. 運用管理

### 10.1 監視項目
- CPU、メモリ、ディスク使用率
- ネットワークトラフィック
- NSG Flow Logs
- バックアップジョブの成功/失敗
- Azure Policyコンプライアンス状況

### 10.2 定期メンテナンス
- **週次**: バックアップ状態の確認
- **月次**: コスト分析およびリソース最適化
- **四半期**: セキュリティ監査およびコンプライアンスレビュー

### 10.3 インシデント対応
- アラート受信時は速やかに調査および対応
- 重大インシデント時はエスカレーションプロセスに従う

---

## 11. セキュリティベストプラクティス

### 11.1 実装済みセキュリティ対策
- すべてのリソースに適切なタグ付与
- Key Vault公開アクセス無効化
- Storage Account HTTPS通信のみ許可（TLS 1.2以上）
- VM へのアクセスは Azure Bastion 経由のみ
- すべてのアウトバウンドトラフィックは Azure Firewall 経由
- User Assigned Managed Identity による認証
- NSG によるサブネットレベルトラフィック制御
- Private Endpoint による閉域接続
- Log Analytics Workspace は Private Link 経由のみアクセス
- NSG Flow Logs によるネットワークトラフィック可視化
- 全リソースの診断ログ保存

---

## 12. トラブルシューティング

### 12.1 デプロイ失敗時
1. Azure CLI バージョン確認
2. サブスクリプション権限確認
3. デプロイログ確認
4. リソース名の競合確認（Storage Account、Key Vault等）

### 12.2 リソース名競合
一部のリソース（Storage Account、Key Vault）はグローバルに一意である必要があります。ProjectNameパラメータを変更して再デプロイしてください。

---

## 13. 変更履歴

| バージョン | 日付 | 変更内容 | 変更者 |
|-----------|------|---------|--------|
| 1.0 | 2025-11-18 | 初版作成 | akkoike@microsoft.com |

---

## 14. 承認

| 役割 | 氏名 | 署名 | 日付 |
|------|------|------|------|
| 作成者 | | | |
| レビュー者 | | | |
| 承認者 | | | |

---

## 15. 参考資料

- [Azure アーキテクチャのベストプラクティス](https://docs.microsoft.com/ja-jp/azure/architecture/best-practices/)
- [Azure リソース命名規則](https://docs.microsoft.com/ja-jp/azure/architecture/best-practices/naming-conventions)
- [Azure タグ付けポリシー](https://docs.microsoft.com/ja-jp/azure/azure-resource-manager/management/tag-resources)
- [Microsoft Cloud Security Benchmark](https://docs.microsoft.com/ja-jp/security/benchmark/azure/)
- [Azure Bicep ドキュメント](https://docs.microsoft.com/ja-jp/azure/azure-resource-manager/bicep/)

---

**文書管理番号**: AZS-SPEC-001  
**機密区分**: 社外秘  
**配布先**: プロジェクトメンバー

---

*本文書に関するお問い合わせは akkoike@microsoft.com までご連絡ください。*
