// ============================================================
// SKILORAX — Marketplace
// ============================================================

import { supabase } from './auth.js';

export const Marketplace = {
  // ===== GET PRODUCTS =====
  async getProducts(filters = {}) {
    let query = supabase
      .from('products')
      .select('*, seller:profiles(*)')
      .eq('status', 'published');

    if (filters.category) {
      query = query.eq('category', filters.category);
    }
    if (filters.search) {
      query = query.ilike('name', `%${filters.search}%`);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data;
  },

  // ===== CREATE PRODUCT =====
  async createProduct(productData) {
    const { data, error } = await supabase
      .from('products')
      .insert(productData)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // ===== UPDATE PRODUCT =====
  async updateProduct(productId, updates) {
    const { data, error } = await supabase
      .from('products')
      .update(updates)
      .eq('id', productId)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // ===== DELETE PRODUCT =====
  async deleteProduct(productId) {
    const { error } = await supabase
      .from('products')
      .delete()
      .eq('id', productId);
    if (error) throw error;
  },

  // ===== ADD REVIEW =====
  async addReview(productId, userId, rating, comment) {
    const { data, error } = await supabase
      .from('product_reviews')
      .insert({ product_id: productId, user_id: userId, rating, comment })
      .select()
      .single();
    if (error) throw error;
    return data;
  }
};
