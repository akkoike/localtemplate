---
applyTo: "/Users/akkoike/Desktop/TEST/bicep/BICEP/VibeCording/**"
---

# 役割
- ネットワーク要件に基づき、Bicep テンプレートを使用して Azure 環境のネットワーク構成を標準化します。

# ネットワーク構成
- Azure Virtual Network を４つ作成します。
  - Azure Virtual Network は以下の条件を満たしてください
    - Hub-VNet
      - vNETのアドレス空間:10.0.0.0/16
        - サブネットのアドレス空間:
          - GatewaySubnet:10.0.0.0/24
          - AzureFirewallSubnet:10.0.1.0/26
          - AzureBastionSubnet:10.0.2.0/26
    - workspace-VNet
      - vNETのアドレス空間:10.1.0.0/16
        - サブネットのアドレス空間:
          - private-endpoint-subnet:10.1.0.0/24
    - Spoke-VNet-1
      - vNETのアドレス空間:192.168.0.0/16
        - サブネットのアドレス空間:
          - AppSubnet:192.168.0.0/24
          - DBSubnet:192.168.1.0/24
    - Spoke-VNet-2
      - vNETのアドレス空間:172.16.0.0/16
        - サブネットのアドレス空間:
          - VMSubnet:172.16.0.0/24
- HubとSpoke間で VNet Peering を構成します。
  - Hub-vNET と 各 Spoke-vNET との Peering を構成します。
- Hub-VNet には Azure Firewall をデプロイします。
  - Azure Firewall は AzureFirewallSubnet にデプロイします。
  - Azure Firewall のパブリックIPアドレスは静的に割り当てます。
  - Azure Firewall のアウトバウンド通信には、以下のルールを設定します。
    - 送信元: 各Spoke-VNet のアドレス空間
    - 宛先: *.azure.com (Azure サービス全般)
    - プトコル: TCP
    - ポート: 443と80
    - アクション: Allow
- Hub-VNet には Azure Bastion をデプロイします。
  - Azure Bastion は AzureBastionSubnet にデプロイします。
  - Azure Bastion のパブリックIPアドレスは静的に割り当てます。
  - Azure Bastion を使用して、各 Spoke-VNet 内の Virtual Machine への RDP および SSH アクセスを可能にします。
# 閉域接続要件
- Azure Storage Account との接続は、workspace-VNet の private-endpoint-subnet からアドレス空間を利用して Private Endpoint 経由で接続できるように構成します。
- Azure Log Analytics Workspace との接続は、workspace-VNet の private-endpoint-subnet からアドレス空間を利用して Azure Monitor Private Link 経由で接続できるように構成します。
# ルーティング要件
- 各 Spoke-VNet からのアウトバウンド通信は、Hub-VNet にデプロイした Azure Firewall 経由でデフォルトルートするようにRouteTableを設定します。