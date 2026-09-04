// ============================================================
// SKILORAX — Social Engine (Sparks)
// ============================================================

import { supabase } from './auth.js';

export const Social = {
  // ===== CREATE SPARK =====
  async createSpark(data) {
    const { data: spark, error } = await supabase
      .from('sparks')
      .insert(data)
      .select()
      .single();
    if (error) throw error;
    return spark;
  },

  // ===== GET FEED =====
  async getFeed(userId, limit = 20, cursor = null) {
    let query = supabase
      .from('sparks')
      .select('*, author:profiles(*)')
      .eq('visibility', 'public')
      .is('deleted_at', null)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (cursor) {
      query = query.lt('created_at', cursor);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data;
  },

  // ===== LIKE SPARK =====
  async likeSpark(sparkId, userId) {
    const { error } = await supabase
      .from('likes')
      .insert({ spark_id: sparkId, user_id: userId });
    if (error) throw error;
  },

  // ===== UNLIKE SPARK =====
  async unlikeSpark(sparkId, userId) {
    const { error } = await supabase
      .from('likes')
      .delete()
      .eq('spark_id', sparkId)
      .eq('user_id', userId);
    if (error) throw error;
  },

  // ===== COMMENT ON SPARK =====
  async addComment(sparkId, userId, content, parentId = null) {
    const { data, error } = await supabase
      .from('comments')
      .insert({ spark_id: sparkId, user_id: userId, content, parent_comment_id: parentId })
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // ===== RE-SPARK =====
  async reSpark(sparkId, userId, quoteText = null) {
    const { data, error } = await supabase
      .from('reshares')
      .insert({ original_spark_id: sparkId, user_id: userId, quote_text: quoteText })
      .select()
      .single();
    if (error) throw error;
    return data;
  }
};
