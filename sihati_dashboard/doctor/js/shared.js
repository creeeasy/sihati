// ─── Page → translation key map ──────────────────────────────────────────────
const PAGE_KEYS = {
  'doctor-dashboard.html': { title: 'dashboard_title',    sub: 'dashboard_subtitle' },
  'patients.html':         { title: 'patients_title',     sub: 'patients_subtitle' },
  'appointments.html':     { title: 'appointments_title', sub: 'appointments_subtitle' },
  'availability.html':     { title: 'availability_title', sub: 'availability_subtitle' },
  'reviews.html':          { title: 'reviews_title',      sub: 'reviews_subtitle' },
  'profile.html':          { title: 'profile_title',      sub: 'profile_subtitle' },
  'waiting-queue.html':    { title: 'waiting_queue_title', sub: 'waiting_queue_subtitle' },
};

// Nav link: data-file → translation key
const NAV_KEYS = {
  'doctor-dashboard.html': 'dashboard_title',
  'waiting-queue.html':    'waiting_queue_title',
  'appointments.html':     'appointments_title',
  'patients.html':         'patients_title',
  'availability.html':     'availability_title',
  'reviews.html':          'reviews_title',
  'profile.html':          'profile_title',
};

// ─── Apply ALL static i18n text (sidebar + topbar) ────────────────────────────
function applyAllI18n() {
  // 1. Brand sub ("Espace Médecin" / "فضاء الطبيب")
  const brandSub = document.querySelector('.brand-sub');
  if (brandSub) brandSub.textContent = t('brand_sub');

  // 2. Nav section labels (Principal / Gestion / Compte)
  const sections = document.querySelectorAll('.nav-section');
  const sectionKeys = ['nav_principal', 'nav_gestion', 'nav_compte'];
  sections.forEach((el, i) => { if (sectionKeys[i]) el.textContent = t(sectionKeys[i]); });

  // 3. Nav link text spans
  document.querySelectorAll('.nav-link[data-file]').forEach(link => {
    const key = NAV_KEYS[link.dataset.file];
    if (key) {
      const span = link.querySelector('span:not(.nav-icon)');
      if (span) span.textContent = t(key);
    }
  });

  // 4. Page title & subtitle in topbar
  const file = window.location.pathname.split('/').pop() || 'doctor-dashboard.html';
  const keys = PAGE_KEYS[file] || PAGE_KEYS['doctor-dashboard.html'];
  const titleEl    = document.getElementById('pageTitle');
  const subtitleEl = document.getElementById('pageSubtitle');
  if (titleEl)    titleEl.textContent    = t(keys.title);
  if (subtitleEl) subtitleEl.textContent = t(keys.sub);

  // 5. Sidebar doctor name loading placeholder
  const nameEl = document.getElementById('doctorName');
  if (nameEl && (nameEl.textContent === 'Chargement...' || nameEl.textContent === 'جار التحميل...')) {
    nameEl.textContent = t('loading_sidebar');
  }

  // 6. Sidebar doctor specialty placeholder
  const specEl = document.getElementById('doctorSpecialty');
  if (specEl && (specEl.textContent === 'Medecin' || specEl.textContent === 'طبيب')) {
    specEl.textContent = t('doctor');
  }

  // 7. Logout button title
  const logoutBtn = document.getElementById('logoutBtn');
  if (logoutBtn) logoutBtn.title = t('logout_confirm').replace(' ?', '').replace('؟', '').trim();

  // 8. Dir + lang on html element
  document.documentElement.dir  = currentLang === 'ar' ? 'rtl' : 'ltr';
  document.documentElement.lang = currentLang;
}

// ─── Theme ───────────────────────────────────────────────────────────────────
function initTheme() {
  const theme = localStorage.getItem('sihati_theme') || 'dark';
  document.documentElement.setAttribute('data-theme', theme);
  _updateThemeBtn(theme);
}
function toggleTheme() {
  const cur  = document.documentElement.getAttribute('data-theme') || 'dark';
  const next = cur === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('sihati_theme', next);
  _updateThemeBtn(next);
}
function _updateThemeBtn(theme) {
  const btn = document.getElementById('themeToggleBtn');
  if (!btn) return;
  btn.innerHTML = theme === 'dark' ? '<i class="fas fa-sun"></i>' : '<i class="fas fa-moon"></i>';
  btn.title     = theme === 'dark' ? t('theme_light') || 'Mode clair' : t('theme_dark') || 'Mode sombre';
}

// ─── Language ────────────────────────────────────────────────────────────────
function toggleLanguage() {
  const next = currentLang === 'fr' ? 'ar' : 'fr';
  setLanguage(next);
  window.location.reload();
}
function _updateLangBtn() {
  const btn = document.getElementById('langToggleBtn');
  if (!btn) return;
  btn.innerHTML = currentLang === 'fr' ? _flagDZ() : _flagFR();
  btn.title     = currentLang === 'fr' ? 'العربية' : 'Français';
}
function _flagDZ() {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 3 2" width="24" height="16" style="border-radius:3px;display:block">
    <rect width="1.5" height="2" fill="#006233"/>
    <rect x="1.5" width="1.5" height="2" fill="#fff"/>
    <circle cx="1.65" cy="1" r="0.42" fill="#d21034"/>
    <circle cx="1.73" cy="1" r="0.42" fill="#fff"/>
    <polygon points="1.73,0.62 1.78,0.77 1.93,0.77 1.81,0.86 1.86,1.01 1.73,0.92 1.6,1.01 1.65,0.86 1.53,0.77 1.68,0.77" fill="#d21034"/>
  </svg>`;
}
function _flagFR() {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 3 2" width="24" height="16" style="border-radius:3px;display:block">
    <rect width="1" height="2" fill="#002395"/>
    <rect x="1" width="1" height="2" fill="#fff"/>
    <rect x="2" width="1" height="2" fill="#ed2939"/>
  </svg>`;
}

