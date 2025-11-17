---
applyTo: "/Users/akkoike/Desktop/TEST/bicep/BICEP/VibeCording/**"
---

# 役割
- セキュリティ要件に基づき、Bicep テンプレートを使用して Azure 環境のセキュリティ構成を標準化します。
# コンプライアンス要件
- コンプライアンスは Microsoft Cloud Security Benchmark (MCSB) に準拠してください。
- Azure Policy を使用して、リソースの準拠状況を監視および強制してください。
  - 以下の組み込みポリシーを割り当てます。
    - "Enforce tag and its value on resources"
    - "Allowed locations"
      - 許可されるリージョンは "Japan East" と "Japan West" のみとします。
  - ポリシー違反が検出された場合、アラートを生成し、管理者に通知します。
  - ポリシー違反の修復には、Azure Policy の自動修復機能を使用します。
  - 監査レポートを定期的に生成し、コンプライアンス状況を確認します。
# ID管理要件
- Azure にデプロイした各リソースは、Role-Based Access Control (RBAC) を使用して、最小権限の原則に基づきアクセス制御を構成してください。
  - 所有者権限は MOD Administrator に付与します。
- User Assigned Managed Identity を使用して、Azure リソース間の認証を構成してください。
  - User Assigned Managed Identity には、必要な権限のみを付与し、分類スコープを適切に設定します。
<!--
- Multi-Factor Authentication (MFA) を有効にして、Azure ポータルおよびリソースへのアクセスを保護してください。
-->
# シークレット管理要件
- keyvault モジュールを作成し、以下の要件を満たすように構成してください。
  - Key Vault は、Spoke-vNET の VMSubnet からアクセスできるように構成します。
  - Key Vault のアクセス ポリシーには、以下のユーザーとサービス プリンシパルを追加します。
    - MOD Administrator: 全ての権限を付与
  - Key Vault に保存するシークレットには、AzureVMからログインするための管理者ユーザー名(azureuser01)とパスワード(p@ssw0rd1234!)を含めます。
# ネットワークセキュリティ要件
- 各 Azure Virtual Network 内のサブネットには、Azure Network Security Group (NSG) を適用し、最小権限の原則に基づいたトラフィックのみ許可するルールを設定してください。
  - VMSubnet には、以下のインバウンドルールを設定してください。
    - ポート 22 (SSH): Azure Bastion 経由でのアクセスを許可
    - ポート 3389 (RDP): Azure Bastion 経由でのアクセスを許可 (Windows VM 用)
- Network Watcher を有効にして、ネットワークトラフィックの監視とログ記録を行うように構成してください。
  - Network Watcher は、Japan East リージョンにデプロイしてください。
  - NSG Flow Logs を有効にし、Log Analytics Workspace にログを送信するように設定してください。
- 各Spoke-VNet間での通信は許可せず、Hub-VNetに配置されているAzure Firewall をを経由するように構成してください。

# データ保護要件
- 通信の暗号化はTLS 1.2以上を使用してください。
- データの保存時の暗号化は、Azure Storage Service Encryption (SSE) を使用してください。

# 可用性および災害復旧要件
- 各 Azure リソースは、リージョン冗長構成をサポートする場合、リージョン冗長構成でデプロイしてください。
- 可用性ゾーンをサポートするリソースは、可用性ゾーンを使用してデプロイしてください。
- ゾーン冗長サービスをサポートするリソースは、ゾーン冗長サービスを使用してデプロイしてください。
