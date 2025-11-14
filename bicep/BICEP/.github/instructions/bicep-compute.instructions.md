---
applyTo: "/Users/akkoike/Desktop/TEST/bicep/BICEP/VibeCording/**"
---

# 役割
- コンピューティングリソース要件に基づき、Bicep テンプレートを使用して Azure 環境のコンピューティングリソース構成を標準化します。
# コンピューティングリソース要件
- 各 Spoke-VNet 内に、以下の構成で Azure Virtual Machine をデプロイします。
  - VM サイズ: Standard_D4s_v3
  - インスタンス数: 2 台 (可用性ゾーンを使用してデプロイし、それぞれ異なるゾーンに配置します)
  - OS: Ubuntu 20.04 LTS
  - 管理者ユーザー名: keyvault のsecretに保存された値を使用します。
  - 管理者パスワード: keyvault のsecretに保存された値を使用します。
  - VM は、Spoke-VNet 内の VMSubnet にデプロイします。
  - VM にパブリック IP アドレスは割り当てません。
- 各 Virtual Machine に対して、Azure VM Extension を使用して以下のエージェントをインストールします。
  - Azure Monitor エージェント
- Log Analytics ワークスペースに接続して、監視データを収集します。
- VM のバックアップを構成します。
  - Azure Backup サービスを使用して、各 Virtual Machine のバックアップを有効にします。
  - バックアップポリシーは、毎日1回のバックアップを取得し、バックアップデータを30日間保持するように設定します。