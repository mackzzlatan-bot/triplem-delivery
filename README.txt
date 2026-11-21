# TRIPLEM DELIVERY COMPANY website setup

Files:
- `index.html` — public website, public tracking form, owner sign-in and owner dashboard.
- `supabase_setup.sql` — database table, owner-only Row Level Security policies, and safe public tracking function.

## Setup order

1. Create a Supabase project.
2. In Supabase > SQL Editor > New query, paste and run all of `supabase_setup.sql`.
3. In Supabase > Authentication > Users, add/ invite the owner user `triplem0147@gmail.com` and set a strong password. Do not enable public sign-ups.
4. In Supabase > Project Settings > API, copy the Project URL and publishable key (or legacy anon key).
5. Open `index.html` and replace:
   - `PASTE_YOUR_SUPABASE_PROJECT_URL`
   - `PASTE_YOUR_SUPABASE_PUBLISHABLE_KEY`
   with those values.
6. Upload `index.html` to the root of your GitHub repository, then connect the repository to Cloudflare Pages.

Security notes:
- Never place a Supabase service_role or secret key in the HTML.
- Public users can only call `track_shipment`, which returns tracking number, status, origin, destination, ETA and timestamps.
- Sender and receiver names, contacts, and internal description are only available to the authorised owner account through RLS.
- The owner restriction in SQL is based on the authenticated email `triplem0147@gmail.com`. Protect that mailbox and use a strong unique password.
- The HTML file is a starter implementation. Test the owner login, shipment creation, updates, deletion and public tracking before using real customer records.
- The supplied address is displayed as provided; verify the business address before launch.
