let currentPharmacy = null;
let currentPage = "dashboard";

document.addEventListener("DOMContentLoaded", async () => {
  const authenticated = await pharmacyAuth.checkAuth();
  if (!authenticated) return;
  await loadPharmacyProfile();
  setupNav();
  setupModal();
  await loadDashboard();
});

function setupNav() {
  document.querySelectorAll(".nav-link[data-page]").forEach((link) => {
    link.addEventListener("click", async (e) => {
      e.preventDefault();
      document
        .querySelectorAll(".nav-link")
        .forEach((l) => l.classList.remove("active"));
      link.classList.add("active");
      await navigateTo(link.dataset.page);
    });
  });
  document.getElementById("logoutBtn").addEventListener("click", async () => {
    if (confirm("Voulez-vous vous deconnecter ?")) {
      await pharmacyAuth.logout();
    }
  });
  const mobileBtn = document.getElementById("mobileMenuBtn");
  const sidebar = document.getElementById("sidebar");
  if (mobileBtn && sidebar) {
    mobileBtn.addEventListener("click", function () {
      if (window.innerWidth <= 700) {
        if (
          sidebar.style.display === "none" ||
          getComputedStyle(sidebar).display === "none"
        ) {
          sidebar.style.display = "flex";
        } else {
          sidebar.style.display = "none";
        }
      }
    });
    window.addEventListener("resize", function () {
      if (window.innerWidth > 700) {
        sidebar.style.display = "";
      }
    });
  }
}

async function navigateTo(page) {
  currentPage = page;
  const titles = {
    dashboard: ["Tableau de bord", "Gerez votre pharmacie"],
    inventory: ["Stock", "Gerez vos medicaments"],
    medications: ["Medicaments", "Recherchez et consultez les medicaments"],
    profile: ["Ma pharmacie", "Modifiez vos informations"],
  };
  const [title, subtitle] = titles[page] || ["-", ""];
  document.getElementById("pageTitle").textContent = title;
  document.getElementById("pageSubtitle").textContent = subtitle;
  pageLoading();
  try {
    if (page === "dashboard") await loadDashboard();
    else if (page === "inventory") await loadInventory();
    else if (page === "medications") await loadMedicationsPage();
    else if (page === "profile") await loadProfile();
  } catch (e) {
    pageError(e.message);
  }
}

function pageLoading() {
  document.getElementById("pageContent").innerHTML =
    `<div class="loading"><div class="spinner"></div><p>Chargement en cours...</p></div>`;
}

function pageError(msg) {
  document.getElementById("pageContent").innerHTML =
    `<div class="empty-state"><i class="fas fa-exclamation-circle"></i><p>${msg}</p></div>`;
}

function setContent(html) {
  document.getElementById("pageContent").innerHTML = html;
}

function updateDutyBadge() {
  const badge = document.getElementById("dutyBadge");
  if (!badge || !currentPharmacy) return;
  const isActive = currentPharmacy.isOnDutyTonight === true;
  badge.className = isActive ? "duty-pill active" : "duty-pill inactive";
  const span = badge.querySelector("span:last-child");
  if (span) span.textContent = isActive ? "De garde" : "Hors garde";
}

async function loadPharmacyProfile() {
  try {
    const res = await api.getCurrentPharmacy();
    if (!res.success) return;
    currentPharmacy = res.data;
    const name = currentPharmacy.pharmacyName || "Pharmacie";
    const initials = name.slice(0, 2).toUpperCase();
    const avatarEl = document.getElementById("pharmacyAvatar");
    const nameEl = document.getElementById("pharmacyName");
    const addressEl = document.getElementById("pharmacyAddress");
    if (avatarEl) avatarEl.textContent = initials;
    if (nameEl) nameEl.textContent = name;
    if (addressEl) addressEl.textContent = currentPharmacy.address || "";
    updateDutyBadge();
  } catch (e) {
    console.error(e);
  }
}

