# AI Foundry基本設計書生成スクリプト
# PowerShellスクリプトでWord文書を作成

# Word COMオブジェクトの作成
$word = New-Object -ComObject Word.Application
$word.Visible = $true
$doc = $word.Documents.Add()
$selection = $word.Selection

# 文書のタイトル
$selection.Font.Size = 18
$selection.Font.Bold = $true
$selection.TypeText("Azure AI Foundry基本設計書")
$selection.TypeParagraph()
$selection.TypeParagraph()

# 作成日時
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.TypeText("作成日: $(Get-Date -Format 'yyyy年MM月dd日')")
$selection.TypeParagraph()
$selection.TypeText("バージョン: 1.0")
$selection.TypeParagraph()
$selection.TypeParagraph()

# 目次
$selection.Font.Size = 14
$selection.Font.Bold = $true
$selection.TypeText("目次")
$selection.TypeParagraph()
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.TypeText("1. 概要")
$selection.TypeParagraph()
$selection.TypeText("2. システム構成図")
$selection.TypeParagraph()
$selection.TypeText("3. リソース構成")
$selection.TypeParagraph()
$selection.TypeText("4. セキュリティ設計")
$selection.TypeParagraph()
$selection.TypeText("5. 設定詳細")
$selection.TypeParagraph()
$selection.TypeParagraph()

# 1. 概要
$selection.Font.Size = 14
$selection.Font.Bold = $true
$selection.TypeText("1. 概要")
$selection.TypeParagraph()
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.TypeText("本システムは、Azure AI FoundryとAzure OpenAIを活用したRAG（Retrieval-Augmented Generation）デモ環境です。")
$selection.TypeParagraph()
$selection.TypeText("以下の主要機能を提供します：")
$selection.TypeParagraph()
$selection.TypeText("• 文書の自動インデックス化とベクトル検索")
$selection.TypeParagraph()
$selection.TypeText("• Azure OpenAIを使用した自然言語処理")
$selection.TypeParagraph()
$selection.TypeText("• セキュアなデータ管理とアクセス制御")
$selection.TypeParagraph()
$selection.TypeParagraph()

# 2. システム構成図
$selection.Font.Size = 14
$selection.Font.Bold = $true
$selection.TypeText("2. システム構成図")
$selection.TypeParagraph()
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.TypeText("┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐")
$selection.TypeParagraph()
$selection.TypeText("│  Azure Storage  │────│ Azure AI Search │────│ Azure OpenAI    │")
$selection.TypeParagraph()
$selection.TypeText("│  (Blob)         │    │                 │    │ Service         │")
$selection.TypeParagraph()
$selection.TypeText("└─────────────────┘    └─────────────────┘    └─────────────────┘")
$selection.TypeParagraph()
$selection.TypeText("         │                       │                       │")
$selection.TypeParagraph()
$selection.TypeText("         └───────────────────────┼───────────────────────┘")
$selection.TypeParagraph()
$selection.TypeText("                                 │")
$selection.TypeParagraph()
$selection.TypeText("                    ┌─────────────────┐")
$selection.TypeParagraph()
$selection.TypeText("                    │ AI Foundry      │")
$selection.TypeParagraph()
$selection.TypeText("                    │ Account         │")
$selection.TypeParagraph()
$selection.TypeText("                    └─────────────────┘")
$selection.TypeParagraph()
$selection.TypeParagraph()

# 3. リソース構成
$selection.Font.Size = 14
$selection.Font.Bold = $true
$selection.TypeText("3. リソース構成")
$selection.TypeParagraph()
$selection.TypeParagraph()

# 3.1 Azure Storage Account
$selection.Font.Size = 13
$selection.Font.Bold = $true
$selection.TypeText("3.1 Azure Storage Account")
$selection.TypeParagraph()
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.TypeText("• リソース名: stracc1010001")
$selection.TypeParagraph()
$selection.TypeText("• SKU: Standard_LRS")
$selection.TypeParagraph()
$selection.TypeText("• 種類: StorageV2")
$selection.TypeParagraph()
$selection.TypeText("• Blobコンテナー名: content")
$selection.TypeParagraph()
$selection.TypeText("• パブリックアクセス: 無効")
$selection.TypeParagraph()
$selection.TypeText("• 最小TLSバージョン: 1.2")
$selection.TypeParagraph()
$selection.TypeParagraph()

# 3.2 Azure AI Search
$selection.Font.Size = 13
$selection.Font.Bold = $true
$selection.TypeText("3.2 Azure AI Search")
$selection.TypeParagraph()
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.TypeText("• リソース名: {prefix}search")
$selection.TypeParagraph()
$selection.TypeText("• SKU: Standard")
$selection.TypeParagraph()
$selection.TypeText("• パーティション数: 1")
$selection.TypeParagraph()
$selection.TypeText("• レプリカ数: 1")
$selection.TypeParagraph()
$selection.TypeText("• マネージドID: システム割り当て")
$selection.TypeParagraph()
$selection.TypeParagraph()

# 3.3 Azure OpenAI
$selection.Font.Size = 13
$selection.Font.Bold = $true
$selection.TypeText("3.3 Azure OpenAI Service")
$selection.TypeParagraph()
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.TypeText("• リソース名: {prefix}openai")
$selection.TypeParagraph()
$selection.TypeText("• SKU: S0")
$selection.TypeParagraph()
$selection.TypeText("• カスタムサブドメイン: {prefix}openai")
$selection.TypeParagraph()
$selection.TypeText("• パブリックネットワークアクセス: 無効")
$selection.TypeParagraph()
$selection.TypeText("• ローカル認証: 無効（Azure AD認証のみ）")
$selection.TypeParagraph()
$selection.TypeText("• マネージドID: システム割り当て")
$selection.TypeParagraph()
$selection.TypeParagraph()

