// ============================================================
// SKILORAX — Chat / Messaging
// ============================================================

import { supabase } from './auth.js';

export const Chat = {
  // ===== GET CONVERSATIONS =====
  async getConversations(userId) {
    const { data, error } = await supabase
      .from('conversations')
      .select('*')
      .contains('participant_ids', [userId])
      .order('last_message_at', { ascending: false });
    if (error) throw error;
    return data;
  },

  // ===== GET MESSAGES =====
  async getMessages(conversationId, limit = 50) {
    const { data, error } = await supabase
      .from('messages')
      .select('*')
      .eq('conversation_id', conversationId)
      .order('created_at', { ascending: true })
      .limit(limit);
    if (error) throw error;
    return data;
  },

  // ===== SEND MESSAGE =====
  async sendMessage(conversationId, senderId, content) {
    const { data, error } = await supabase
      .from('messages')
      .insert({ conversation_id: conversationId, sender_id: senderId, content })
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // ===== CREATE CONVERSATION =====
  async createConversation(participants) {
    const { data, error } = await supabase
      .from('conversations')
      .insert({ participant_ids: participants })
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // ===== MARK AS READ =====
  async markAsRead(conversationId, userId) {
    const { error } = await supabase
      .from('messages')
      .update({ read_at: new Date().toISOString() })
      .eq('conversation_id', conversationId)
      .neq('sender_id', userId)
      .is('read_at', null);
    if (error) throw error;
  },

  // ===== SUBSCRIBE TO MESSAGES =====
  subscribeToMessages(conversationId, callback) {
    return supabase
      .channel(`messages:${conversationId}`)
      .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'messages',
        filter: `conversation_id=eq.${conversationId}`
      }, callback)
      .subscribe();
  }
};