async function loadDashboard() {
  const stockList = await loadAllStock();
  const stockCount = stockList.length;
  const lowStockCount = stockList.filter(
    (s) => s.quantity > 0 && s.quantity < 10,
  ).length;
  const outOfStockCount = stockList.filter(
    (s) => !s.inStock || s.quantity === 0,
  ).length;

  setContent(`
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon primary"><i class="fas fa-pills"></i></div>
        <div class="stat-body">
          <div class="stat-value">${stockCount}</div>
          <div class="stat-label">Medicaments en stock</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon warning"><i class="fas fa-exclamation-triangle"></i></div>
        <div class="stat-body">
          <div class="stat-value">${lowStockCount}</div>
          <div class="stat-label">Stock faible</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon danger"><i class="fas fa-ban"></i></div>
        <div class="stat-body">
          <div class="stat-value">${outOfStockCount}</div>
          <div class="stat-label">Rupture de stock</div>
        </div>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        <h3>Rechercher un medicament</h3>
      </div>
      <div class="card-body">
        <div class="search-bar">
          <i class="fas fa-search"></i>
          <input type="text" id="medSearchInput" placeholder="Nom du medicament..." autocomplete="off">
          <button id="scanBarcodeBtn" class="btn-icon"><i class="fas fa-camera"></i></button>
        </div>
        <div id="searchResults" style="margin-top: 16px;"></div>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        <h3>Stock recent</h3>
        <button id="refreshStockBtn" class="btn-sm"><i class="fas fa-sync-alt"></i> Rafraichir</button>
      </div>
      <div class="card-body">
        <div class="stock-table-container">
          <table class="stock-table">
            <thead><tr><th>Medicament</th><th>Quantite</th><th>Prix</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody id="stockTableBody">
              ${stockList
                .slice(0, 10)
                .map((item) => renderStockRow(item))
                .join("")}
            </tbody>
          </table>
          ${stockList.length > 10 ? `<div class="view-all"><button id="viewAllStockBtn" class="link-more">Voir tout le stock →</button></div>` : ""}
        </div>
      </div>
    </div>

    <div class="card">
      <div class="card-header"><h3>Pharmacie de garde</h3></div>
      <div class="card-body">
        <div class="duty-toggle">
          <div class="duty-status">
            Status actuel :
            <span class="duty-badge-inline ${currentPharmacy?.isOnDutyTonight ? "active" : "inactive"}">
              ${currentPharmacy?.isOnDutyTonight ? "De garde" : "Hors garde"}
            </span>
          </div>
          <button id="toggleDutyBtn" class="${currentPharmacy?.isOnDutyTonight ? "btn-danger" : "btn-success"}">
            <i class="fas ${currentPharmacy?.isOnDutyTonight ? "fa-power-off" : "fa-bell"}"></i>
            ${currentPharmacy?.isOnDutyTonight ? "Desactiver la garde" : "Activer la garde"}
          </button>
        </div>
      </div>
    </div>
  `);

  let timer;
  const searchInput = document.getElementById("medSearchInput");
  if (searchInput) {
    searchInput.addEventListener("input", (e) => {
      clearTimeout(timer);
      timer = setTimeout(() => searchMedications(e.target.value), 500);
    });
  }
  const scanBtn = document.getElementById("scanBarcodeBtn");
  if (scanBtn) scanBtn.addEventListener("click", () => scanBarcode());
  const refreshBtn = document.getElementById("refreshStockBtn");
  if (refreshBtn) refreshBtn.addEventListener("click", () => loadDashboard());
  const viewAllBtn = document.getElementById("viewAllStockBtn");
  if (viewAllBtn)
    viewAllBtn.addEventListener("click", () => navigateTo("inventory"));
  const toggleBtn = document.getElementById("toggleDutyBtn");
  if (toggleBtn) toggleBtn.addEventListener("click", () => toggleDuty());
}

