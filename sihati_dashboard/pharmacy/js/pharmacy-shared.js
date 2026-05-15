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
  return `<svg 
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 -4 28 28"
    width="24"
    height="16"
    fill="none"
    style="border-radius:3px;display:block"
  >
    <g clip-path="url(#clip0)">
      <rect
        x="0.25"
        y="0.25"
        width="27.5"
        height="19.5"
        rx="1.75"
        fill="white"
        stroke="#F5F5F5"
        stroke-width="0.5"
      />

      <mask
        id="mask0"
        style="mask-type:alpha"
        maskUnits="userSpaceOnUse"
        x="0"
        y="0"
        width="28"
        height="20"
      >
        <rect
          x="0.25"
          y="0.25"
          width="27.5"
          height="19.5"
          rx="1.75"
          fill="white"
          stroke="white"
          stroke-width="0.5"
        />
      </mask>

      <g mask="url(#mask0)">
        <path
          fill-rule="evenodd"
          clip-rule="evenodd"
          d="M0 20H14.6667V0H0V20Z"
          fill="#048345"
        />

        <path
          fill-rule="evenodd"
          clip-rule="evenodd"
          d="M17.3333 11.04L15.7659 12.1574L16.3442 10.3214L14.7971 9.17596L16.722 9.15863L17.3333 7.33334L17.9446 9.15863L19.8694 9.17596L18.3224 10.3214L18.9007 12.1574L17.3333 11.04Z"
          fill="#E81B42"
        />

        <path
          fill-rule="evenodd"
          clip-rule="evenodd"
          d="M17.68 14.3813C16.6519 15.3853 15.2702 16 13.7509 16C10.5748 16 8 13.3137 8 10C8 6.68629 10.5748 4 13.7509 4C15.2702 4 16.6519 4.61468 17.68 5.61867C16.9709 5.28113 16.1688 5.09091 15.3193 5.09091C12.4319 5.09091 10.0912 7.28878 10.0912 10C10.0912 12.7112 12.4319 14.9091 15.3193 14.9091C16.1688 14.9091 16.9709 14.7189 17.68 14.3813Z"
          fill="#E81B42"
        />
      </g>
    </g>

    <defs>
      <clipPath id="clip0">
        <rect width="28" height="20" rx="2" fill="white"/>
      </clipPath>
    </defs>
  </svg>`;
}
function phFlagFR() {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 3 2" width="24" height="16" style="border-radius:3px;display:block">
    <rect width="1" height="2" fill="#002395"/>
    <rect x="1" width="1" height="2" fill="#fff"/>
    <rect x="2" width="1" height="2" fill="#ed2939"/>
  </svg>`;
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

window.phCloseModal = phCloseModal;
window.phToggleTheme = phToggleTheme;
window.phToggleLanguage = phToggleLanguage;
