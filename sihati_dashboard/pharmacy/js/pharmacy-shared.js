// pharmacy/js/pharmacy-shared.js
// ─── Page → translation key map ─────────────────────────────────────────────
const PH_PAGE_KEYS = {
  "pharmacy-dashboard.html": {
    title: "dashboard_title",
    sub: "dashboard_subtitle",
  },
  "inventory.html": { title: "inventory_title", sub: "inventory_subtitle" },
  "medications.html": {
    title: "medications_title",
    sub: "medications_subtitle",
  },
  "profile.html": { title: "profile_title", sub: "profile_subtitle" },
};

const PH_NAV_KEYS = {
  "pharmacy-dashboard.html": "dashboard_title",
  "inventory.html": "inventory_title",
  "medications.html": "medications_title",
  "profile.html": "profile_title",
};

// ─── Apply all static i18n ──────────────────────────────────────────────────
function phApplyAllI18n() {
  // Brand sub
  const brandSub = document.querySelector(".brand-sub");
  if (brandSub) brandSub.textContent = pt("brand_sub");

  // Nav section labels
  document.querySelectorAll(".nav-section").forEach((el) => {
    el.textContent = pt("nav_navigation");
  });

  // Nav link text
  document.querySelectorAll(".nav-link[data-file]").forEach((link) => {
    const key = PH_NAV_KEYS[link.dataset.file];
    if (key) {
      const span = link.querySelector("span:not(.nav-icon)");
      if (span) span.textContent = pt(key);
    }
  });

  // Page title & subtitle
  const file =
    window.location.pathname.split("/").pop() || "pharmacy-dashboard.html";
  const keys = PH_PAGE_KEYS[file] || PH_PAGE_KEYS["pharmacy-dashboard.html"];
  const titleEl = document.getElementById("pageTitle");
  const subtitleEl = document.getElementById("pageSubtitle");
  if (titleEl) titleEl.textContent = pt(keys.title);
  if (subtitleEl) subtitleEl.textContent = pt(keys.sub);

  // Sidebar loading placeholder
  const nameEl = document.getElementById("pharmacyName");
  if (
    nameEl &&
    (nameEl.textContent === "Chargement..." ||
      nameEl.textContent === "جار التحميل...")
  ) {
    nameEl.textContent = pt("loading_sidebar");
  }

  // Dir + lang
  document.documentElement.dir = phLang === "ar" ? "rtl" : "ltr";
  document.documentElement.lang = phLang;
}

// ─── Theme ──────────────────────────────────────────────────────────────────
function phInitTheme() {
  const theme = localStorage.getItem("sihati_theme") || "dark";
  document.documentElement.setAttribute("data-theme", theme);
  phUpdateThemeBtn(theme);
}
function phToggleTheme() {
  const cur = document.documentElement.getAttribute("data-theme") || "dark";
  const next = cur === "dark" ? "light" : "dark";
  document.documentElement.setAttribute("data-theme", next);
  localStorage.setItem("sihati_theme", next);
  phUpdateThemeBtn(next);
}
function phUpdateThemeBtn(theme) {
  const btn = document.getElementById("themeToggleBtn");
  if (!btn) return;
  btn.innerHTML =
    theme === "dark"
      ? '<i class="fas fa-sun"></i>'
      : '<i class="fas fa-moon"></i>';
  btn.title = theme === "dark" ? "Mode clair" : "Mode sombre";
}

// ─── Language ────────────────────────────────────────────────────────────────
function phToggleLanguage() {
  const next = phLang === "fr" ? "ar" : "fr";
  setPhLanguage(next);
  window.location.reload();
}
function phUpdateLangBtn() {
  const btn = document.getElementById("langToggleBtn");
  if (!btn) return;
  btn.innerHTML = phLang === "fr" ? phFlagDZ() : phFlagFR();
  btn.title = phLang === "fr" ? "العربية" : "Français";
}
function phFlagDZ() {
  return `<img src="../../assets/icons/dz-flag.svg" width="24" height="16" style="border-radius:3px;display:block" alt="DZ">`;
}
function phFlagFR() {
  return `<img src="../../assets/icons/fr-flag.svg" width="24" height="16" style="border-radius:3px;display:block" alt="FR">`;
}

// ─── Sidebar profile ─────────────────────────────────────────────────────────
let currentPharmacy = null;
async function phLoadSidebarProfile() {
  try {
    const res = await api.getCurrentPharmacy();
    if (!res.success) return null;
    currentPharmacy = res.data;
    const name = currentPharmacy.pharmacyName || "Pharmacie";
    const nameEl = document.getElementById("pharmacyName");
    const addrEl = document.getElementById("pharmacyAddress");
    const avEl = document.getElementById("pharmacyAvatar");
    if (nameEl) nameEl.textContent = name;
    if (addrEl) addrEl.textContent = currentPharmacy.address || "";
    if (avEl) avEl.textContent = name.slice(0, 2).toUpperCase();
    phUpdateDutyBadge();
    return currentPharmacy;
  } catch (e) {
    console.error("Pharmacy profile:", e);
    return null;
  }
}

function phUpdateDutyBadge() {
  const badge = document.getElementById("dutyBadge");
  if (!badge || !currentPharmacy) return;
  const isOn = currentPharmacy.isOnDutyTonight === true;
  badge.className = isOn ? "duty-pill active" : "duty-pill inactive";
  const span = badge.querySelector("span:last-child");
  if (span) span.textContent = isOn ? pt("on_duty") : pt("off_duty");
}

