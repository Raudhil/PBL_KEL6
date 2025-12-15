-- ============================================
-- NOTIFICATION SYSTEM - SQL SETUP
-- Copy paste ini ke SQL Editor Supabase
-- ============================================

-- 1. TABEL NOTIFICATIONS (Utama)
-- ============================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  type VARCHAR(50) NOT NULL, -- 'pengumuman', 'kegiatan', 'iuran', 'marketplace', 'system'
  category VARCHAR(50), -- Sub-kategori detail
  priority VARCHAR(20) DEFAULT 'low', -- 'high', 'medium', 'low'
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  
  -- Referensi ke objek terkait
  reference_id INTEGER, -- ID dari pengumuman/kegiatan/iuran/transaksi
  reference_type VARCHAR(50), -- Tipe referensi
  
  -- Metadata
  action_url TEXT, -- Route untuk navigation
  image_url TEXT, -- Gambar untuk rich notification
  extra_data JSONB, -- Data tambahan fleksibel
  
  -- Status
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP, -- Auto-delete setelah tanggal ini
  
  -- Foreign key ke users table
  CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) 
    REFERENCES public.users(id) ON DELETE CASCADE
);

-- Index untuk performa
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON public.notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON public.notifications(type);
CREATE INDEX IF NOT EXISTS idx_notifications_reference ON public.notifications(reference_type, reference_id);

-- ============================================
-- 2. TABEL NOTIFICATION_SETTINGS
-- ============================================
CREATE TABLE IF NOT EXISTS public.notification_settings (
  user_id INTEGER PRIMARY KEY,
  
  -- Toggle per kategori
  enable_pengumuman BOOLEAN DEFAULT TRUE,
  enable_kegiatan BOOLEAN DEFAULT TRUE,
  enable_iuran BOOLEAN DEFAULT TRUE,
  enable_marketplace BOOLEAN DEFAULT TRUE,
  enable_system BOOLEAN DEFAULT TRUE,
  
  -- Pengaturan umum
  enable_push BOOLEAN DEFAULT TRUE,
  enable_sound BOOLEAN DEFAULT TRUE,
  enable_vibration BOOLEAN DEFAULT TRUE,
  
  -- Quiet hours
  quiet_hours_start TIME, -- contoh: '22:00:00'
  quiet_hours_end TIME, -- contoh: '07:00:00'
  
  -- Auto clear
  auto_clear_days INTEGER DEFAULT 30,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  -- Foreign key
  CONSTRAINT notification_settings_user_id_fkey FOREIGN KEY (user_id) 
    REFERENCES public.users(id) ON DELETE CASCADE
);

-- ============================================
-- 3. TABEL NOTIFICATION_TOKENS (FCM)
-- ============================================
CREATE TABLE IF NOT EXISTS public.notification_tokens (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  device_token TEXT NOT NULL UNIQUE,
  device_type VARCHAR(20), -- 'android', 'ios', 'web'
  device_name VARCHAR(100),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  last_used_at TIMESTAMP DEFAULT NOW(),
  
  -- Foreign key
  CONSTRAINT notification_tokens_user_id_fkey FOREIGN KEY (user_id) 
    REFERENCES public.users(id) ON DELETE CASCADE
);

-- Index
CREATE INDEX IF NOT EXISTS idx_notification_tokens_user ON public.notification_tokens(user_id, is_active);

-- ============================================
-- 4. FUNCTION: Create Notification
-- ============================================
CREATE OR REPLACE FUNCTION public.create_notification(
  p_user_id INTEGER,
  p_type VARCHAR,
  p_title VARCHAR,
  p_message TEXT,
  p_priority VARCHAR DEFAULT 'low',
  p_reference_id INTEGER DEFAULT NULL,
  p_reference_type VARCHAR DEFAULT NULL,
  p_action_url TEXT DEFAULT NULL,
  p_image_url TEXT DEFAULT NULL
) RETURNS INTEGER AS $$
DECLARE
  notification_id INTEGER;
  user_settings RECORD;
BEGIN
  -- Cek settings user
  SELECT * INTO user_settings 
  FROM public.notification_settings 
  WHERE user_id = p_user_id;
  
  -- Jika belum ada settings, buat default
  IF NOT FOUND THEN
    INSERT INTO public.notification_settings (user_id)
    VALUES (p_user_id);
    
    SELECT * INTO user_settings 
    FROM public.notification_settings 
    WHERE user_id = p_user_id;
  END IF;
  
  -- Cek apakah kategori notifikasi enabled
  IF (p_type = 'pengumuman' AND NOT user_settings.enable_pengumuman) OR
     (p_type = 'kegiatan' AND NOT user_settings.enable_kegiatan) OR
     (p_type = 'iuran' AND NOT user_settings.enable_iuran) OR
     (p_type = 'marketplace' AND NOT user_settings.enable_marketplace) OR
     (p_type = 'system' AND NOT user_settings.enable_system) THEN
    RETURN NULL; -- User disabled kategori ini
  END IF;
  
  -- Insert notification
  INSERT INTO public.notifications (
    user_id, type, title, message, priority,
    reference_id, reference_type, action_url, image_url
  ) VALUES (
    p_user_id, p_type, p_title, p_message, p_priority,
    p_reference_id, p_reference_type, p_action_url, p_image_url
  ) RETURNING id INTO notification_id;
  
  RETURN notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5. TRIGGER: New Pengumuman
