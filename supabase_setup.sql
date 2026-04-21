-- Run this in Supabase SQL Editor for full server-side behavior.

-- 1) Votes table (one vote per user per post)
create table if not exists public.post_votes (
  id bigserial primary key,
  post_id bigint not null references public.posts(id) on delete cascade,
  anonymous_id text not null,
  vote_value smallint not null check (vote_value in (-1, 1)),
  created_at timestamptz not null default now(),
  unique (post_id, anonymous_id)
);

-- 2) Moderators table (who can moderate)
create table if not exists public.moderators (
  id bigserial primary key,
  anonymous_id text not null unique,
  created_at timestamptz not null default now()
);

-- 3) Moderation actions (hide post/reply)
create table if not exists public.moderation_actions (
  id bigserial primary key,
  target_type text not null check (target_type in ('post', 'reply')),
  target_id bigint not null,
  action text not null check (action in ('hide')),
  moderator_id text not null,
  created_at timestamptz not null default now()
);

-- 4) Profanity dictionary managed on server
create table if not exists public.profanity_terms (
  id bigserial primary key,
  language text not null,
  term text not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- seed default multilingual terms
insert into public.profanity_terms(language, term, is_active) values
  ('en', 'fuck', true),
  ('en', 'fucker', true),
  ('en', 'shit', true),
  ('en', 'bitch', true),
  ('en', 'bastard', true),
  ('en', 'asshole', true),
  ('en', 'motherfucker', true),
  ('hi', 'madarchod', true),
  ('hi', 'bhenchod', true),
  ('hi', 'behenchod', true),
  ('hi', 'chutiya', true),
  ('hi', 'gaand', true),
  ('hi', 'gandu', true),
  ('hi', 'harami', true),
  ('hi', 'रंडी', true),
  ('hi', 'हरामी', true),
  ('bn', 'magi', true),
  ('bn', 'choda', true),
  ('bn', 'chod', true),
  ('bn', 'bal', true),
  ('bn', 'হারামি', true),
  ('bn', 'মাগি', true),
  ('or', 'chhinal', true),
  ('or', 'randi', true),
  ('or', 'gandu', true),
  ('or', 'harami', true),
  ('or', 'ହରାମି', true),
  ('or', 'ରାଣ୍ଡି', true)
on conflict (term) do nothing;

-- Enable RLS
alter table public.post_votes enable row level security;
alter table public.moderators enable row level security;
alter table public.moderation_actions enable row level security;
alter table public.profanity_terms enable row level security;

-- Basic policies for anonymous/publishable key usage
drop policy if exists "read votes" on public.post_votes;
create policy "read votes" on public.post_votes for select using (true);
drop policy if exists "write own votes" on public.post_votes;
create policy "write own votes" on public.post_votes for insert with check (true);
drop policy if exists "update own votes" on public.post_votes;
create policy "update own votes" on public.post_votes for update using (true) with check (true);
drop policy if exists "delete own votes" on public.post_votes;
create policy "delete own votes" on public.post_votes for delete using (true);

drop policy if exists "read moderators" on public.moderators;
create policy "read moderators" on public.moderators for select using (true);

drop policy if exists "read moderation actions" on public.moderation_actions;
create policy "read moderation actions" on public.moderation_actions for select using (true);
drop policy if exists "insert moderation actions" on public.moderation_actions;
create policy "insert moderation actions" on public.moderation_actions for insert with check (true);

drop policy if exists "read profanity terms" on public.profanity_terms;
create policy "read profanity terms" on public.profanity_terms for select using (true);
