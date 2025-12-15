-- Migration: Add peran_keluarga column to warga table
-- Date: 2025-12-15
-- Description: Tambah kolom peran_keluarga untuk validasi kepala keluarga

-- Add peran_keluarga column
ALTER TABLE public.warga 
ADD COLUMN peran_keluarga VARCHAR(50);

-- Add comment
COMMENT ON COLUMN public.warga.peran_keluarga IS 'Peran dalam keluarga: Kepala Keluarga, Istri/Suami, Anak, Orang Tua, dll';

-- Optional: Set default value for existing records
UPDATE public.warga 
SET peran_keluarga = 'Anggota Keluarga' 
WHERE peran_keluarga IS NULL;

-- Note: Tidak ada constraint UNIQUE karena hanya Kepala Keluarga yang harus unik per KK
-- Validasi dilakukan di aplikasi level
