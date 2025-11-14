---
applyTo: "C:\Users\akkoike\Desktop\TEST\bicep\BICEP\VibeCording\*"
---

# 役割
- ログ収集要件に基づき、Bicep テンプレートを使用して Azure 環境のログ収集構成を標準化します。
# ログ収集要件
- Azure Log Analytics Workspace は、workspace-VNet の private-endpoint-subnet からアドレス空間を利用して Azure Monitor Private Link Scope 経由でプライベート接続できるように構成します。
- Azure log Analytics Workspace に Azure Monitor Private Link Scope が設定された後、Azure Log Analytics Workspace へのpublic endpointは無効に設定します。
- デプロイされた Azure リソースには、全て診断設定を構成し、ログとメトリックを Azure Log Analytics Workspace と Azure Blob Storage に送信できるように設定します。
- Azure Log Analytics Workspace のログ保存期間は90日に設定します。