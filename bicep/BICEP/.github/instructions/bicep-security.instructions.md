---
applyTo: "/Users/akkoike/Desktop/TEST/bicep/BICEP/VibeCording/**"
---

# 役割
- セキュリティ要件に基づき、Bicep テンプレートを使用して Azure 環境のセキュリティ構成を標準化します。
# コンプライアンス要件
- コンプライアンスは Microsoft Cloud Security Benchmark (MCSB) に準拠してください。
# ID管理要件
- Azure にデプロイした各リソースは、Role-Based Access Control (RBAC) を使用して、最小権限の原則に基づきアクセス制御を構成してください。
  - 所有者権限は akkoike(Akira Koike) に付与します。
- keyvault モジュールを作成し、以下の要件を満たすように構成してください。
  - Key Vault は、各環境ごとに作成します。(dev, stag, prod)
  - Key Vault のアクセス ポリシーには、以下のユーザーとサービス プリンシパルを追加します。
    - akkoike(Akira Koike): 全ての権限を付与
    - 各 Virtual Machine のマネージド ID: シークレットの取得権限を付与
  - Key Vault に保存するシークレットには、各 Virtual Machine の管理者ユーザー名(azureuser01)とパスワード(p@ssw0rd1234!)を含めます。
# ネットワークセキュリティ要件
- 各 Azure Virtual Network 内のサブネットには、適切な Azure Network Security Group (NSG) を適用し、必要なトラフィックのみを許可するルールを設定してください。
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