-- ============================================
CREATE OR REPLACE FUNCTION public.notify_new_pengumuman()
RETURNS TRIGGER AS $$
BEGIN
  -- Kirim notifikasi ke semua warga aktif kecuali pembuat
  INSERT INTO public.notifications (
    user_id, type, priority, title, message, 
    reference_id, reference_type, action_url, image_url
  )
  SELECT 
    u.id,
    'pengumuman',
    'medium',
    '📢 ' || NEW.judul,
    CASE 
      WHEN LENGTH(NEW.isi) > 100 THEN SUBSTRING(NEW.isi, 1, 100) || '...'
      ELSE NEW.isi
    END,
    NEW.id,
    'pengumuman',
    '/pengumuman/' || NEW.id,
    NEW.foto_url
  FROM public.users u
  LEFT JOIN public.notification_settings ns ON u.id = ns.user_id
  WHERE u.status = 'Aktif'
    AND (ns.enable_pengumuman IS NULL OR ns.enable_pengumuman = TRUE)
    AND u.id != NEW.id_pembuat;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_new_pengumuman ON public.pengumuman;
CREATE TRIGGER trigger_new_pengumuman
AFTER INSERT ON public.pengumuman
FOR EACH ROW
EXECUTE FUNCTION public.notify_new_pengumuman();

-- ============================================
-- 6. TRIGGER: New Kegiatan
-- ============================================
CREATE OR REPLACE FUNCTION public.notify_new_kegiatan()
RETURNS TRIGGER AS $$
BEGIN
  -- Kirim notifikasi ke semua warga aktif
  INSERT INTO public.notifications (
    user_id, type, priority, title, message, 
    reference_id, reference_type, action_url, image_url
  )
  SELECT 
    u.id,
    'kegiatan',
    'medium',
    '📅 Kegiatan Baru: ' || NEW.judul,
    COALESCE(NEW.deskripsi, 'Ada kegiatan baru di RT. Klik untuk lihat detail.'),
    NEW.id::INTEGER,
    'kegiatan',
    '/kegiatan/' || NEW.id,
    NEW.foto_url
  FROM public.users u
  LEFT JOIN public.notification_settings ns ON u.id = ns.user_id
  WHERE u.status = 'Aktif'
    AND (ns.enable_kegiatan IS NULL OR ns.enable_kegiatan = TRUE);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_new_kegiatan ON public.kegiatan;
CREATE TRIGGER trigger_new_kegiatan
AFTER INSERT ON public.kegiatan
FOR EACH ROW
EXECUTE FUNCTION public.notify_new_kegiatan();

-- ============================================
-- 7. TRIGGER: Pembayaran Iuran Berhasil
-- ============================================
CREATE OR REPLACE FUNCTION public.notify_payment_success()
RETURNS TRIGGER AS $$
DECLARE
  iuran_info RECORD;
