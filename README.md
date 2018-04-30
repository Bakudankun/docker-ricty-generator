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
--tarball                生成したフォントの .tar.gz ファイルを標準出力に吐く
--zipball                生成したフォントの .zip ファイルを標準出力に吐く
--generator-opts=opts    ricty_generator.sh に渡すオプション（Rictyのサイトを参照）
--no-os2                 Windowsのためのフォント幅修正を行わない
-h, --help               使い方を表示
```

