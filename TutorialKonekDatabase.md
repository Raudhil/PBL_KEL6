Cara menghubungkan Flutter ke Supabase

1. Install package Supabase di terminal flutter

flutter pub add supabase_flutter

2. Buat .env dan masukkan:

SUPABASE_URL=https://qocwwkkirsscsxtfsrpk.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFvY3d3a2tpcnNzY3N4dGZzcnBrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MjY3NTMsImV4cCI6MjA3ODUwMjc1M30.5jQmIjT8K6iBRwoTELoBe8joP36rwfiIAusGNzT2JMA

3. Pastikan pubspec.yamlnya juga terhubung dengan env

