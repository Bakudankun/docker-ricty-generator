# Ricty Generator

自動で[Rictyフォント](https://github.com/yascentur/Ricty)を生成してくれるすごいやつだよ


## Usage

```
docker run [--rm] -v /path/to/outdir:/out bakudankun/ricty-generator [OPTIONS]
docker run [--rm] bakudankun/ricty-generator --tarball [OPTIONS] > Ricty.tar.gz
docker run [--rm] bakudankun/ricty-generator --zipball [OPTIONS] > Ricty.zip
docker run [--rm] bakudankun/ricty-generator [ -h | --help ]
```


## Options

```
--discord-opts=opts      ricty_discord_converter.pe に渡すオプション（RictyのREADMEを参照）
--generator-opts=opts    ricty_generator.sh に渡すオプション（RictyのREADMEを参照）
-o, --oblique            斜体も生成する
--no-os2                 os2version_reviser.sh を利用しない
--tarball                生成したフォントの .tar.gz ファイルを標準出力に吐く
-h, --help               使い方を表示
--zipball                生成したフォントの .zip ファイルを標準出力に吐く
```

