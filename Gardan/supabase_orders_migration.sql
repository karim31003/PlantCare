-- ================================================================
-- Gardan-zaki | Orders Migration | Run in Supabase SQL Editor
-- ================================================================
-- HOW TO RUN:
--   1. Go to https://supabase.com → your project
--   2. Click "SQL Editor" in the left sidebar
--   3. Paste ALL of this file → click "Run"
--   4. You should see: "Success. No rows returned"
-- ================================================================

-- ── Step 1: Create orders table ──────────────────────────────────
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

-- ── Step 2: Create order_items table ────────────────────────────
CREATE TABLE IF NOT EXISTS public.order_items (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id    UUID        NOT NULL REFERENCES public.orders(id)   ON DELETE CASCADE,
  product_id  UUID        NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
  quantity    INT         NOT NULL CHECK (quantity > 0),
  unit_price  NUMERIC(10,2) NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Step 3: Auto-update updated_at on orders ─────────────────────
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

-- ── Step 4: Indexes ───────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_orders_user_id
  ON public.orders(user_id);

CREATE INDEX IF NOT EXISTS idx_orders_status
  ON public.orders(status);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id
  ON public.order_items(order_id);

-- ── Step 5: Row Level Security ───────────────────────────────────
ALTER TABLE public.orders      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Drop old policies first (safe to re-run)
DROP POLICY IF EXISTS "Users read own orders"        ON public.orders;
DROP POLICY IF EXISTS "Users insert own orders"      ON public.orders;
DROP POLICY IF EXISTS "Users update own orders"      ON public.orders;
DROP POLICY IF EXISTS "Users read own order items"   ON public.order_items;
DROP POLICY IF EXISTS "Users insert own order items" ON public.order_items;

-- orders policies
CREATE POLICY "Users read own orders"
  ON public.orders FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users insert own orders"
  ON public.orders FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own orders"
  ON public.orders FOR UPDATE
  USING (auth.uid() = user_id);

-- order_items policies
CREATE POLICY "Users read own order items"
  ON public.order_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id      = order_items.order_id
        AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "Users insert own order items"
  ON public.order_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id      = order_items.order_id
        AND orders.user_id = auth.uid()
    )
  );

-- ── Step 6: Enable Realtime ───────────────────────────────────────
-- Needed for live order tracking in Flutter
ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;

-- ================================================================
-- DONE ✓  Tables: orders + order_items
-- DONE ✓  RLS policies applied
-- DONE ✓  Realtime enabled on orders
-- ================================================================