function renderStockRow(item) {
  const statusClass =
    !item.inStock || item.quantity === 0
      ? "out-of-stock"
      : item.quantity < 10
        ? "low-stock"
        : "in-stock";
  const statusText =
    !item.inStock || item.quantity === 0
      ? "Rupture"
      : item.quantity < 10
        ? "Stock faible"
        : "Disponible";
  const medName =
    item.medication?.name ||
    item.medication_name ||
    item.medicationName ||
    "Medicament";
  const medId = item.medication_id || item.medicationId;
  return `
    <tr>
      <td><strong>${medName}</strong></td>
      <td class="quantity-cell">${item.quantity || 0}</td>
      <td>${item.price ? item.price + " DA" : "-"}</td>
      <td><span class="stock-badge ${statusClass}">${statusText}</span></td>
      <td><button class="btn-edit-stock" data-medication-id="${medId}" data-medication-name="${medName}"><i class="fas fa-edit"></i></button></td>
    </tr>
  `;
}

async function loadAllStock() {
  try {
    const pharmacyId = api.getPharmacyId();
    if (!pharmacyId) return [];
    const response = await api.request(`/pharmacies/${pharmacyId}/stock`);
    if (response.success && response.data) {
      return response.data;
    }
    return [];
  } catch (error) {
    console.warn("Endpoint stock non disponible, utilisation donnees de test");
    return [
      {
        medication_id: "1",
        medication_name: "Doliprane 500mg",
        quantity: 25,
        price: 250,
        inStock: true,
      },
      {
        medication_id: "2",
        medication_name: "Amoxicilline 500mg",
        quantity: 5,
        price: 480,
        inStock: true,
      },
      {
        medication_id: "3",
        medication_name: "Spasfon 80mg",
        quantity: 0,
        price: 320,
        inStock: false,
      },
      {
        medication_id: "4",
        medication_name: "Ibuprofene 400mg",
        quantity: 12,
        price: 400,
        inStock: true,
      },
      {
        medication_id: "5",
        medication_name: "Ventoline 100mcg",
        quantity: 8,
        price: 1800,
        inStock: true,
      },
    ];
  }
}

async function loadInventory() {
  const stockList = await loadAllStock();
  setContent(`
    <div class="card">
      <div class="card-header">
        <h3>Gestion du stock</h3>
        <div class="header-actions">
          <input type="text" id="stockSearchInput" placeholder="Filtrer..." class="search-small">
        </div>
      </div>
      <div class="card-body">
        <div class="stock-table-container">
          <table class="stock-table">
            <thead><tr><th>Medicament</th><th>Quantite</th><th>Prix</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody id="inventoryTableBody">
              ${stockList.map((item) => renderStockRow(item)).join("")}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  `);
  const searchInput = document.getElementById("stockSearchInput");
  if (searchInput) {
    searchInput.addEventListener("input", (e) => {
      const term = e.target.value.toLowerCase();
      document.querySelectorAll("#inventoryTableBody tr").forEach((row) => {
        row.style.display = row.textContent.toLowerCase().includes(term)
          ? ""
          : "none";
      });
    });
  }
  bindEditStockButtons();
}

function bindEditStockButtons() {
  document.querySelectorAll(".btn-edit-stock").forEach((btn) => {
    btn.addEventListener("click", () => {
      showEditStockModal(btn.dataset.medicationId, btn.dataset.medicationName);
    });
  });
}

