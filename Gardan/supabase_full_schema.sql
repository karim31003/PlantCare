-- ================================================================
-- Gardan-zaki | Full Database Schema | Run in Supabase SQL Editor
-- ================================================================
-- HOW TO RUN:
--   1. Go to https://supabase.com → your project
--   2. Click "SQL Editor" in the left sidebar
--   3. Paste ALL of this file → click "Run"
--   4. You should see: "Success. No rows returned"
-- ================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── 1: Create products table ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.products (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT        NOT NULL,
  category    TEXT        NOT NULL,
  description TEXT,
  price       NUMERIC(10,2) NOT NULL,
  image_url   TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 2: Create plants table ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.plants (
  id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                 UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name                    TEXT        NOT NULL,
  species                 TEXT,
  image_url               TEXT,
  last_watered            TIMESTAMPTZ,
  watering_frequency_days INTEGER     NOT NULL DEFAULT 0,
  health_status           TEXT        NOT NULL,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 3: Create reminders table ────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.reminders (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plant_name     TEXT        NOT NULL,
  scheduled_time TEXT        NOT NULL,
  frequency      TEXT        NOT NULL DEFAULT 'daily',
  is_active      BOOLEAN     NOT NULL DEFAULT true,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 4: Create scans table (Plant Disease Detection) ──────────────
CREATE TABLE IF NOT EXISTS public.scans (
  id                   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plant_id             UUID        REFERENCES public.plants(id) ON DELETE SET NULL,
  image_url            TEXT,
  disease_name         TEXT        NOT NULL,
  confidence           NUMERIC(5,4),
  treatment_suggestion TEXT,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 5: Create cart_items table ───────────────────────────────────
CREATE TABLE IF NOT EXISTS public.cart_items (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id  UUID        NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  quantity    INTEGER     NOT NULL DEFAULT 1 CHECK (quantity > 0),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 6: Create orders table ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.orders (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status          TEXT        NOT NULL DEFAULT 'pending'
                              CHECK (status IN (
                                'pending', 'confirmed', 'preparing',
                                'shipped', 'outForDelivery', 'delivered', 'cancelled'
                              )),
  total_amount    NUMERIC(10,2) NOT NULL,
  full_name       TEXT        NOT NULL,
  phone           TEXT        NOT NULL,
  street_address  TEXT        NOT NULL,
  city            TEXT        NOT NULL,
  state           TEXT,
  zip             TEXT,
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ
);

-- ── 7: Create order_items table ──────────────────────────────────
CREATE TABLE IF NOT EXISTS public.order_items (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id    UUID        NOT NULL REFERENCES public.orders(id)   ON DELETE CASCADE,
  product_id  UUID        NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
  quantity    INT         NOT NULL CHECK (quantity > 0),
  unit_price  NUMERIC(10,2) NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Auto-update updated_at on orders ─────────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS orders_set_updated_at ON public.orders;
CREATE TRIGGER orders_set_updated_at
  BEFORE UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ── Indexes ──────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_plants_user_id ON public.plants(user_id);
CREATE INDEX IF NOT EXISTS idx_reminders_user_id ON public.reminders(user_id);
CREATE INDEX IF NOT EXISTS idx_scans_user_id ON public.scans(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON public.cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);

-- ================================================================
-- ROW LEVEL SECURITY (RLS)
-- ================================================================

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Products: Everyone can read, only admins/service role can insert/update
DROP POLICY IF EXISTS "Products are viewable by everyone" ON public.products;
CREATE POLICY "Products are viewable by everyone" ON public.products FOR SELECT USING (true);

-- Plants: Users can only read/write their own plants
DROP POLICY IF EXISTS "Users can view their own plants" ON public.plants;
DROP POLICY IF EXISTS "Users can insert their own plants" ON public.plants;
DROP POLICY IF EXISTS "Users can update their own plants" ON public.plants;
DROP POLICY IF EXISTS "Users can delete their own plants" ON public.plants;

CREATE POLICY "Users can view their own plants" ON public.plants FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own plants" ON public.plants FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own plants" ON public.plants FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own plants" ON public.plants FOR DELETE USING (auth.uid() = user_id);

-- Reminders: Users can only read/write their own reminders
DROP POLICY IF EXISTS "Users can manage their own reminders" ON public.reminders;
CREATE POLICY "Users can manage their own reminders" ON public.reminders FOR ALL USING (auth.uid() = user_id);

-- Scans: Users can only read/write their own scans
DROP POLICY IF EXISTS "Users can manage their own scans" ON public.scans;
CREATE POLICY "Users can manage their own scans" ON public.scans FOR ALL USING (auth.uid() = user_id);

-- Cart Items: Users can only read/write their own cart items
DROP POLICY IF EXISTS "Users can manage their own cart items" ON public.cart_items;
CREATE POLICY "Users can manage their own cart items" ON public.cart_items FOR ALL USING (auth.uid() = user_id);

-- Orders
DROP POLICY IF EXISTS "Users read own orders" ON public.orders;
DROP POLICY IF EXISTS "Users insert own orders" ON public.orders;
DROP POLICY IF EXISTS "Users update own orders" ON public.orders;

CREATE POLICY "Users read own orders" ON public.orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users insert own orders" ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users update own orders" ON public.orders FOR UPDATE USING (auth.uid() = user_id);

-- Order Items
DROP POLICY IF EXISTS "Users read own order items" ON public.order_items;
DROP POLICY IF EXISTS "Users insert own order items" ON public.order_items;

CREATE POLICY "Users read own order items" ON public.order_items FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid())
);
CREATE POLICY "Users insert own order items" ON public.order_items FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid())
);

-- ================================================================
-- REALTIME
-- ================================================================
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.cart_items;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.plants;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- ================================================================
-- DONE ✓
-- ================================================================
