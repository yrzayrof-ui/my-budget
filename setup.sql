-- ============================================================
-- Mon Budget — Schéma Supabase
-- ============================================================
-- À copier-coller dans : Supabase Dashboard > SQL Editor > New query
-- Puis cliquer sur "Run" (Ctrl+Enter)
-- ============================================================
 
-- Table des transactions (revenus + dépenses)
create table if not exists public.transactions (
  id           text         primary key,
  user_id      uuid         references auth.users(id) on delete cascade not null default auth.uid(),
  type         text         not null check (type in ('income', 'expense')),
  amount       numeric      not null check (amount > 0),
  category     text         not null,
  description  text,
  date         timestamptz  not null default now(),
  deleted_at   timestamptz,                                  -- soft delete pour la sync multi-appareils
  created_at   timestamptz  not null default now(),
  updated_at   timestamptz  not null default now()
);

-- Index pour des requêtes rapides
create index if not exists transactions_user_date_idx
  on public.transactions(user_id, date desc);

create index if not exists transactions_user_updated_idx
  on public.transactions(user_id, updated_at desc);

-- Row Level Security : chaque utilisateur ne voit QUE ses propres transactions
alter table public.transactions enable row level security;

drop policy if exists "Users can view own transactions"   on public.transactions;
drop policy if exists "Users can insert own transactions" on public.transactions;
drop policy if exists "Users can update own transactions" on public.transactions;
drop policy if exists "Users can delete own transactions" on public.transactions;

create policy "Users can view own transactions"
  on public.transactions for select
  using (auth.uid() = user_id);

create policy "Users can insert own transactions"
  on public.transactions for insert
  with check (auth.uid() = user_id);

create policy "Users can update own transactions"
  on public.transactions for update
  using (auth.uid() = user_id);

create policy "Users can delete own transactions"
  on public.transactions for delete
  using (auth.uid() = user_id);

-- Trigger pour mettre à jour automatiquement updated_at
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists transactions_updated_at on public.transactions;
create trigger transactions_updated_at
  before update on public.transactions
  for each row
  execute function public.handle_updated_at();

-- Activation de la réplication temps réel (pour la sync entre appareils)
alter publication supabase_realtime add table public.transactions;


-- ============================================================
-- Table des prêts reçus
-- ============================================================
create table if not exists public.loans (
  id           text         primary key,
  user_id      uuid         references auth.users(id) on delete cascade not null default auth.uid(),
  amount       numeric      not null check (amount > 0),
  lender       text         not null,
  lender_type  text         not null check (lender_type in ('marche', 'famille')),
  description  text,
  date         timestamptz  not null default now(),
  status       text         not null default 'actif' check (status in ('actif', 'rembourse')),
  deleted_at   timestamptz,
  created_at   timestamptz  not null default now(),
  updated_at   timestamptz  not null default now()
);

alter table public.loans enable row level security;

drop policy if exists "Users can view own loans"   on public.loans;
drop policy if exists "Users can insert own loans" on public.loans;
drop policy if exists "Users can update own loans" on public.loans;
drop policy if exists "Users can delete own loans" on public.loans;

create policy "Users can view own loans"   on public.loans for select using (auth.uid() = user_id);
create policy "Users can insert own loans" on public.loans for insert with check (auth.uid() = user_id);
create policy "Users can update own loans" on public.loans for update using (auth.uid() = user_id);
create policy "Users can delete own loans" on public.loans for delete using (auth.uid() = user_id);

drop trigger if exists loans_updated_at on public.loans;
create trigger loans_updated_at
  before update on public.loans
  for each row execute function public.handle_updated_at();

alter publication supabase_realtime add table public.loans;
