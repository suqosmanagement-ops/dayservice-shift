# デイサービス シフト管理 v0.8（オンライン化ベース）

v0.7.5の操作感を維持しつつ、Supabase Auth + Database + Realtime に対応した版です。

## 1. Supabase
1. Supabaseで新規Projectを作成。
2. SQL Editorで `supabase.sql` を実行。
3. Authentication > Users で管理者とスタッフのユーザーを作成（メール + パスワード）。
4. 各ユーザーのUUIDを確認し、SQL Editorで `profiles` に登録します。

例：
```sql
insert into public.profiles(user_id, display_name, role, staff_id)
values
('管理者UUID','管理者','manager',null),
('スタッフUUID','山田 太郎','staff',0);
```

`staff_id` はアプリ内スタッフ番号で、初期データは 0〜4 です。

## 2. index.html にSupabase接続情報を設定
Supabase > Project Settings > API から以下を確認します。
- Project URL
- anon / publishable key

`index.html` 冒頭の以下を置換します。
```js
const SUPABASE_URL = '__SUPABASE_URL__';
const SUPABASE_ANON_KEY = '__SUPABASE_ANON_KEY__';
```

※ service_role key は絶対にブラウザ側へ入れないでください。

## 3. 初期データ
最初の管理者ログイン後は、ブラウザに残っている初期/テストデータを使えます。何か1つ変更して保存すると `app_state` に同期されます。

## 4. GitHub
このフォルダ内の `index.html` をGitHubリポジトリへアップロードします。`supabase.sql` と README は公開リポジトリに置いても秘密鍵を含まない限り問題ありませんが、実運用ではPrivate repository推奨です。

## 5. Vercel
1. Add New > Project
2. GitHubのリポジトリをImport
3. Framework Preset: Other
4. Build Command: 空欄
5. Output Directory: 空欄
6. Deploy

発行された `*.vercel.app` URLをスマホで開いてテストします。

## 重要
- v0.8は「今までの試作をオンライン共有できる状態へ移す」ため、既存データ構造を1つのJSONとして共有する移行版です。
- ログイン権限で画面は分けていますが、スタッフも共有JSONの更新権限を持つ暫定方式です。スタッフ5名でのテストには使えますが、本運用前に requests / shifts / daily_operations をテーブル分割し、スタッフが自分の希望だけ更新できるRLSへ強化することを推奨します。
- 利用者の氏名・住所・介護情報などはこの版へ入力しないでください。
