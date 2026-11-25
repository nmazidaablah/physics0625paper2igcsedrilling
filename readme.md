# IGCSE Physics Paper 2 Practice (versi akaun + dashboard)

Laman web statik (tiada proses build). Pelajar daftar akaun sendiri, kemajuan disimpan di pelayan, dan cikgu ada dashboard semua pelajar.
Pangkalan data dan login guna **Supabase** (ada pelan percuma). Hosting guna **Netlify** atau **Cloudflare Pages** (percuma).

## Langkah pemasangan

1. **Supabase**: daftar di supabase.com, tekan *New project*, tunggu siap.
2. **Pangkalan data**: buka *SQL Editor*, tampal seluruh isi `supabase/schema.sql`, tekan *Run*.
3. **Pendaftaran mudah**: *Authentication > Sign In / Providers > Email*, matikan **Confirm email** (supaya pelajar boleh terus masuk selepas daftar).
4. **Kunci**: *Project Settings > API*. Salin **Project URL** dan **anon public key** ke dalam `config.js`. (Jangan guna kunci `service_role`.)
5. **Hosting**: seret seluruh folder ini ke app.netlify.com/drop (atau Cloudflare Pages > Upload assets). Anda akan dapat satu link untuk dikongsi.
6. **Akaun cikgu**: daftar satu akaun dalam app dengan e-mel cikgu, kemudian dalam *SQL Editor* jalankan:
   `update profiles set role = 'teacher' where id = (select id from auth.users where email = 'EMEL-CIKGU@contoh.com');`
   Muat semula app. Menu akan ada butang **Teacher dashboard**.

Nota: `index.html` tak boleh dibuka terus dengan klik dua kali (fail `questions.json` tak akan dimuat). Ia mesti dihoskan, atau dijalankan dengan `python3 -m http.server`.

## Apa yang disimpan
- `answers`: setiap jawapan (soalan, pilihan, betul/salah, mod practise atau timed).
- `attempts`: markah setiap kertas timed.
- Pelajar hanya nampak data sendiri. Cikgu nampak semua (dikawal oleh RLS dalam `schema.sql`).

## Belum ada (perlu untuk jual)
Pembayaran dan kawalan akses berbayar, set soalan SPM, reset kata laluan, dan polisi privasi (pelajar bawah 18 tahun).
