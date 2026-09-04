-- ============================================================
-- SKILORAX — Initial Database Schema
-- Built in Africa. Designed for the World.
-- ============================================================

-- 1. PROFILES (extends auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  avatar_url TEXT,
  bio TEXT,
  location TEXT,
  title TEXT,
  website TEXT,
  skills TEXT[] DEFAULT '{}',
  is_verified BOOLEAN DEFAULT false,
  is_expert BOOLEAN DEFAULT false,
  seller_status TEXT DEFAULT 'none', -- 'none','pending','active','suspended'
  follower_count INT DEFAULT 0,
  following_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_profiles_username ON profiles(username);
CREATE INDEX idx_profiles_skills ON profiles USING GIN(skills);

-- 2. SPARKS (content)
CREATE TABLE sparks (
  id BIGSERIAL PRIMARY KEY,
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content_type TEXT NOT NULL, -- 'text','photo','video','short','audio','pdf','project','poll','question','achievement','opportunity','product','event','learning'
  content TEXT,
  skills TEXT[] DEFAULT '{}',
  skill_proof TEXT,
  series_id BIGINT REFERENCES spark_series(id) ON DELETE SET NULL,
  visibility TEXT DEFAULT 'public', -- 'public','followers','connections','private'
  media JSONB DEFAULT '[]',
  poll_options JSONB,
  poll_votes JSONB,
  link_entity_type TEXT,
  link_entity_id BIGINT,
  like_count INT DEFAULT 0,
  comment_count INT DEFAULT 0,
  reshare_count INT DEFAULT 0,
  view_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ NULL
);

CREATE INDEX idx_sparks_author_created ON sparks(author_id, created_at DESC);
CREATE INDEX idx_sparks_skills ON sparks USING GIN(skills);
CREATE INDEX idx_sparks_created ON sparks(created_at DESC);
CREATE INDEX idx_sparks_visibility ON sparks(visibility) WHERE deleted_at IS NULL;

-- 3. LIKES
CREATE TABLE likes (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  spark_id BIGINT NOT NULL REFERENCES sparks(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, spark_id)
);

CREATE INDEX idx_likes_spark ON likes(spark_id);
CREATE INDEX idx_likes_user ON likes(user_id);

-- 4. COMMENTS
CREATE TABLE comments (
  id BIGSERIAL PRIMARY KEY,
  spark_id BIGINT NOT NULL REFERENCES sparks(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  parent_comment_id BIGINT REFERENCES comments(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  like_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_comments_spark ON comments(spark_id);
CREATE INDEX idx_comments_parent ON comments(parent_comment_id);

-- 5. RESHARES
CREATE TABLE reshares (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  original_spark_id BIGINT NOT NULL REFERENCES sparks(id) ON DELETE CASCADE,
  quote_text TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, original_spark_id)
);

-- 6. FOLLOWS
CREATE TABLE follows (
  id BIGSERIAL PRIMARY KEY,
  follower_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(follower_id, following_id)
);

CREATE INDEX idx_follows_follower ON follows(follower_id);
CREATE INDEX idx_follows_following ON follows(following_id);

-- 7. CONVERSATIONS
CREATE TABLE conversations (
  id BIGSERIAL PRIMARY KEY,
  participant_ids UUID[] NOT NULL,
  last_message TEXT,
  last_message_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_conv_participants ON conversations USING GIN(participant_ids);

-- 8. MESSAGES
CREATE TABLE messages (
  id BIGSERIAL PRIMARY KEY,
  conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES profiles(id),
  content TEXT NOT NULL,
  read_at TIMESTAMPTZ NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_conv ON messages(conversation_id, created_at DESC);

-- 9. NOTIFICATIONS
CREATE TABLE notifications (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  actor_id UUID NOT NULL REFERENCES profiles(id),
  type TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id BIGINT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read, created_at DESC);

-- 10. PRODUCTS
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  seller_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2),
  currency TEXT DEFAULT 'USD',
  product_type TEXT,
  checkout_url TEXT,
  media JSONB DEFAULT '[]',
  status TEXT DEFAULT 'draft',
  views INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_products_seller ON products(seller_id);

-- 11. OPPORTUNITIES
CREATE TABLE opportunities (
  id BIGSERIAL PRIMARY KEY,
  creator_id UUID NOT NULL REFERENCES profiles(id),
  title TEXT NOT NULL,
  description TEXT,
  company TEXT,
  type TEXT,
  location TEXT,
  remote BOOLEAN DEFAULT true,
  skills TEXT[] DEFAULT '{}',
  compensation TEXT,
  application_url TEXT,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_opp_skills ON opportunities USING GIN(skills);