async function loadMedicationsPage() {
  setContent(`
    <div class="card">
      <div class="card-header"><h3>Recherche de medicaments</h3></div>
      <div class="card-body">
        <div class="search-bar large">
          <i class="fas fa-search"></i>
          <input type="text" id="globalMedSearch" placeholder="Rechercher un medicament (nom, DCI, fabricant)...">
          <button id="globalScanBtn" class="btn-icon"><i class="fas fa-camera"></i></button>
        </div>
        <div id="globalSearchResults" style="margin-top: 24px;"></div>
      </div>
    </div>
    <div class="card">
      <div class="card-header"><h3>Medicaments populaires</h3></div>
      <div class="card-body">
        <div id="popularMedications" class="med-grid"><div class="loading">Chargement...</div></div>
      </div>
    </div>
  `);
  try {
    const popularRes = await api.getPopularMedications(8);
    if (popularRes.success && popularRes.data) {
      const container = document.getElementById("popularMedications");
      if (container) {
        container.innerHTML = popularRes.data
          .map(
            (med) => `
          <div class="med-card" onclick="showMedicationDetails('${med.id}')">
            <i class="fas fa-pills med-icon"></i>
            <div class="med-name">${med.name}</div>
            <div class="med-dosage">${med.dosage || ""}</div>
            ${med.requiresPrescription ? '<span class="prescription-badge">Prescription</span>' : ""}
          </div>
        `,
          )
          .join("");
      }
    }
  } catch (e) {
    console.error(e);
  }
  let timer;
  const searchInput = document.getElementById("globalMedSearch");
  if (searchInput) {
    searchInput.addEventListener("input", (e) => {
      clearTimeout(timer);
      timer = setTimeout(() => searchGlobalMedications(e.target.value), 500);
    });
  }
  const scanBtn = document.getElementById("globalScanBtn");
  if (scanBtn) scanBtn.addEventListener("click", () => scanBarcodeGlobal());
}

async function searchGlobalMedications(query) {
  if (query.length < 2) {
    const resultsDiv = document.getElementById("globalSearchResults");
    if (resultsDiv) resultsDiv.innerHTML = "";
    return;
  }
  try {
    const res = await api.searchMedications(query);
    const resultsDiv = document.getElementById("globalSearchResults");
    if (!resultsDiv) return;
    if (res.success && res.data && res.data.length) {
      resultsDiv.innerHTML = `
        <h4>Resultats (${res.data.length})</h4>
        <div class="med-grid">
          ${res.data
            .map(
              (med) => `
            <div class="med-card" onclick="showMedicationDetails('${med.id}')">
              <i class="fas fa-capsules med-icon"></i>
              <div class="med-name">${med.name}</div>
              <div class="med-dosage">${med.dosage || ""}</div>
              ${med.requiresPrescription ? '<span class="prescription-badge">Prescription</span>' : ""}
              <button class="btn-view-stock" data-med-id="${med.id}" onclick="event.stopPropagation(); showStockForMedication('${med.id}')">Voir stock</button>
            </div>
          `,
            )
            .join("")}
        </div>
      `;
    } else {
      resultsDiv.innerHTML = `<div class="empty-state">Aucun resultat</div>`;
    }
  } catch (e) {
    const resultsDiv = document.getElementById("globalSearchResults");
    if (resultsDiv)
      resultsDiv.innerHTML = `<div class="error-state">Erreur de recherche</div>`;
  }
}

async function scanBarcodeGlobal() {
  const barcode = prompt("Scannez le code-barres ou entrez le numero:");
  if (barcode) {
    try {
      const res = await api.searchByBarcode(barcode);
      if (res.success && res.data) {
        showMedicationDetails(res.data.id);
      } else {
        showToast("Medicament non trouve", "error");
      }
    } catch (e) {
      showToast(e.message, "error");
    }
  }
}

