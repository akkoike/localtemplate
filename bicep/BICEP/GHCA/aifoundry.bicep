// パラメーター定義
param location string = 'japaneast'  // リソースを配置するリージョン
param resourceNamePrefix string = 'my-rag-demo2'  // リソース名プレフィックス
param searchSku string = 'standard'  // SearchサービスのSKU (standard/basic 等)
param openAiSku string = 'S0'        // OpenAIサービスのSKU (S0=標準)
param storageSku string = 'Standard_LRS'  // StorageアカウントのSKU
param storageContainerName string = 'content'  // Blobコンテナー名
param storageAccountName string = 'stracc1010001'  // Storageアカウント名

// Storageアカウントのデプロイ
resource storageAcct 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false  // Blobの匿名アクセス禁止
    minimumTlsVersion: 'TLS1_2'
  }
}

// Blobコンテナー作成
resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: '${storageAcct.name}/default/${storageContainerName}'
  properties: {
    publicAccess: 'None'  // コンテナーのパブリックアクセス無し
  }
}

// Azure AI Searchサービスのデプロイ
resource searchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: '${resourceNamePrefix}search'
  location: location
  sku: {
    name: searchSku  // 例:'standard' SKU (Basic以上でVector機能利用可能)
  }
  // Managed Identity を有効化 (Storage 等他リソースアクセス用に利用可能)
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hostingMode: 'default'
    partitionCount: 1
    replicaCount: 1
  }
  // SearchサービスはStandard SKU以上でManaged Identity利用可 (必要に応じて identity: {} を追加)
}

// Azure OpenAIサービス (Cognitive Servicesアカウント, kind: OpenAI) のデプロイ
resource openAiAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: '${resourceNamePrefix}openai'
  location: location
  kind: 'OpenAI'
  sku: {
    name: openAiSku  // 通常 'S0'
  }
  identity: {
    type: 'SystemAssigned'  // システム割り当てのマネージドIDを使用
  }
  properties: {
    customSubDomainName: '${resourceNamePrefix}openai'  // OpenAIのカスタムサブドメイン[4](https://learn.microsoft.com/en-us/answers/questions/2238073/azure-openai-service-doesnt-show-up-for-azure-ai-s)
    publicNetworkAccess: 'Disabled'  // パブリックネットワーク経由を禁止
    networkAcls: {
      defaultAction: 'Deny'
    }
    disableLocalAuth: true  // APIキー認証を無効化しAzure AD認証のみ許可
  }
}

// (オプション) Azure AI Foundry統合アカウントのデプロイ
resource aiFoundryAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: '${resourceNamePrefix}aiservices'
  location: location
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
    }
    customSubDomainName: '${resourceNamePrefix}akkoikeai'
    disableLocalAuth: true
  }
}


// (オプション) Foundryプロジェクトの作成
resource aiProject 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' = {
  name: 'rag-project'
  location: location
  parent: aiFoundryAccount
  identity: {
    type: 'SystemAssigned'
  } 
  properties: {
    displayName: 'RAG Project'
    description: 'Sample RAG environment project'
  }
}
