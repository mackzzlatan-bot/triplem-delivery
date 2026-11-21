-- TRIPLEM DELIVERY COMPANY: secure Supabase database setup
-- Run this in Supabase Dashboard > SQL Editor > New query.
-- Owner account email must be triplem0147@gmail.com.
-- Create that user manually in Authentication > Users > Add user before signing in.
-- Do not create a public sign-up form.

create extension if not exists pgcrypto;

create table if not exists public.shipments (
  id uuid primary key default gen_random_uuid(),
  tracking_number text not null unique,
  sender_name text not null,
  sender_contact text,
  receiver_name text not null,
  receiver_contact text,
  origin text not null,
  destination text not null,
  estimated_delivery date,
  status text not null default 'Pending Pickup'
    check (status in ('Pending Pickup','In Transit','Out for Delivery','Delivered')),
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.shipments enable row level security;

-- Remove broad defaults; then grant authenticated database operations subject to RLS.
revoke all on table public.shipments from anon, authenticated;
grant select, insert, update, delete on table public.shipments to authenticated;

drop policy if exists "Owner can view all shipments" on public.shipments;
create policy "Owner can view all shipments"
on public.shipments for select to authenticated
using (lower(coalesce(auth.jwt() ->> 'email','')) = 'triplem0147@gmail.com');

drop policy if exists "Owner can create shipments" on public.shipments;
create policy "Owner can create shipments"
on public.shipments for insert to authenticated
with check (lower(coalesce(auth.jwt() ->> 'email','')) = 'triplem0147@gmail.com');

drop policy if exists "Owner can update shipments" on public.shipments;
create policy "Owner can update shipments"
on public.shipments for update to authenticated
using (lower(coalesce(auth.jwt() ->> 'email','')) = 'triplem0147@gmail.com')
with check (lower(coalesce(auth.jwt() ->> 'email','')) = 'triplem0147@gmail.com');

drop policy if exists "Owner can delete shipments" on public.shipments;
create policy "Owner can delete shipments"
on public.shipments for delete to authenticated
using (lower(coalesce(auth.jwt() ->> 'email','')) = 'triplem0147@gmail.com');

-- Public tracking function returns only safe, non-personal fields.
create or replace function public.track_shipment(tracking_code text)
returns table (
  tracking_number text,
  status text,
  origin text,
  destination text,
  estimated_delivery date,
  created_at timestamptz,
  updated_at timestamptz
)
language sql
security definer
set search_path = public
stable
as $$
  select s.tracking_number, s.status, s.origin, s.destination,
         s.estimated_delivery, s.created_at, s.updated_at
  from public.shipments s
  where upper(s.tracking_number) = upper(trim(tracking_code))
  limit 1;
$$;

revoke all on function public.track_shipment(text) from public;
grant execute on function public.track_shipment(text) to anon, authenticated;

-- Optional: ensure only authenticated users can access the table at the API privilege level.
-- The owner policy above still restricts which authenticated user can read or modify records.