// ─── Sidebar & auth ──────────────────────────────────────────────────────────
function phSetupSidebar() {
  const file =
    window.location.pathname.split("/").pop() || "pharmacy-dashboard.html";
  document.querySelectorAll(".nav-link[data-file]").forEach((link) => {
    link.classList.toggle("active", link.dataset.file === file);
  });

  document.getElementById("logoutBtn")?.addEventListener("click", async () => {
    if (confirm(pt("logout_confirm"))) {
      await api.logout();
      api.clearPharmacyId();
      STORAGE.clear();
      window.location.href = "pharmacy-login.html";
    }
  });

  const mobileBtn = document.getElementById("mobileMenuBtn");
  const sidebar = document.getElementById("sidebar");
  if (mobileBtn && sidebar) {
    mobileBtn.addEventListener("click", () => {
      if (window.innerWidth <= 700) {
        const hidden = getComputedStyle(sidebar).display === "none";
        sidebar.style.display = hidden ? "flex" : "none";
      }
    });
    window.addEventListener("resize", () => {
      if (window.innerWidth > 700) sidebar.style.display = "";
    });
  }
}

async function phAuthCheck() {
  const token = STORAGE.getToken();
  const user = STORAGE.getUser();
  if (!token || !user || user.role !== "pharmacy") {
    window.location.href = "pharmacy-login.html";
    return false;
  }
  if (!api.getPharmacyId()) {
    try {
      const res = await api.getPharmacyByUserId(user.id);
      if (res.success && res.data && res.data.length > 0) {
        api.setPharmacyId(res.data[0].id);
      } else {
        window.location.href = "pharmacy-login.html";
        return false;
      }
    } catch {
      window.location.href = "pharmacy-login.html";
      return false;
    }
  }
  return true;
}

// ─── initPage ────────────────────────────────────────────────────────────────
async function phInitPage() {
  phInitTheme();
  phUpdateLangBtn();
  phApplyAllI18n();

  // Show Lottie loader while we auth+load
  const pc = document.getElementById('pageContent');
  if (pc) pc.innerHTML = `
    <div style="display:flex;flex-direction:column;align-items:center;justify-content:center;height:60vh;gap:16px;">
      <lottie-player src="../../assets/animations/sihati_dna.json" background="transparent" speed="1"
        style="width:140px;height:140px;" loop autoplay></lottie-player>
    </div>`;

  const ok = await phAuthCheck();
  if (!ok) return false;

  // Auth passed — reveal page with a smooth fade-in
  document.documentElement.style.transition = 'opacity 0.2s ease';
  document.documentElement.style.opacity = '0';
  document.documentElement.style.visibility = 'visible';
  requestAnimationFrame(() => { document.documentElement.style.opacity = '1'; });

  await phLoadSidebarProfile();
  phSetupSidebar();

  document.getElementById('themeToggleBtn')?.addEventListener('click', phToggleTheme);
  document.getElementById('langToggleBtn')?.addEventListener('click', phToggleLanguage);

  document.getElementById('modalCloseBtn')?.addEventListener('click', phCloseModal);
  document.getElementById('modalOverlay')?.addEventListener('click', (e) => {
    if (e.target === document.getElementById('modalOverlay')) phCloseModal();
  });

  return true;
}

// ─── Modal helpers ───────────────────────────────────────────────────────────
function phOpenModal(title, bodyHTML) {
  const modal = document.getElementById("modalOverlay");
  const titleEl = document.getElementById("modalTitle");
  const bodyEl = document.getElementById("modalBody");
  if (!modal || !titleEl || !bodyEl) return;
  titleEl.textContent = title;
  bodyEl.innerHTML = bodyHTML;
  modal.style.display = "flex";
}
function phCloseModal() {
  const modal = document.getElementById("modalOverlay");
  if (modal) modal.style.display = "none";
}

// ─── Toast ───────────────────────────────────────────────────────────────────
function phShowToast(message, type = "info") {
  const toast = document.createElement("div");
  toast.className = `toast ${type}`;
  const icon =
    type === "success"
      ? "fa-check-circle"
      : type === "error"
        ? "fa-exclamation-circle"
        : "fa-info-circle";
  toast.innerHTML = `<i class="fas ${icon}"></i> ${message}`;
  document.body.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = "0";
    toast.style.transform = "translateY(20px)";
    setTimeout(() => toast.remove(), 300);
  }, 3200);
}

// ─── Skeleton helpers ────────────────────────────────────────────────────────
function phSkeletonStats(n = 3) {
  return `<div class="stats-grid">${Array(n).fill('<div class="stat-card skeleton skeleton-stat"></div>').join("")}</div>`;
}
function phSkeletonList(n = 4) {
  return Array(n).fill('<div class="skeleton skeleton-row"></div>').join("");
}

function phEscapeHtml(str) {
  if (!str) return "";
  return str
    .replace(/[&<>]/g, (m) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;" })[m])
    .replace(/['"]/g, (m) => (m === "'" ? "&#39;" : "&quot;"));
}

function formatCurrency(amount) {
  if (!amount && amount !== 0) return '—';
  const value = typeof amount === 'string' ? parseFloat(amount) : amount;
  if (isNaN(value)) return '—';
  if (value === 0) return '0 DZD';
  return new Intl.NumberFormat('en-US').format(Math.round(value)) + ' DZD';
}

window.phCloseModal = phCloseModal;
window.phToggleTheme = phToggleTheme;
window.phToggleLanguage = phToggleLanguage;
