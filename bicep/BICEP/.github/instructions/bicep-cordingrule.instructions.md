---
applyTo: "/Users/akkoike/Desktop/TEST/bicep/BICEP/VibeCording/**"
---

# Bicep テンプレートに関するコーディングルール
- シンボリック名はパスカルケース（例: myResourceGroup）を使用してください
- 変数名はアッパーキャメルケース（例: MyVariable）を使用してください
- 定数は全て大文字とアンダースコア（例: MY_CONSTANT）を使用してください
- モジュール名はモジュールの機能を明確に表す名前を使用してください（例: NetworkModule.bicep）
- @description の説明は使わないでください
- Azure Verified Modules は使用しないでください
- **依存性に注意し、必要に応じてdependsOn、parent、scope を使用してください**
- Output はmoduleの受け渡しにのみ使用し、デプロイ後の情報取得には使用しないでください