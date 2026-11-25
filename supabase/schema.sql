-- Jalankan sekali dalam Supabase > SQL Editor

create table profiles (
  id uuid primary key references auth.users on delete cascade,
  name text not null default 'Student',
  role text not null default 'student' check (role in ('student','teacher')),
  created_at timestamptz default now()
);
create table answers (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  qkey text not null, paper text not null, topic int,
  chosen char(1) not null, correct boolean not null, mode text not null,
  created_at timestamptz default now()
);
create index on answers (user_id, qkey, created_at desc);
create table attempts (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  paper text not null, label text, score int not null, total int not null, seconds int,
  created_at timestamptz default now()
);

create function is_teacher() returns boolean language sql security definer stable set search_path = public as
$$ select exists (select 1 from profiles where id = auth.uid() and role = 'teacher') $$;

create function handle_new_user() returns trigger language plpgsql security definer set search_path = public as
$$ begin
  insert into profiles (id, name) values (new.id, coalesce(nullif(new.raw_user_meta_data->>'name',''), 'Student'));
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function handle_new_user();

alter table profiles enable row level security;
alter table answers  enable row level security;
alter table attempts enable row level security;
create policy "read own or teacher" on profiles for select using (id = auth.uid() or is_teacher());
create policy "read own or teacher" on answers  for select using (user_id = auth.uid() or is_teacher());
create policy "insert own"          on answers  for insert with check (user_id = auth.uid());
create policy "read own or teacher" on attempts for select using (user_id = auth.uid() or is_teacher());
create policy "insert own"          on attempts for insert with check (user_id = auth.uid());

create view my_latest with (security_invoker = true) as
  select distinct on (user_id, qkey) user_id, qkey, chosen from answers order by user_id, qkey, created_at desc;
create view my_best with (security_invoker = true) as
  select user_id, paper, max(score) as best from attempts group by user_id, paper;
create view student_summary with (security_invoker = true) as
  select p.id, p.name, count(a.id) as answered, count(a.id) filter (where a.correct) as right_count, max(a.created_at) as last_active
  from profiles p left join answers a on a.user_id = p.id where p.role = 'student' group by p.id, p.name;