BEGIN
  -- Hanya trigger jika status berubah menjadi Lunas
  IF NEW.status = 'Lunas' AND (OLD.status IS NULL OR OLD.status != 'Lunas') THEN
    -- Ambil info iuran
    SELECT * INTO iuran_info FROM public.iuran WHERE id = NEW.id_iuran;
    
    -- Kirim notifikasi ke user yang bayar
    PERFORM public.create_notification(
      NEW.id_user,
      'iuran',
      '✅ Pembayaran Berhasil',
      'Pembayaran iuran ' || iuran_info.jenis || ' berhasil. Terima kasih!',
      'medium',
      NEW.id,
      'transaksi_iuran',
      '/iuran/history'
    );
    
    -- Kirim notifikasi ke bendahara
    PERFORM public.create_notification(
      iuran_info.id_bendahara,
      'iuran',
      '💰 Pembayaran Masuk',
      'Ada pembayaran iuran ' || iuran_info.jenis || ' baru',
      'low',
      NEW.id,
      'transaksi_iuran',
      '/bendahara/iuran'
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_payment_success ON public.transaksi_iuran;
CREATE TRIGGER trigger_payment_success
AFTER INSERT OR UPDATE ON public.transaksi_iuran
FOR EACH ROW
EXECUTE FUNCTION public.notify_payment_success();

-- ============================================
-- 8. TRIGGER: New Order Marketplace
-- ============================================
CREATE OR REPLACE FUNCTION public.notify_new_order()
RETURNS TRIGGER AS $$
DECLARE
  seller_ids INTEGER[];
BEGIN
  -- Ambil semua seller dari produk yang dibeli
  SELECT ARRAY_AGG(DISTINCT t.id_pemilik) INTO seller_ids
  FROM public.detail_t_marketplace dtm
  JOIN public.produk p ON dtm.id_produk = p.id
  JOIN public.toko t ON p.id_toko = t.id
  WHERE dtm.id_transaksi = NEW.id;
  
  -- Kirim notifikasi ke setiap seller
  IF seller_ids IS NOT NULL THEN
    INSERT INTO public.notifications (
      user_id, type, priority, title, message, 
      reference_id, reference_type, action_url
    )
    SELECT 
      unnest(seller_ids),
      'marketplace',
      'high',
      '🛒 Pesanan Baru!',
      'Anda mendapat pesanan baru. Segera proses pesanan.',
      NEW.id,
      'transaksi_marketplace',
      '/seller/orders/' || NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_new_order ON public.transaksi_marketplace;
CREATE TRIGGER trigger_new_order
AFTER INSERT ON public.transaksi_marketplace
FOR EACH ROW
EXECUTE FUNCTION public.notify_new_order();

-- ============================================
-- 9. TRIGGER: Update Status Pesanan
-- ============================================
CREATE OR REPLACE FUNCTION public.notify_order_status()
RETURNS TRIGGER AS $$
DECLARE
  status_message TEXT;
BEGIN
  -- Hanya trigger jika status berubah
  IF NEW.status != OLD.status THEN
    status_message := CASE NEW.status
      WHEN 'Diproses' THEN '📦 Pesanan sedang diproses oleh penjual'
      WHEN 'Dikirim' THEN '🚚 Pesanan sedang dikirim'
      WHEN 'Selesai' THEN '✅ Pesanan selesai. Jangan lupa berikan ulasan!'
      WHEN 'Dibatalkan' THEN '❌ Pesanan dibatalkan'
      ELSE 'Status pesanan diperbarui'
    END;
    
    -- Kirim ke pembeli
    PERFORM public.create_notification(
      NEW.id_pembeli,
      'marketplace',
      'Update Pesanan',
      status_message,
      'medium',
      NEW.id,
      'transaksi_marketplace',
      '/orders/' || NEW.id
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_order_status ON public.transaksi_marketplace;
CREATE TRIGGER trigger_order_status
AFTER UPDATE ON public.transaksi_marketplace
FOR EACH ROW
EXECUTE FUNCTION public.notify_order_status();

-- ============================================
-- 10. FUNCTION: Auto Delete Old Notifications
-- ============================================
CREATE OR REPLACE FUNCTION public.cleanup_old_notifications()
RETURNS void AS $$
BEGIN
  -- Hapus notifikasi yang sudah dibaca > 30 hari
  DELETE FROM public.notifications
  WHERE is_read = TRUE
    AND read_at < NOW() - INTERVAL '30 days';
  
  -- Hapus notifikasi expired
  DELETE FROM public.notifications
  WHERE expires_at IS NOT NULL
    AND expires_at < NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 11. ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_tokens ENABLE ROW LEVEL SECURITY;

-- Policy: User hanya bisa lihat notifikasi sendiri
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (user_id = (
    SELECT id FROM public.users WHERE id_auth = auth.uid()
  ));

-- Policy: User bisa update notifikasi sendiri (mark as read)
CREATE POLICY "Users can update own notifications" ON public.notifications
  FOR UPDATE USING (user_id = (
    SELECT id FROM public.users WHERE id_auth = auth.uid()
  ));

-- Policy: User bisa delete notifikasi sendiri
CREATE POLICY "Users can delete own notifications" ON public.notifications
  FOR DELETE USING (user_id = (
    SELECT id FROM public.users WHERE id_auth = auth.uid()
  ));

-- Policy: Settings
CREATE POLICY "Users can manage own settings" ON public.notification_settings
  FOR ALL USING (user_id = (
    SELECT id FROM public.users WHERE id_auth = auth.uid()
  ));

-- Policy: Tokens
CREATE POLICY "Users can manage own tokens" ON public.notification_tokens
  FOR ALL USING (user_id = (
    SELECT id FROM public.users WHERE id_auth = auth.uid()
  ));

-- ============================================
-- 12. CREATE HELPER FUNCTIONS
-- ============================================

-- Get unread count
CREATE OR REPLACE FUNCTION public.get_unread_count(p_user_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
  count INTEGER;
BEGIN
  SELECT COUNT(*) INTO count
  FROM public.notifications
  WHERE user_id = p_user_id AND is_read = FALSE;
  
  RETURN count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Mark all as read
CREATE OR REPLACE FUNCTION public.mark_all_notifications_read(p_user_id INTEGER)
RETURNS void AS $$
BEGIN
  UPDATE public.notifications
  SET is_read = TRUE, read_at = NOW()
  WHERE user_id = p_user_id AND is_read = FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Clear all notifications
CREATE OR REPLACE FUNCTION public.clear_all_notifications(p_user_id INTEGER)
RETURNS void AS $$
BEGIN
  DELETE FROM public.notifications
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- SELESAI! 
-- Schema notification sudah siap digunakan
-- ============================================

-- Test query untuk cek tabel
-- SELECT * FROM public.notifications LIMIT 10;
-- SELECT * FROM public.notification_settings LIMIT 10;