async function loadProfile() {
  const pharmacy = currentPharmacy;
  setContent(`
    <div class="profile-card">
      <div class="profile-header">
        <div class="profile-avatar">${(pharmacy?.pharmacyName || "P").slice(0, 2).toUpperCase()}</div>
        <div class="profile-info">
          <h2>${pharmacy?.pharmacyName || ""}</h2>
          <p class="verified-badge ${pharmacy?.isVerified ? "verified" : "pending"}">
            ${pharmacy?.isVerified ? "Compte verifie" : "En attente de verification"}
          </p>
        </div>
      </div>
      <div id="profileAlert"></div>
      <div class="form-grid">
        <div class="form-group"><label>Nom de la pharmacie</label><input id="p_name" class="form-control" value="${escapeHtml(pharmacy?.pharmacyName || "")}"></div>
        <div class="form-group"><label>Telephone</label><input id="p_phone" class="form-control" value="${escapeHtml(pharmacy?.phone || "")}"></div>
        <div class="form-group"><label>WhatsApp</label><input id="p_whatsapp" class="form-control" value="${escapeHtml(pharmacy?.whatsappNumber || "")}"></div>
        <div class="form-group"><label>Email</label><input id="p_email" class="form-control" value="${escapeHtml(pharmacy?.email || "")}"></div>
        <div class="form-group"><label>Wilaya</label><input id="p_wilaya" class="form-control" value="${escapeHtml(pharmacy?.wilaya || "")}"></div>
        <div class="form-group"><label>Commune</label><input id="p_commune" class="form-control" value="${escapeHtml(pharmacy?.commune || "")}"></div>
        <div class="form-group full-width"><label>Adresse</label><input id="p_address" class="form-control" value="${escapeHtml(pharmacy?.address || "")}"></div>
      </div>
      <button id="saveProfileBtn" class="btn-save">Enregistrer les modifications</button>
    </div>
  `);
  const saveBtn = document.getElementById("saveProfileBtn");
  if (saveBtn) {
    saveBtn.addEventListener("click", async () => {
      const alertEl = document.getElementById("profileAlert");
      const data = {
        pharmacyName: document.getElementById("p_name").value.trim(),
        phone: document.getElementById("p_phone").value.trim(),
        whatsappNumber: document.getElementById("p_whatsapp").value.trim(),
        email: document.getElementById("p_email").value.trim(),
        wilaya: document.getElementById("p_wilaya").value.trim(),
        commune: document.getElementById("p_commune").value.trim(),
        address: document.getElementById("p_address").value.trim(),
      };
      if (!data.pharmacyName || !data.phone || !data.address) {
        if (alertEl)
          alertEl.innerHTML = `<div class="alert-error">Champs obligatoires manquants</div>`;
        return;
      }
      try {
        await api.updatePharmacyProfile(data);
        if (alertEl)
          alertEl.innerHTML = `<div class="alert-success">Profil mis a jour</div>`;
        setTimeout(() => {
          if (alertEl) alertEl.innerHTML = "";
        }, 3000);
        await loadPharmacyProfile();
      } catch (e) {
        if (alertEl)
          alertEl.innerHTML = `<div class="alert-error">${e.message}</div>`;
      }
    });
  }
}

async function showMedicationDetails(medicationId) {
  try {
    const res = await api.getMedicationById(medicationId);
    const med = res.data;
    openModal(
      med.name,
      `
      <div class="med-details">
        <p><strong>Forme:</strong> ${med.form || "-"}</p>
        <p><strong>Dosage:</strong> ${med.dosage || "-"}</p>
        <p><strong>Fabricant:</strong> ${med.manufacturer || "-"}</p>
        <p><strong>Prescription requise:</strong> ${med.requiresPrescription ? "Oui" : "Non"}</p>
        ${med.indications ? `<p><strong>Indications:</strong> ${med.indications}</p>` : ""}
        ${med.contraindications ? `<p><strong>Contre-indications:</strong> ${med.contraindications}</p>` : ""}
        ${med.sideEffects ? `<p><strong>Effets secondaires:</strong> ${med.sideEffects}</p>` : ""}
      </div>
      <div class="modal-actions">
        <button class="btn-primary" onclick="showEditStockModal('${med.id}', '${escapeHtml(med.name)}')">Mettre a jour le stock</button>
        <button class="btn-cancel-modal" onclick="showStockForMedication('${med.id}')">Voir pharmacies avec stock</button>
      </div>
    `,
    );
  } catch (e) {
    showToast(e.message, "error");
  }
}

