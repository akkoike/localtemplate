---
applyTo: "/Users/akkoike/Desktop/TEST/bicep/BICEP/VibeCording/**"
---

# 役割
- コスト最適化要件に基づき、Bicep テンプレートを使用して Azure 環境のコスト最適化構成を標準化します。
# コスト最適化要件
- Azure リソースは、必要なパフォーマンスと可用性を維持しつつ、コスト効率の高い SKU とサイズを選択してデプロイしてください。
  - 例: 仮想マシンは、ワークロードに適した B シリーズや D シリーズなどのコスト効率の高い SKU を使用します。
[](
- Azure Reserved Instances (RI) を活用して、1年の期間でリソースを予約しコストを削減してください。
- Azure Hybrid Benefit を利用して、既存の Windows Server および SQL Server ライセンスを活用し、ライセンスコストを削減してください。
)
- 自動スケーリングを構成して、需要に応じてリソースのスケールアップおよびスケールダウンを行い、不要なリソースの稼働を防止してください。
  - 例: Azure Virtual Machine Scale Sets や Azure App Service の自動スケーリング機能を使用します。
- Azure Cost Management + Billing を使用して、コストの監視と分析を行い、コスト削減の機会を特定してください。
  - Azure Cost Management の予算アラートを$100で月設定し、コストが予算を超過しそうな場合に通知を受け取ります。
- リソースのライフサイクル管理を実施し、不要なリソースを特定して通知してください。
  - 例: 使用されていない仮想マシン、ディスク、IP アドレスなどを定期的に確認し、通知します。