# 3.4 AI Foundry Account
$selection.Font.Size = 13
$selection.Font.Bold = $true
$selection.TypeText("3.4 Azure AI Foundry Account")
$selection.TypeParagraph()
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.TypeText("• リソース名: {prefix}aiservices")
$selection.TypeParagraph()
$selection.TypeText("• 種類: AIServices")
$selection.TypeParagraph()
$selection.TypeText("• SKU: S0")
$selection.TypeParagraph()
$selection.TypeText("• カスタムサブドメイン: {prefix}akkoikeai")
$selection.TypeParagraph()
$selection.TypeText("• パブリックネットワークアクセス: 無効")
$selection.TypeParagraph()
$selection.TypeText("• マネージドID: システム割り当て")
$selection.TypeParagraph()
$selection.TypeParagraph()

# 3.5 AI Project
$selection.Font.Size = 13
$selection.Font.Bold = $true
$selection.TypeText("3.5 AI Foundry Project")
$selection.TypeParagraph()
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.TypeText("• プロジェクト名: rag-project")
$selection.TypeParagraph()
$selection.TypeText("• 表示名: RAG Project")
$selection.TypeParagraph()
$selection.TypeText("• 説明: Sample RAG environment project")
$selection.TypeParagraph()
$selection.TypeText("• マネージドID: システム割り当て")
$selection.TypeParagraph()
$selection.TypeParagraph()

# 4. セキュリティ設計
$selection.Font.Size = 14
$selection.Font.Bold = $true
$selection.TypeText("4. セキュリティ設計")
$selection.TypeParagraph()
$selection.TypeParagraph()

$selection.Font.Size = 13
$selection.Font.Bold = $true
$selection.TypeText("4.1 認証・認可")
$selection.TypeParagraph()
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.TypeText("• Azure AD（Entra ID）認証の利用")
$selection.TypeParagraph()
$selection.TypeText("• マネージドIDによるサービス間認証")
$selection.TypeParagraph()
$selection.TypeText("• APIキー認証の無効化")
$selection.TypeParagraph()
$selection.TypeParagraph()

$selection.Font.Size = 13
$selection.Font.Bold = $true
$selection.TypeText("4.2 ネットワークセキュリティ")
$selection.TypeParagraph()
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.TypeText("• パブリックネットワークアクセスの無効化")
$selection.TypeParagraph()
$selection.TypeText("• ネットワークACLによるアクセス制御")
$selection.TypeParagraph()
$selection.TypeText("• TLS 1.2以上の強制")
$selection.TypeParagraph()
$selection.TypeParagraph()

$selection.Font.Size = 13
$selection.Font.Bold = $true
$selection.TypeText("4.3 データセキュリティ")
$selection.TypeParagraph()
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.TypeText("• Blobの匿名アクセス禁止")
$selection.TypeParagraph()
$selection.TypeText("• コンテナーのパブリックアクセス無効")
$selection.TypeParagraph()
$selection.TypeText("• データの暗号化（Azure標準）")
$selection.TypeParagraph()
$selection.TypeParagraph()

# 5. 設定詳細
$selection.Font.Size = 14
$selection.Font.Bold = $true
$selection.TypeText("5. 設定詳細")
$selection.TypeParagraph()
$selection.TypeParagraph()

$selection.Font.Size = 13
$selection.Font.Bold = $true
$selection.TypeText("5.1 パラメーター設定")
$selection.TypeParagraph()
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.TypeText("• デフォルトリージョン: Japan East")
$selection.TypeParagraph()
$selection.TypeText("• リソース名プレフィックス: my-rag-demo2")
$selection.TypeParagraph()
$selection.TypeText("• Search SKU: standard（ベクトル検索対応）")
$selection.TypeParagraph()
$selection.TypeText("• OpenAI SKU: S0（標準プラン）")
$selection.TypeParagraph()
$selection.TypeText("• Storage SKU: Standard_LRS（ローカル冗長）")
$selection.TypeParagraph()
$selection.TypeParagraph()

$selection.Font.Size = 13
$selection.Font.Bold = $true
$selection.TypeText("5.2 デプロイメント情報")
$selection.TypeParagraph()
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.TypeText("• 使用APIバージョン:")
$selection.TypeParagraph()
$selection.TypeText("  - Storage: 2022-05-01")
$selection.TypeParagraph()
$selection.TypeText("  - Search: 2023-11-01")
$selection.TypeParagraph()
$selection.TypeText("  - Cognitive Services: 2024-10-01")
$selection.TypeParagraph()
$selection.TypeText("  - AI Foundry: 2023-05-01")
$selection.TypeParagraph()
$selection.TypeText("  - AI Project: 2025-04-01-preview")
$selection.TypeParagraph()
$selection.TypeParagraph()

# 文書の保存
$docPath = "C:\Users\akkoike\Desktop\TEST\bicep\BICEP\GHCA\AI_Foundry_基本設計書.docx"
$doc.SaveAs($docPath)

Write-Host "Word文書が作成されました: $docPath" -ForegroundColor Green