async function showStockForMedication(medicationId) {
  try {
    const res = await api.getPharmaciesWithStock(medicationId);
    openModal(
      "Pharmacies avec stock",
      `
      <div id="pharmaciesStockList">
        ${
          res.data && res.data.length
            ? res.data
                .map(
                  (item) => `
          <div style="border-bottom: 1px solid var(--border); padding: 16px;">
            <div style="display: flex; justify-content: space-between;">
              <div>
                <strong>${item.pharmacy.pharmacyName}</strong>
                ${item.pharmacy.isOnDutyTonight ? '<span style="background: var(--green-dim); color: var(--green); padding: 2px 8px; border-radius: 12px; font-size: 11px; margin-left: 8px;">De garde</span>' : ""}
              </div>
              <div>
                <span style="font-weight: 600; color: var(--teal);">${item.price} DA</span>
                <span style="font-size: 12px; margin-left: 8px;">Stock: ${item.quantity}</span>
              </div>
            </div>
            <div style="margin-top: 8px; color: var(--text-muted); font-size: 13px;">
              ${item.pharmacy.address}, ${item.pharmacy.wilaya}<br>
              Tel: ${item.pharmacy.phone}
            </div>
            <div style="margin-top: 12px; display: flex; gap: 8px;">
              <a href="tel:${item.pharmacy.phone}" style="background: var(--green-dim); color: var(--green); padding: 6px 12px; border-radius: 6px; text-decoration: none; font-size: 12px;">Appeler</a>
              <a href="https://www.google.com/maps?q=${item.pharmacy.latitude},${item.pharmacy.longitude}" target="_blank" style="background: var(--teal-dim); color: var(--teal); padding: 6px 12px; border-radius: 6px; text-decoration: none; font-size: 12px;">Itineraire</a>
            </div>
          </div>
        `,
                )
                .join("")
            : "<div class='empty-state'>Aucune pharmacie avec ce medicament</div>"
        }
      </div>
    `,
    );
  } catch (e) {
    showToast(e.message, "error");
  }
}

async function showEditStockModal(medicationId, medicationName) {
  let currentStock = { quantity: 0, price: null, inStock: true };
  try {
    const stockRes = await api.getStock(medicationId);
    if (stockRes.success && stockRes.data) {
      currentStock = stockRes.data;
    }
  } catch (e) {}
  openModal(
    `Stock: ${medicationName}`,
    `
    <div id="stockAlert"></div>
    <div class="form-group"><label>Quantite en stock</label><input type="number" id="stockQuantity" class="modal-input" value="${currentStock.quantity || 0}" min="0"></div>
    <div class="form-group"><label>Prix (DA)</label><input type="number" id="stockPrice" class="modal-input" value="${currentStock.price || ""}" step="10" min="0"></div>
    <div class="form-group"><label>Disponible</label>
      <select id="stockInStock" class="modal-input">
        <option value="true" ${currentStock.inStock !== false ? "selected" : ""}>Oui</option>
        <option value="false" ${currentStock.inStock === false ? "selected" : ""}>Non (rupture)</option>
      </select>
    </div>
    <div class="modal-actions">
      <button class="btn-cancel-modal" onclick="closeModal()">Annuler</button>
      <button class="btn-save-modal" onclick="saveStock('${medicationId}', '${escapeHtml(medicationName)}')">Enregistrer</button>
    </div>
  `,
  );
}

async function saveStock(medicationId, medicationName) {
  const quantity =
    parseInt(document.getElementById("stockQuantity").value) || 0;
  const price = parseFloat(document.getElementById("stockPrice").value) || null;
  const inStock = document.getElementById("stockInStock").value === "true";
  try {
    await api.updateStock(medicationId, { quantity, price, inStock });
    closeModal();
    showToast(`Stock de ${medicationName} mis a jour`, "success");
    if (currentPage === "dashboard") await loadDashboard();
    else if (currentPage === "inventory") await loadInventory();
  } catch (e) {
    const alertEl = document.getElementById("stockAlert");
    if (alertEl)
      alertEl.innerHTML = `<div class="alert-error">${e.message}</div>`;
  }
}

