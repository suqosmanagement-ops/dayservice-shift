-- デイサービス シフト管理 v0.8
-- Supabase > SQL Editor で実行してください。

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  role text not null check (role in ('manager','staff')),
  staff_id integer
);

create table if not exists public.app_state (
  id integer primary key default 1 check (id = 1),
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.app_state enable row level security;

-- ログイン済みユーザーは自分のプロフィールだけ閲覧可
create policy "profile self read" on public.profiles
for select to authenticated using (auth.uid() = user_id);

-- ログイン済みユーザーは共有シフトデータを閲覧可
create policy "state authenticated read" on public.app_state
for select to authenticated using (true);

-- 管理者は共有データを更新可
create policy "state manager write" on public.app_state
for all to authenticated
using (exists(select 1 from public.profiles p where p.user_id=auth.uid() and p.role='manager'))
with check (exists(select 1 from public.profiles p where p.user_id=auth.uid() and p.role='manager'));

-- スタッフも希望入力を保存するため共有データ更新可。
-- v0.8では単一JSONで既存機能を維持するための暫定構成です。
create policy "state staff update" on public.app_state
for update to authenticated
using (exists(select 1 from public.profiles p where p.user_id=auth.uid() and p.role='staff'))
with check (exists(select 1 from public.profiles p where p.user_id=auth.uid() and p.role='staff'));

insert into public.app_state(id,data)
values (1,'{}'::jsonb)
on conflict (id) do nothing;

alter publication supabase_realtime add table public.app_state;
