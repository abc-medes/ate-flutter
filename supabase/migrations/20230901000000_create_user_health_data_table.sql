-- Create a new table for user health data
CREATE TABLE IF NOT EXISTS public.user_health_data (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  height DECIMAL,
  weight DECIMAL,
  date_of_birth TIMESTAMP WITH TIME ZONE,
  gender TEXT,
  pre_existing_conditions JSONB,
  medications JSONB,
  allergies JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  CONSTRAINT unique_user_health_profile UNIQUE (user_id)
);

-- Add RLS policies for the new table
ALTER TABLE public.user_health_data ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own health data
CREATE POLICY "Users can read their own health data" 
ON public.user_health_data
FOR SELECT 
USING (auth.uid() = user_id);

-- Allow users to insert their own health data
CREATE POLICY "Users can insert their own health data" 
ON public.user_health_data
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own health data
CREATE POLICY "Users can update their own health data" 
ON public.user_health_data
FOR UPDATE 
USING (auth.uid() = user_id);

-- Create a migration to remove the health_profile field from the profiles table
-- This requires creating a function to handle JSON modification
CREATE OR REPLACE FUNCTION remove_health_profile_from_profiles()
RETURNS void AS $$
BEGIN
  -- Check if the column exists and has data
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'health_profile'
  ) THEN
    -- First, ensure user_health_data exists for each profile with health_profile
    INSERT INTO public.user_health_data (user_id, height, weight, date_of_birth, gender)
    SELECT 
      id, 
      (health_profile->>'height')::DECIMAL,
      (health_profile->>'weight')::DECIMAL,
      (health_profile->>'date_of_birth')::TIMESTAMP WITH TIME ZONE,
      health_profile->>'gender'
    FROM public.profiles
    WHERE health_profile IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM public.user_health_data WHERE user_id = profiles.id
    );
    
    -- Now we can safely alter the profiles table to remove the health_profile column
    ALTER TABLE public.profiles DROP COLUMN IF EXISTS health_profile;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Execute the function to perform the migration
SELECT remove_health_profile_from_profiles();

-- Drop the function after use (cleanup)
DROP FUNCTION IF EXISTS remove_health_profile_from_profiles();

-- Add a trigger to update the updated_at timestamp automatically
CREATE OR REPLACE FUNCTION update_user_health_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_health_updated_at
BEFORE UPDATE ON public.user_health_data
FOR EACH ROW
EXECUTE FUNCTION update_user_health_updated_at(); 