-- anime.log: database setup for accounts & cross-device sync
--
-- Setting up accounts (one-time, for whoever runs the site):
--   1. Create a free project at supabase.com.
--   2. Paste this whole file into SQL Editor → New query → Run. Safe to run more than once.
--   3. Authentication → Sign In / Providers → Email: turn OFF "Confirm email"
--      (Supabase's free email can't reach visitors).
--   4. Authentication → URL Configuration → Site URL: your site's address.
--   5. In index.html, fill in SYNC_CONFIG: url and anonKey (Project Settings → API), and site.
--   Optional, "Sign in with GitHub": create a GitHub OAuth App whose callback URL is the one shown under
--   Authentication → Sign In / Providers → GitHub, paste its Client ID and secret there, and set github: true.
--   The included GitHub Action pings the database every two days so the free project doesn't pause.

-- One row per person: their list, preferences and (optionally) encrypted API keys
create table if not exists public.user_data (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,  -- anime list, ranking, scores, notes, chat
  prefs      jsonb not null default '{}'::jsonb,  -- theme, effects, search sites, AI provider/model (never API keys)
  key_vault  jsonb,                               -- optional: API keys encrypted on the person's device with their
                                                  -- passphrase; the database only ever sees scrambled data
  updated_at timestamptz not null default now()
);

-- Keep rows to a sensible size (about 5 MB)
alter table public.user_data drop constraint if exists user_data_size;
alter table public.user_data add constraint user_data_size
  check (pg_column_size(data) + pg_column_size(prefs) < 5000000);

-- Only signed-in people can reach the table, and only their own row
revoke all on table public.user_data from anon;
grant select, insert, update, delete on table public.user_data to authenticated;

alter table public.user_data enable row level security;
drop policy if exists "own row: read"   on public.user_data;
drop policy if exists "own row: insert" on public.user_data;
drop policy if exists "own row: update" on public.user_data;
drop policy if exists "own row: delete" on public.user_data;
create policy "own row: read"   on public.user_data for select to authenticated using ((select auth.uid()) = user_id);
create policy "own row: insert" on public.user_data for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own row: update" on public.user_data for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "own row: delete" on public.user_data for delete to authenticated using ((select auth.uid()) = user_id);

-- Lets people delete their own account from Settings (their row goes with it)
create or replace function public.delete_my_account()
returns void
language sql
security definer
set search_path = ''
as $$
  delete from auth.users where id = auth.uid();
$$;
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

-- Tiny "are you there?" query used by the keep-alive GitHub Action
-- (free Supabase projects pause after a quiet week; this counts as activity).
-- It returns the current time and nothing else, so it's safe for anyone to call.
create or replace function public.keep_alive()
returns timestamptz
language sql
stable
set search_path = ''
as $$
  select now();
$$;
grant execute on function public.keep_alive() to anon, authenticated;

-- Live updates between devices
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'user_data'
  ) then
    alter publication supabase_realtime add table public.user_data;
  end if;
end $$;
