// ============================================================
// SKILORAX — SkiloraXBot AI Assistant
// ============================================================

export const Bot = {
  // ===== ANALYZE CONTENT =====
  analyzeContent(files, caption = '') {
    // Mock AI analysis
    return new Promise((resolve) => {
      setTimeout(() => {
        const suggestions = this.generateSuggestions(files);
        resolve(suggestions);
      }, 1200);
    });
  },

  // ===== GENERATE SUGGESTIONS =====
  generateSuggestions(files) {
    const names = files.map(f => f.name.toLowerCase());
    const allText = names.join(' ');

    let caption = '';
    let skills = [];
    let hashtags = [];
    let category = '';
    let audience = '';
    let opportunity = '';

    // Heuristic logic
    if (allText.includes('react') || allText.includes('web') || allText.includes('frontend')) {
      caption = "Just finished building this web project. Built with React and modern tools.";
      skills = ['React', 'Web Development', 'JavaScript'];
      hashtags = ['WebDev', 'ReactJS', 'Frontend'];
      category = 'Web Development';
      audience = 'Employers, Developers, Clients';
      opportunity = 'Potential freelance or collaboration opportunity.';
    } else if (allText.includes('design') || allText.includes('ui') || allText.includes('ux')) {
      caption = "New design concept for a mobile app. Focused on user experience.";
      skills = ['UI/UX Design', 'Figma', 'Prototyping'];
      hashtags = ['UIDesign', 'UX', 'DesignThinking'];
      category = 'Design';
      audience = 'Designers, Product Managers, Clients';
      opportunity = 'Potential freelance design work.';
    } else {
      caption = "Check out what I've been working on! Open to feedback and connections.";
      skills = ['Creativity', 'Problem Solving'];
      hashtags = ['WorkInProgress', 'BuildingInPublic'];
      category = 'General';
      audience = 'Professionals, Network';
      opportunity = 'Networking and collaboration.';
    }

    return {
      caption,
      skills,
      hashtags,
      category,
      audience,
      opportunity,
      improvedCaption: `✨ ${caption} (enhanced with more detail.)`
    };
  },

  // ===== SUGGEST HASHTAGS =====
  suggestHashtags(text) {
    // Simple hashtag extraction
    const words = text.split(' ');
    const hashtags = words
      .filter(w => w.length > 3)
      .slice(0, 5)
      .map(w => w.replace(/[^a-zA-Z]/g, ''));
    return hashtags;
  }
};
