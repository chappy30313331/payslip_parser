# payslip_parser

## About

給与明細のPDFファイルをパースするスクリプトです。pdfディレクトリ配下のPDFをpopplerのpdftohtmlでhtmlに変換し、パース結果をresults.jsonに保存します。

## Usage

```sh
$ brew install poppler
$ bundle install
```

```sh
$ mv /path/to/*.pdf pdf/
```

```sh
$ bundle exec ruby convert_pdf_to_html.rb
$ bundle exec ruby parse.rb

$ cat results.json

```
