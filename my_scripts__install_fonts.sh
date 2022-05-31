#!/bin/bash
set -x

# Noto Sans/Serif JP フォントのインストール

# Google Fonts から日本語フォントのみダウンロードして手動でインストールする
# フォント名は、以前の Noto Sans/Serif CJK JP から "CJK" なしの Noto Sans/Serif JP になった

wget -q -O NotoSansJP.zip https://fonts.google.com/download?family=Noto%20Sans%20JP
wget -q -O NotoSerifJP.zip https://fonts.google.com/download?family=Noto%20Serif%20JP
unzip NotoSansJP.zip NotoSans*.otf
unzip NotoSerifJP.zip NotoSerif*.otf

mkdir -p /usr/share/fonts/notojp
mv NotoSerifJP-Light.otf /usr/share/fonts/notojp/
mv NotoSerifJP-Regular.otf /usr/share/fonts/notojp/
mv NotoSerifJP-Bold.otf /usr/share/fonts/notojp/
mv NotoSansJP-Regular.otf /usr/share/fonts/notojp/
mv NotoSansJP-Bold.otf /usr/share/fonts/notojp/
mv NotoSansJP-Black.otf /usr/share/fonts/notojp/
mv NotoSansJP-Medium.otf /usr/share/fonts/notojp/

rm -rf Noto*

# Coding font として、UDEV Gothic LG (BIZ UD Gothic + JetBrains Mono) https://github.com/yuru7/udev-gothic/ をインストール
# 半角：全角 1:2、リガチャ有効バージョンを使用

wget -q https://github.com/yuru7/udev-gothic/releases/download/v1.0.0/UDEVGothic_v1.0.0.zip
unzip UDEVGothic_v1.0.0.zip

mkdir -p /usr/share/fonts/UDEVGothic
mv UDEVGothic_v1.0.0/UDEVGothicLG-Regular.ttf /usr/share/fonts/UDEVGothic/
mv UDEVGothic_v1.0.0/UDEVGothicLG-Italic.ttf /usr/share/fonts/UDEVGothic/
mv UDEVGothic_v1.0.0/UDEVGothicLG-Bold.ttf /usr/share/fonts/UDEVGothic/
mv UDEVGothic_v1.0.0/UDEVGothicLG-BoldItalic.ttf /usr/share/fonts/UDEVGothic/

rm -rf UDEVGothic*

# 標準フォント sans/serif として手動で入れた Noto fonts を認識できるようにする
# Noto Sans/Serif CJK JP を Noto Sans/Serif JP の別名として登録しておく（過去のコードの文字化け回避）
# 設定しておけば、最低限グラフの文字化けはなくなる

cp /my_scripts/fonts.conf /etc/fonts/local.conf

chmod 644 /usr/share/fonts/notojp/*
chmod 644 /usr/share/fonts/UDEVGothic/*
fc-cache -fv

# Code-server で UDEV Gothic LG を使えるようにする
# Refs: https://qiita.com/BonyChops/items/2f78ec57d55db63cb7e3
#       https://github.com/coder/code-server/issues/1374

ln -s /usr/share/fonts/UDEVGothic/*.ttf /usr/lib/code-server/src/browser/media/

patch -u /usr/lib/code-server/lib/vscode/out/vs/code/browser/workbench/workbench.html << EOF
@@ -32,6 +32,33 @@
 		<link rel="manifest" href="{{VS_BASE}}/manifest.json" crossorigin="use-credentials" />
 		<link data-name="vs/workbench/workbench.web.main" rel="stylesheet" href="{{VS_BASE}}/static/out/vs/workbench/workbench.web.main.css">
 
+		<!-- Custom fonts -->
+		<style>
+			@font-face {
+				font-family: "UDEV Gothic LG";
+				src: url("{{BASE}}/_static/src/browser/media/UDEVGothicLG-Regular.ttf") format("truetype");
+				font-weight: 400;
+				font-style: normal;
+			}
+			@font-face {
+				font-family: "UDEV Gothic LG";
+				src: url("{{BASE}}/_static/src/browser/media/UDEVGothicLG-Itaclic.ttf") format("truetype");
+				font-weight: 400;
+				font-style: italic;
+			}
+			@font-face {
+				font-family: "UDEV Gothic LG";
+				src: url("{{BASE}}/_static/src/browser/media/UDEVGothicLG-Bold.ttf") format("truetype");
+				font-weight: 700;
+				font-style: normal;
+			}
+			@font-face {
+				font-family: "UDEV Gothic LG";
+				src: url("{{BASE}}/_static/src/browser/media/UDEVGothicLG-BoldItaclic.ttf") format("truetype");
+				font-weight: 700;
+				font-style: italic;
+			}
+		</style>
 	</head>
 
 	<body aria-label="">
EOF
