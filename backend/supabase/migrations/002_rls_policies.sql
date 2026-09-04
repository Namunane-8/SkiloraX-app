-- ============================================================
-- SKILORAX — Row Level Security (RLS) Policies
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sparks ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reshares ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE opportunities ENABLE ROW LEVEL SECURITY;

-- PROFILES
CREATE POLICY profiles_read ON profiles FOR SELECT USING (true);
CREATE POLICY profiles_update ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY profiles_delete ON profiles FOR DELETE USING (auth.uid() = id);

-- SPARKS
CREATE POLICY sparks_read ON sparks FOR SELECT USING (
  deleted_at IS NULL AND (
    visibility = 'public' OR 
    (visibility = 'followers' AND EXISTS (SELECT 1 FROM follows WHERE follower_id = auth.uid() AND following_id = author_id)) OR
    author_id = auth.uid()
  )
);
CREATE POLICY sparks_insert ON sparks FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY sparks_update ON sparks FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY sparks_delete ON sparks FOR DELETE USING (auth.uid() = author_id);

-- LIKES
CREATE POLICY likes_insert ON likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY likes_delete ON likes FOR DELETE USING (auth.uid() = user_id);

-- COMMENTS
CREATE POLICY comments_read ON comments FOR SELECT USING (true);
CREATE POLICY comments_insert ON comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY comments_update ON comments FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY comments_delete ON comments FOR DELETE USING (auth.uid() = user_id);

-- FOLLOWS
CREATE POLICY follows_read ON follows FOR SELECT USING (true);
CREATE POLICY follows_insert ON follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY follows_delete ON follows FOR DELETE USING (auth.uid() = follower_id);

-- MESSAGES
CREATE POLICY messages_read ON messages FOR SELECT USING (
  EXISTS (SELECT 1 FROM conversations WHERE id = conversation_id AND auth.uid() = ANY(participant_ids))
);
CREATE POLICY messages_insert ON messages FOR INSERT WITH CHECK (
  auth.uid() = sender_id AND 
  EXISTS (SELECT 1 FROM conversations WHERE id = conversation_id AND auth.uid() = ANY(participant_ids))
);

-- NOTIFICATIONS
CREATE POLICY notifications_read ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY notifications_update ON notifications FOR UPDATE USING (auth.uid() = user_id);

-- PRODUCTS
CREATE POLICY products_read ON products FOR SELECT USING (status = 'published' OR auth.uid() = seller_id);
CREATE POLICY products_insert ON products FOR INSERT WITH CHECK (auth.uid() = seller_id);
CREATE POLICY products_update ON products FOR UPDATE USING (auth.uid() = seller_id);
CREATE POLICY products_delete ON products FOR DELETE USING (auth.uid() = seller_id);
