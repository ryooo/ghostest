# 概要
ghostestは**ローカルPC上で動作するテストコード自動生成LLMエージェントツール**です。

# 使い方
#### インストール
```sh
gem install ghostest
```

#### config/ghostest.ymlを作成
```yaml
language: ruby

watch_files:
  - app/models/user.rb # テスト対象ファイル

agents:
  Mr_test_designer:
    role: test_designer
    color: light_yellow
    system_prompt: |- # システムプロンプトをカスタマイズ可能
      <%= I18n.t("ghostest.agents.test_designer.ruby.default_system_prompt").gsub("\n", "\n      ") %>
      - Ruby version assumes 3 series.

  Mr_test_programmer:
    role: test_programmer
    color: cyan
    system_prompt: |-
      <%= I18n.t("ghostest.agents.test_programmer.ruby.default_system_prompt").gsub("\n", "\n      ") %>
      - Ruby version assumes 3 series.

  Mr_reviewer:
    role: reviewer
    color: green
    system_prompt: |-
      <%= I18n.t("ghostest.agents.reviewer.ruby.default_system_prompt").gsub("\n", "\n      ") %>
```
※ デフォルトのシステムプロンプトは以下のようになっています。
https://github.com/ryooo/ghostest/blob/4b33f6f26bd5f7513b9fc7085c61964876339c4f/config/locales/agents/test_programmer/en.yml#L19-L56

#### Azureのトークンを設定
```sh
xport AZURE_OPENAI_API_KEY=xxxxxx
```

#### 起動
```sh
bundle exec ghostest --use-azure
```
※ デフォルトはOpenAIになっていますが動作確認は取れていません