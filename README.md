# README

This README would normally document whatever steps are necessary to get the
application up and running.

社内システム(各メーカーから取得した商品の在庫情報を、出店しているECサイトに反映するためのシステム)を、
Railsの勉強も兼ねてリプレイスしようとした際に書いたプログラム

社内の商品のマスタDBに接続することが前提のため、cloneして動かすことは不可。
あくまでソースをお見せする用。

Things you may want to cover:

* Ruby version
Ruby 2.7.8
Rails 7.1.5.1

* System dependencies
Ubuntu 20.04
mysql2
apache2

* Configuration
DB接続先はconfig/database.ymlに記載

* Database creation
既存の社内DBへの接続を前提としているため、マイグレーション等は無し

* Database initialization
既存の社内DBへの接続を前提としているため、マイグレーション等は無し

* How to run the test suite
現状テストクラス無し

* Services (job queues, cache servers, search engines, etc.)
現状プログラムの実行はrails console上でMaker::Xx::StartService.new()で実行クラス呼び出し
展望としては、bundle exec rake コマンドでの実行できるようにする

* Deployment instructions

* ...
