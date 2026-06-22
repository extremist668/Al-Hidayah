-- SQL Schema for Islamic Android Application
-- Place this in the Supabase SQL Editor to execute.

-- 1. PROFILES TABLE (linked to auth.users)
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own profile" 
    ON public.profiles FOR SELECT 
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
    ON public.profiles FOR UPDATE 
    USING (auth.uid() = id);

-- Trigger to create profile when auth.users is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, avatar_url)
  VALUES (
    new.id,
    new.email,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- 2. PRAYER LOGS TABLE (Offline Sync-friendly)
CREATE TABLE public.prayer_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    prayer_date DATE NOT NULL,
    prayer_name VARCHAR(15) NOT NULL, -- 'fajr', 'dhuhr', 'asr', 'maghrib', 'isha'
    status VARCHAR(20) NOT NULL,      -- 'completed', 'missed', 'qaza', 'none'
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT unique_user_prayer_date UNIQUE (user_id, prayer_date, prayer_name)
);

ALTER TABLE public.prayer_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own prayer logs"
    ON public.prayer_logs FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_prayer_logs_user_date ON public.prayer_logs(user_id, prayer_date);


-- 3. PRAYER STREAKS TABLE
CREATE TABLE public.prayer_streaks (
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE PRIMARY KEY,
    current_streak INT DEFAULT 0 NOT NULL,
    max_streak INT DEFAULT 0 NOT NULL,
    last_tracked_date DATE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.prayer_streaks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own streaks"
    ON public.prayer_streaks FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);


-- 4. ZAKAT HISTORY TABLE
CREATE TABLE public.zakat_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    calculation_date DATE DEFAULT CURRENT_DATE NOT NULL,
    cash_amount NUMERIC(15,2) DEFAULT 0.00 NOT NULL,
    gold_value NUMERIC(15,2) DEFAULT 0.00 NOT NULL,
    silver_value NUMERIC(15,2) DEFAULT 0.00 NOT NULL,
    business_assets NUMERIC(15,2) DEFAULT 0.00 NOT NULL,
    other_assets NUMERIC(15,2) DEFAULT 0.00 NOT NULL,
    liabilities NUMERIC(15,2) DEFAULT 0.00 NOT NULL,
    nisab_value NUMERIC(15,2) DEFAULT 0.00 NOT NULL,
    nisab_type VARCHAR(10) NOT NULL, -- 'gold' or 'silver'
    total_zakat NUMERIC(15,2) DEFAULT 0.00 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.zakat_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own zakat history"
    ON public.zakat_history FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_zakat_history_user ON public.zakat_history(user_id);


-- 5. QURAN PROGRESS TABLE
CREATE TABLE public.quran_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    last_read_surah INT NOT NULL,     -- Surah number (1-114)
    last_read_ayah INT NOT NULL,      -- Ayah number
    surah_name_en VARCHAR(100),
    surah_name_ar VARCHAR(100),
    progress_percentage NUMERIC(5,2) DEFAULT 0.00 NOT NULL, -- overall progress or surah progress
    is_completed BOOLEAN DEFAULT FALSE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT unique_user_surah_progress UNIQUE (user_id, last_read_surah)
);

ALTER TABLE public.quran_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own quran progress"
    ON public.quran_progress FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_quran_progress_user ON public.quran_progress(user_id);


-- 6. RAMADAN TRACKER TABLE
CREATE TABLE public.ramadan_tracker (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    year INT NOT NULL,                      -- Islamic Year (e.g., 1447)
    fast_day INT NOT NULL,                  -- Day of Ramadan (1-30)
    fast_date DATE NOT NULL,
    is_fasting BOOLEAN DEFAULT TRUE NOT NULL,
    sehri_reminder BOOLEAN DEFAULT TRUE NOT NULL,
    iftar_reminder BOOLEAN DEFAULT TRUE NOT NULL,
    quran_pages_read INT DEFAULT 0 NOT NULL,
    charity_amount NUMERIC(15,2) DEFAULT 0.00 NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT unique_user_ramadan_day UNIQUE (user_id, year, fast_day)
);

ALTER TABLE public.ramadan_tracker ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own ramadan tracker"
    ON public.ramadan_tracker FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_ramadan_tracker_user ON public.ramadan_tracker(user_id);


-- 7. USER SETTINGS TABLE
CREATE TABLE public.user_settings (
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE PRIMARY KEY,
    language VARCHAR(10) DEFAULT 'en' NOT NULL, -- 'en', 'ur', 'ar'
    theme_mode VARCHAR(10) DEFAULT 'system' NOT NULL, -- 'light', 'dark', 'system'
    madhab VARCHAR(15) DEFAULT 'hanafi' NOT NULL,     -- 'hanafi', 'shafii'
    calculation_method INT DEFAULT 2 NOT NULL,        -- Aladhan calculations methods
    notifications_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    azan_sound VARCHAR(50) DEFAULT 'default' NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own settings"
    ON public.user_settings FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);


-- 8. NOTIFICATIONS AND REMINDERS (Queue / Log)
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    category VARCHAR(30) NOT NULL, -- 'prayer', 'ramadan', 'general'
    is_read BOOLEAN DEFAULT FALSE NOT NULL,
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own notifications"
    ON public.notifications FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_notifications_user_unread ON public.notifications(user_id, is_read);
