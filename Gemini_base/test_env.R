# ==========================================
# R 解析環境 動作確認スクリプト
# ==========================================

# 1. R バージョンの確認 (4.5.1 であること)
message("--- R Version Check ---")
print(R.version.string)

# 2. プリインストール済みパッケージのロード
message("\n--- Loading Packages ---")
library(tidyverse)
library(httpgd)

# 3. httpgd による描画テスト
# 実行すると VS Code の右側に Plot パネルが開くはずです
message("\n--- Testing httpgd ---")
if (interactive()) {
  hgd()  # httpgd サーバーの起動
  
  # 重めの描画も ARM バイナリの威力でサクサク動くか確認
  ggplot(diamonds, aes(x = carat, y = price, color = cut)) +
    geom_point(alpha = 0.5) +
    theme_minimal() +
    labs(title = "httpgd Rendering Test", subtitle = "Diamonds dataset")
}

# 4. pak によるシステム依存解決テスト
# すでに tidyverse が入っているので、高速に「空振り」することを確認
message("\n--- Testing pak (System Dependency Check) ---")
pak::pkg_status("tidyverse")

# 5. Air (posit.air-vscode) の整形テスト
# わざと汚いコードを書いて、保存(Ctrl+S)時に整形されるか試してください
# (例: a<-1   +2    )
test_val <- 1+2
