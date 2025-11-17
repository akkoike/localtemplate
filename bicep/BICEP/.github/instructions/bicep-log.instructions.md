---
applyTo: "/Users/akkoike/Desktop/TEST/bicep/BICEP/VibeCording/**"
---

# 役割
- ログ収集要件に基づき、Bicep テンプレートを使用して Azure 環境のログ収集構成を標準化します。
# ログ収集要件
- Azure Log Analytics Workspace は、workspace-VNet の private-endpoint-subnet からアドレス空間を利用して Azure Monitor Private Link Scope 経由でプライベート接続できるように構成します。
- Azure log Analytics Workspace に Azure Monitor Private Link Scope が設定された後、Azure Log Analytics Workspace へのpublic endpointは無効に設定します。
- デプロイされた Azure リソースには、全て診断設定を構成し、ログとメトリックを Azure Log Analytics Workspace と Azure Blob Storage に送信できるように設定します。
- Azure Log Analytics Workspace のログ保存期間は90日に設定します。
# アラート通知要件
- Azure Monitor アラートルールを作成し、以下の条件を満たすように構成してください。
  - 通知先: akkoike@microsoft.com
  - アラート条件:
  - CPU 使用率が80%を超えた状態が5分以上継続した場合にアラートを発生させます。
  - メモリ使用率が75%を超えた状態が5分以上継続した場合にアラートを発生させます。
  - ディスク使用率が85%を超えた状態が5分以上継続した場合にアラートを発生させます。
  - ネットワークの受信トラフィックが1分間に300MBを超えた場合にアラートを発生させます。
  - ネットワークの送信トラフィックが1分間に300MBを超えた場合にアラートを発生させます。
  - Azure Backup ジョブが失敗した場合にアラートを発生させます。