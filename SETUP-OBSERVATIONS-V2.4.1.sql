-- Katterums jaktlag v2.4.1 - gemensamma observationer och viltspår
alter table public.observations add column if not exists wind_direction text;
alter table public.observations add column if not exists wind_speed double precision;
alter table public.observations add column if not exists track jsonb not null default '[]'::jsonb;
alter table public.observations add column if not exists observer_name text;
alter table public.observations add column if not exists observer_id text;
alter table public.observations add column if not exists activity text;
alter table public.observations add column if not exists metadata jsonb not null default '{}'::jsonb;
alter table public.observations alter column created_by set default auth.uid();
alter table public.observations enable row level security;

drop policy if exists observations_read_team on public.observations;
create policy observations_read_team on public.observations for select to authenticated
using (exists (select 1 from public.team_memberships tm where tm.team_id=observations.team_id and tm.user_id=auth.uid() and tm.active=true));

drop policy if exists observations_insert_team on public.observations;
create policy observations_insert_team on public.observations for insert to authenticated
with check (created_by=auth.uid() and exists (select 1 from public.team_memberships tm where tm.team_id=observations.team_id and tm.user_id=auth.uid() and tm.active=true));

drop policy if exists observations_update_team on public.observations;
create policy observations_update_team on public.observations for update to authenticated
using (exists (select 1 from public.team_memberships tm where tm.team_id=observations.team_id and tm.user_id=auth.uid() and tm.active=true))
with check (exists (select 1 from public.team_memberships tm where tm.team_id=observations.team_id and tm.user_id=auth.uid() and tm.active=true));

drop policy if exists observations_delete_team on public.observations;
create policy observations_delete_team on public.observations for delete to authenticated
using (exists (select 1 from public.team_memberships tm where tm.team_id=observations.team_id and tm.user_id=auth.uid() and tm.active=true));