// ─── Sidebar profile ──────────────────────────────────────────────────────────
async function loadSidebarProfile() {
  try {
    const res = await api.getCurrentDoctor();
    if (!res.success) return null;
    const doc  = res.data;
    const name = doc.doctorName || 'Dr.';
    const nameEl = document.getElementById('doctorName');
    const specEl = document.getElementById('doctorSpecialty');
    const avEl   = document.getElementById('doctorAvatar');
    if (nameEl) nameEl.textContent = name;
    if (specEl) specEl.textContent = doc.specialty?.nameFr || doc.specialty?.name || t('doctor');
    if (avEl) {
      const parts = name.split(' ');
      avEl.textContent = ((parts[0]?.[0] || '') + (parts[1]?.[0] || '')).toUpperCase() || 'DR';
    }
    return doc;
  } catch (e) { console.error('Profile:', e); return null; }
}

// ─── Sidebar setup ────────────────────────────────────────────────────────────
function setupSidebar() {
  // Mark active link by current filename
  const file = window.location.pathname.split('/').pop() || 'doctor-dashboard.html';
  document.querySelectorAll('.nav-link[data-file]').forEach(link => {
    link.classList.toggle('active', link.dataset.file === file);
  });

  // Logout
  document.getElementById('logoutBtn')?.addEventListener('click', async () => {
    if (confirm(t('logout_confirm'))) {
      await api.logout();
      api.clearDoctorId();
      STORAGE.clear();
      window.location.href = 'doctor-login.html';
    }
  });

  // Mobile sidebar
  const mobileBtn = document.getElementById('mobileMenuBtn');
  const sidebar   = document.getElementById('sidebar');
  if (mobileBtn && sidebar) {
    mobileBtn.addEventListener('click', () => {
      if (window.innerWidth <= 700) {
        const hidden = getComputedStyle(sidebar).display === 'none';
        sidebar.style.display = hidden ? 'flex' : 'none';
      }
    });
    window.addEventListener('resize', () => {
      if (window.innerWidth > 700) sidebar.style.display = '';
    });
  }
}

// ─── Auth check ───────────────────────────────────────────────────────────────
async function authCheck() {
  const token = STORAGE.getToken();
  const user  = STORAGE.getUser();
  if (!token || !user || user.role !== 'doctor') {
    window.location.href = 'doctor-login.html'; return false;
  }
  if (!api.getDoctorId()) {
    try {
      const res = await api.getDoctorByUserId(user.id);
      if (res.success && res.data?.id) { api.setDoctorId(res.data.id); }
      else { window.location.href = 'doctor-login.html'; return false; }
    } catch { window.location.href = 'doctor-login.html'; return false; }
  }
  return true;
}

// ─── initPage: called from every page's DOMContentLoaded ─────────────────────
async function initPage() {
  initTheme();
  _updateLangBtn();
  applyAllI18n();

  // Show Lottie loader while we auth+load
  const pc = document.getElementById('pageContent');
  if (pc) pc.innerHTML = `
    <div style="display:flex;flex-direction:column;align-items:center;justify-content:center;height:60vh;gap:16px;">
      <lottie-player src="../../assets/animations/sihati_dna.json" background="transparent" speed="1"
        style="width:140px;height:140px;" loop autoplay></lottie-player>
    </div>`;

  const ok = await authCheck();
  if (!ok) return false;

  // Auth passed — reveal page with a smooth fade-in
  document.documentElement.style.transition = 'opacity 0.2s ease';
  document.documentElement.style.opacity = '0';
  document.documentElement.style.visibility = 'visible';
  requestAnimationFrame(() => { document.documentElement.style.opacity = '1'; });

  await loadSidebarProfile();
  setupSidebar();

  // Topbar date in current locale
  const dateEl = document.getElementById('dateDisplay');
  if (dateEl) {
    const locale = currentLang === 'ar' ? 'ar-DZ' : 'fr-FR';
    dateEl.textContent = new Date().toLocaleDateString(locale, {
      weekday: 'long', day: 'numeric', month: 'long'
    });
  }

  document.getElementById('themeToggleBtn')?.addEventListener('click', toggleTheme);
  document.getElementById('langToggleBtn')?.addEventListener('click', toggleLanguage);

  // Modal close
  document.getElementById('modalCloseBtn')?.addEventListener('click', closeModal);
  document.getElementById('modalOverlay')?.addEventListener('click', e => {
    if (e.target === document.getElementById('modalOverlay')) closeModal();
  });

  return true;
}

window.toggleTheme    = toggleTheme;
window.toggleLanguage = toggleLanguage;
