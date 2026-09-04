// ============================================================
// SKILORAX — Expert Marketplace
// ============================================================

import { supabase } from './auth.js';

export const Experts = {
  // ===== GET EXPERTS =====
  async getExperts(filters = {}) {
    let query = supabase
      .from('profiles')
      .select('*')
      .eq('is_expert', true)
      .eq('seller_status', 'active');

    if (filters.skill) {
      query = query.contains('skills', [filters.skill]);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data;
  },

  // ===== GET EXPERT BY ID =====
  async getExpert(expertId) {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', expertId)
      .single();
    if (error) throw error;
    return data;
  },

  // ===== BOOK SESSION =====
  async bookSession(bookingData) {
    const { data, error } = await supabase
      .from('bookings')
      .insert(bookingData)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // ===== GET USER BOOKINGS =====
  async getUserBookings(userId) {
    const { data, error } = await supabase
      .from('bookings')
      .select('*')
      .or(`user_id.eq.${userId},expert_id.eq.${userId}`)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data;
  }
};