async function toggleDuty() {
  const newStatus = !currentPharmacy?.isOnDutyTonight;
  try {
    await api.setDutyStatus(newStatus);
    showToast(newStatus ? "Garde activee" : "Garde desactivee", "success");
    await loadPharmacyProfile();
    if (currentPage === "dashboard") {
      await loadDashboard();
    }
  } catch (e) {
    showToast(e.message, "error");
  }
}

async function searchMedications(query) {
  if (query.length < 2) {
    const resultsDiv = document.getElementById("searchResults");
    if (resultsDiv) resultsDiv.innerHTML = "";
    return;
  }
  try {
    const res = await api.searchMedications(query);
    const resultsDiv = document.getElementById("searchResults");
    if (!resultsDiv) return;
    if (res.success && res.data && res.data.length) {
      resultsDiv.innerHTML = `
        <div class="search-results-list">
          ${res.data
            .map(
              (med) => `
            <div class="search-result-item" onclick="showMedicationDetails('${med.id}')">
              <strong>${med.name}</strong> ${med.dosage ? `- ${med.dosage}` : ""}
              <button class="btn-edit-stock-small" onclick="event.stopPropagation(); showEditStockModal('${med.id}', '${escapeHtml(med.name)}')">Modifier stock</button>
            </div>
          `,
            )
            .join("")}
        </div>
      `;
    } else {
      resultsDiv.innerHTML = `<div class="empty-state">Aucun medicament trouve</div>`;
    }
  } catch (e) {
    const resultsDiv = document.getElementById("searchResults");
    if (resultsDiv)
      resultsDiv.innerHTML = `<div class="error-state">Erreur de recherche</div>`;
  }
}

async function scanBarcode() {
  const barcode = prompt("Scannez le code-barres ou entrez le numero:");
  if (barcode) {
    try {
      const res = await api.searchByBarcode(barcode);
      if (res.success && res.data) {
        showMedicationDetails(res.data.id);
      } else {
        showToast("Medicament non trouve", "error");
      }
    } catch (e) {
      showToast(e.message, "error");
    }
  }
}

function setupModal() {
  const closeBtn = document.getElementById("modalCloseBtn");
  if (closeBtn) closeBtn.addEventListener("click", closeModal);
  const overlay = document.getElementById("modalOverlay");
  if (overlay) {
    overlay.addEventListener("click", (e) => {
      if (e.target === overlay) closeModal();
    });
  }
}

function openModal(title, bodyHTML) {
  const modal = document.getElementById("modalOverlay");
  const titleEl = document.getElementById("modalTitle");
  const bodyEl = document.getElementById("modalBody");
  if (!modal || !titleEl || !bodyEl) return;
  titleEl.textContent = title;
  bodyEl.innerHTML = bodyHTML;
  modal.style.display = "flex";
}

function closeModal() {
  const modal = document.getElementById("modalOverlay");
  if (modal) modal.style.display = "none";
}

function escapeHtml(str) {
  if (!str) return "";
  return str
    .replace(/[&<>]/g, function (m) {
      if (m === "&") return "&amp;";
      if (m === "<") return "&lt;";
      if (m === ">") return "&gt;";
      return m;
    })
    .replace(/['"]/g, function (m) {
      if (m === "'") return "&#39;";
      if (m === '"') return "&quot;";
      return m;
    });
}

function showToast(message, type = "info") {
  const colors = { success: "#34d399", error: "#f87171", info: "#60a5fa" };
  const toast = document.createElement("div");
  toast.className = `toast ${type}`;
  toast.innerHTML = `<i class="fas ${type === "success" ? "fa-check-circle" : type === "error" ? "fa-exclamation-circle" : "fa-info-circle"}"></i> ${message}`;
  document.body.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = "0";
    toast.style.transform = "translateY(20px)";
    setTimeout(() => toast.remove(), 300);
  }, 3200);
}

window.showMedicationDetails = showMedicationDetails;
window.showStockForMedication = showStockForMedication;
window.showEditStockModal = showEditStockModal;
window.saveStock = saveStock;
window.closeModal = closeModal;
window.navigateTo = navigateTo;
