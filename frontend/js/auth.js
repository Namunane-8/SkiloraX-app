// ============================================================
// SKILORAX — Authentication (Supabase)
// ============================================================

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL;
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

export const Auth = {
  // ===== SIGN UP =====
  async signUp(email, password, userData) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: userData }
    });
    if (error) throw error;
    return data;
  },

  // ===== SIGN IN =====
  async signIn(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw error;
    return data;
  },

  // ===== SIGN OUT =====
  async signOut() {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  },

  // ===== RESET PASSWORD =====
  async resetPassword(email) {
    const { error } = await supabase.auth.resetPasswordForEmail(email);
    if (error) throw error;
  },

  // ===== GET CURRENT USER =====
  getCurrentUser() {
    return supabase.auth.getUser();
  },

  // ===== LISTEN TO AUTH STATE =====
  onAuthStateChange(callback) {
    return supabase.auth.onAuthStateChange(callback);
  }
};
