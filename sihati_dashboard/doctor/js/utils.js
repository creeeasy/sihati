function formatCurrency(amount) {
  if (!amount && amount !== 0) return '—';
  const value = typeof amount === 'string' ? parseFloat(amount) : amount;
  if (isNaN(value)) return '—';
  if (value === 0) return '0 DZD';
  return new Intl.NumberFormat('en-US').format(Math.round(value)) + ' DZD';
}

function formatDate(dateString) {
  const locale = (typeof currentLang !== 'undefined' && currentLang === 'ar') ? 'ar-DZ' : 'fr-FR';
  return new Date(dateString).toLocaleDateString(locale, { day: 'numeric', month: 'long', year: 'numeric' });
}

function formatDateTime(dateString) {
  const locale = (typeof currentLang !== 'undefined' && currentLang === 'ar') ? 'ar-DZ' : 'fr-FR';
  return new Date(dateString).toLocaleDateString(locale, { day: 'numeric', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

function showPageLoading() {
  const content = document.getElementById('pageContent');
  if (content) {
    const txt = (typeof t === 'function') ? t('loading_text') : 'Chargement...';
    content.innerHTML = `<div class="loading"><div class="spinner"></div><p>${txt}</p></div>`;
  }
}

function hidePageLoading() {
  document.querySelector('#pageContent .loading')?.remove();
}

function showToast(message, type = 'info') {
  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  const icon = type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle';
  toast.innerHTML = `<i class="fas ${icon}"></i> ${message}`;
  document.body.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateY(20px)';
    setTimeout(() => toast.remove(), 300);
  }, 3200);
}

function escapeHtml(str) {
  if (!str) return '';
  return str
    .replace(/[&<>]/g, m => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' }[m]))
    .replace(/['"]/g, m => m === "'" ? '&#39;' : '&quot;');
}

// Skeleton helpers
function skeletonStats(count = 6) {
  return `<div class="stats-grid">${Array(count).fill('<div class="stat-card skeleton skeleton-stat"></div>').join('')}</div>`;
}
function skeletonList(count = 4) {
  return Array(count).fill('<div class="skeleton skeleton-row"></div>').join('');
}
