// doctor/js/doctor-dashboard.js

// ─── State ────────────────────────────────────────────────
let currentDoctor = null;
let currentPage = "dashboard";
let allAppointments = [];
let currentPatients = [];

// ─── Bootstrap ────────────────────────────────────────────
document.addEventListener("DOMContentLoaded", async () => {
  await checkAuth();
  await loadDoctorProfile();
  setupNav();
  setupModal();
  await loadDashboard();
});

// ─── Auth guard ───────────────────────────────────────────
async function checkAuth() {
  const token = STORAGE.getToken();
  const user = STORAGE.getUser();
  if (!token || !user || user.role !== "doctor") {
    window.location.href = "doctor-login.html";
    return;
  }
  if (!api.getDoctorId()) {
    try {
      const res = await api.getDoctorByUserId(user.id);
      if (res.success && res.data?.id) {
        api.setDoctorId(res.data.id);
      } else {
        window.location.href = "doctor-login.html";
      }
    } catch {
      window.location.href = "doctor-login.html";
    }
  }
}

// ─── Header doctor info ───────────────────────────────────
async function loadDoctorProfile() {
  try {
    const res = await api.getCurrentDoctor();
    if (!res.success) return;
    currentDoctor = res.data;
    const name = currentDoctor.doctorName || "Dr.";
    const parts = name.split(" ");
    const initials = (
      (parts[0]?.[0] || "") + (parts[1]?.[0] || "")
    ).toUpperCase();
    document.getElementById("doctorAvatar").textContent = initials || "DR";
    document.getElementById("doctorName").textContent = name;
    document.getElementById("doctorSpecialty").textContent =
      currentDoctor.specialty?.nameFr ||
      currentDoctor.specialty?.name ||
      "Médecin";
  } catch (e) {
    console.error("Erreur profil:", e);
  }
}

// ─── Navigation ───────────────────────────────────────────
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
    if (confirm("Voulez-vous vous déconnecter ?")) {
      await api.logout();
      window.location.href = "doctor-login.html";
    }
  });
}
async function navigateTo(page) {
  currentPage = page;
  const titles = {
    dashboard: ["Tableau de bord", "Bienvenue dans votre espace professionnel"],
    appointments: ["Rendez-vous", "Consultez et gérez tous vos rendez-vous"],
    patients: ["Patients", "Gérez et recherchez vos patients"],
    availability: ["Disponibilités", "Définissez vos horaires de consultation"],
    reviews: ["Avis patients", "Consultez les avis de vos patients"],
    profile: ["Mon profil", "Modifiez vos informations personnelles"],
    "waiting-queue": [
      "File d'attente",
      "Gérez la file d'attente de votre cabinet",
    ], // ✅ AJOUTÉ
  };
  const [title, subtitle] = titles[page] || ["–", ""];
  document.getElementById("pageTitle").textContent = title;
  document.getElementById("pageSubtitle").textContent = subtitle;

  const fns = {
    dashboard: loadDashboard,
    appointments: loadAppointments,
    patients: loadPatients,
    availability: loadAvailability,
    reviews: loadReviews,
    profile: loadProfile,
    "waiting-queue": loadWaitingQueuePage, // ✅ AJOUTÉ
  };
  pageLoading();
  try {
    await (fns[page] || loadDashboard)();
  } catch (e) {
    pageError(e.message);
  }
}

function pageLoading() {
  document.getElementById("pageContent").innerHTML =
    `<div class="loading"><div class="spinner"></div><p>Chargement...</p></div>`;
}

function pageError(msg) {
  document.getElementById("pageContent").innerHTML =
    `<div class="empty-state"><i class="fas fa-exclamation-circle"></i><p>${msg}</p></div>`;
}

function setContent(html) {
  document.getElementById("pageContent").innerHTML = html;
}

// ═══════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════
async function loadDashboard() {
  const [stats, apptRes] = await Promise.all([
    api.getDoctorStats(),
    api.getDoctorAppointments(),
  ]);
  allAppointments = apptRes.data || [];
  const upcoming = allAppointments
    .filter((a) => a.status === "pending" || a.status === "confirmed")
    .sort((a, b) => new Date(a.appointmentDate) - new Date(b.appointmentDate))
    .slice(0, 5);

  // Greeting personnalisé
  const hour = new Date().getHours();
  let greeting = "Bonjour";
  if (hour < 12) greeting = "Bonjour";
  else if (hour < 18) greeting = "Bon après-midi";
  else greeting = "Bonsoir";

  const today = new Date().toLocaleDateString("fr-FR", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
  });

  setContent(`
    <div class="welcome-header">
      <div>
        <h2>${greeting}, ${currentDoctor?.doctorName?.split(" ")[0] || "Docteur"} 👋</h2>
        <p class="text-muted">${today}</p>
      </div>
      <div class="revenue-badge">
        <i class="fas fa-coins"></i> Revenus du jour: ${stats.todayRevenue || 0} DA
      </div>
    </div>

    <div class="stats-grid">
      ${statCard("primary", "fa-calendar-check", stats.total, "Total rendez-vous")}
      ${statCard("warning", "fa-hourglass-half", stats.pending, "En attente")}
      ${statCard("success", "fa-check-circle", stats.confirmed, "Confirmés")}
      ${statCard("info", "fa-stethoscope", stats.completed, "Terminés")}
      ${statCard("danger", "fa-times-circle", stats.cancelled, "Annulés")}
      ${statCard("purple", "fa-star", stats.averageRating, "Note moyenne")}
    </div>

    <div class="card">
      <div class="card-header">
        <h3>📅 Prochains rendez-vous</h3>
        <a href="#" class="link-more" onclick="navigateTo('appointments');return false;">Voir tout →</a>
      </div>
      <div class="card-body">
        ${upcoming.length ? upcoming.map(renderApptCard).join("") : `<div class="empty-state"><i class="fas fa-calendar-check"></i><p>Aucun rendez-vous à venir</p></div>`}
      </div>
    </div>
  `);
  bindApptButtons(upcoming);
}

function statCard(color, icon, value, label) {
  return `<div class="stat-card"><div class="stat-icon ${color}"><i class="fas ${icon}"></i></div><div class="stat-value">${value ?? "–"}</div><div class="stat-label">${label}</div></div>`;
}

// ═══════════════════════════════════════════════════════════
// APPOINTMENTS
// ═══════════════════════════════════════════════════════════
async function loadAppointments() {
  const res = await api.getDoctorAppointments();
  allAppointments = res.data || [];

  const counts = {
    "": allAppointments.length,
    pending: allAppointments.filter((a) => a.status === "pending").length,
    confirmed: allAppointments.filter((a) => a.status === "confirmed").length,
    completed: allAppointments.filter((a) => a.status === "completed").length,
    cancelled: allAppointments.filter((a) => a.status === "cancelled").length,
  };

  setContent(`
    <div class="filter-tabs" id="apptTabs">
      <button class="tab-btn active" data-filter="">Tous (${counts[""]})</button>
      <button class="tab-btn" data-filter="pending">En attente (${counts.pending})</button>
      <button class="tab-btn" data-filter="confirmed">Confirmés (${counts.confirmed})</button>
      <button class="tab-btn" data-filter="completed">Terminés (${counts.completed})</button>
      <button class="tab-btn" data-filter="cancelled">Annulés (${counts.cancelled})</button>
    </div>
    <div id="apptList">
      ${allAppointments.length ? allAppointments.map(renderApptCard).join("") : `<div class="empty-state"><i class="fas fa-calendar"></i><p>Aucun rendez-vous</p></div>`}
    </div>
  `);

  bindApptButtons(allAppointments);

  document.querySelectorAll("#apptTabs .tab-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      document
        .querySelectorAll("#apptTabs .tab-btn")
        .forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      const f = btn.dataset.filter;
      const list = f
        ? allAppointments.filter((a) => a.status === f)
        : allAppointments;
      document.getElementById("apptList").innerHTML = list.length
        ? list.map(renderApptCard).join("")
        : `<div class="empty-state"><i class="fas fa-calendar"></i><p>Aucun rendez-vous</p></div>`;
      bindApptButtons(list);
    });
  });
}

function renderApptCard(a) {
  const STATUS = {
    pending: "En attente",
    confirmed: "Confirmé",
    cancelled: "Annulé",
    completed: "Terminé",
    no_show: "Absent",
  };
  const date = new Date(a.appointmentDate).toLocaleDateString("fr-FR", {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  });
  const time = (a.appointmentTime || "").slice(0, 5);
  const patient = a.patient || {};

  // Calcul du temps restant
  const now = new Date();
  const apptDateTime = new Date(`${a.appointmentDate}T${a.appointmentTime}`);
  const diffMinutes = Math.round((apptDateTime - now) / (1000 * 60));
  let timeInfo = "";
  if (diffMinutes > 0 && diffMinutes <= 60) {
    timeInfo = `<span class="time-warning">⏰ DANS ${diffMinutes} MIN</span>`;
  }

  let actions = "";
  if (a.status === "pending") {
    actions = `<div class="appointment-actions">
      <button class="btn-sm btn-confirm" data-id="${a.id}" data-action="confirm">✓ Confirmer</button>
      <button class="btn-sm btn-cancel" data-id="${a.id}" data-action="cancel">✗ Annuler</button>
    </div>`;
  } else if (a.status === "confirmed") {
    actions = `<div class="appointment-actions">
      <button class="btn-sm btn-cancel" data-id="${a.id}" data-action="cancel">✗ Annuler</button>
      <button class="btn-sm btn-complete" data-id="${a.id}" data-action="complete">✔ Terminer</button>
    </div>`;
  }

  return `
    <div class="appointment-card ${a.status}">
      <div class="appointment-header">
        <span class="patient-name">👤 ${patient.fullName || "Patient"}</span>
        <span class="status-badge ${a.status}">${STATUS[a.status] || a.status}</span>
        ${timeInfo}
      </div>
      <div class="appointment-datetime">📅 ${date} à ${time}</div>
      ${patient.phoneNumber ? `<div class="appointment-reason"><i class="fas fa-phone"></i> ${patient.phoneNumber}</div>` : ""}
      ${a.reason ? `<div class="appointment-reason"><i class="fas fa-notes-medical"></i> ${a.reason}</div>` : ""}
      ${actions}
    </div>`;
}

function bindApptButtons(list) {
  document.querySelectorAll("[data-action]").forEach((btn) => {
    btn.addEventListener("click", async () => {
      const id = btn.dataset.id;
      const action = btn.dataset.action;
      await doApptAction(id, action);
    });
  });
}

async function doApptAction(id, action) {
  try {
    if (action === "confirm") {
      await api.confirmAppointment(id);
      showToast("Rendez-vous confirmé !", "success");
    } else if (action === "cancel") {
      const reason = prompt("Raison de l'annulation (optionnel) :") ?? "";
      await api.cancelAppointment(id, reason);
      showToast("Rendez-vous annulé.", "success");
    } else if (action === "complete") {
      await api.completeAppointment(id);
      showToast("Rendez-vous terminé !", "success");
    }
    if (currentPage === "dashboard") await loadDashboard();
    else await loadAppointments();
  } catch (e) {
    showToast(e.message, "error");
  }
}

// ═══════════════════════════════════════════════════════════
// PATIENTS
// ═══════════════════════════════════════════════════════════
async function loadPatients() {
  if (!allAppointments.length) {
    const res = await api.getDoctorAppointments();
    allAppointments = res.data || [];
  }
  const map = new Map();
  allAppointments.forEach((a) => {
    if (a.patient && !map.has(a.patientId)) map.set(a.patientId, a.patient);
  });
  currentPatients = [...map.values()];
  renderPatientsPage(currentPatients);
}
// Remplacer la fonction renderPatientsPage (section recherche)

function renderPatientsPage(patients) {
  setContent(`
    <div class="patients-toolbar">
      <div class="search-bar">
        <i class="fas fa-search"></i>
        <input type="text" id="patientSearchInput" placeholder="Rechercher par numéro Carte Chifa...">
      </div>
      <button class="btn-primary-sm" id="addPatientBtn"><i class="fas fa-user-plus"></i> Nouveau patient</button>
    </div>
    <div id="patientsList">${renderPatientCards(patients)}</div>
  `);

  // ✅ Recherche par Chifa uniquement (appel API)
  let timer;
  document
    .getElementById("patientSearchInput")
    .addEventListener("input", (e) => {
      clearTimeout(timer);
      timer = setTimeout(async () => {
        const chifaNumber = e.target.value.trim();

        if (!chifaNumber) {
          // Si vide, afficher tous les patients
          document.getElementById("patientsList").innerHTML =
            renderPatientCards(currentPatients);
          bindPatientButtons();
          return;
        }

        // ✅ Appel API avec chifaNumber
        try {
          const res = await api.searchPatientsByChifa(chifaNumber);
          const results = res.data || [];
          document.getElementById("patientsList").innerHTML =
            renderPatientCards(results);
          bindPatientButtons();
        } catch (error) {
          console.error("Erreur recherche:", error);
          document.getElementById("patientsList").innerHTML =
            `<div class="empty-state"><i class="fas fa-exclamation-circle"></i><p>Erreur de recherche</p></div>`;
        }
      }, 500);
    });

  document
    .getElementById("addPatientBtn")
    .addEventListener("click", () => showAddPatientModal());
  bindPatientButtons();
}

function renderPatientCards(patients) {
  if (!patients.length) {
    return `
      <div class="empty-state">
        <i class="fas fa-users"></i>
        <p>Aucun patient trouvé</p>
      </div>
    `;
  }

  return patients
    .map(
      (p) => `
        <div class="patient-card">
          <div class="patient-avatar">
            ${(p.fullName || "?").slice(0, 2).toUpperCase()}
          </div>

          <div class="patient-info">
            <h4>${p.fullName || "Nom inconnu"}</h4>

            <p>
              <i class="fas fa-phone"></i>
              ${p.phoneNumber || "Non renseigné"}
            </p>

            <p>
              <i class="fas fa-id-card"></i>
              Chifa: ${p.chifaNumber || "Non renseigné"}
            </p>
          </div>

          <div class="patient-actions">
            <button
              class="btn-view"
              data-patient-id="${p.id}"
              data-patient-name="${esc(p.fullName || "")}"
              data-action="view"
            >
              <i class="fas fa-eye"></i> Voir détails
            </button>

            <button
              class="btn-consult"
              data-patient-id="${p.id}"
              data-patient-name="${esc(p.fullName || "")}"
              data-action="consult"
            >
              <i class="fas fa-clipboard"></i> Consultation
            </button>

            <button
              class="btn-prescription"
              data-patient-id="${p.id}"
              data-patient-name="${esc(p.fullName || "")}"
              data-action="prescribe"
            >
              <i class="fas fa-pills"></i> Ordonnance
            </button>
          </div>
        </div>
      `,
    )
    .join("");
}

function bindPatientButtons() {
  document.querySelectorAll("[data-action='view']").forEach((btn) => {
    btn.addEventListener("click", () =>
      viewPatient(btn.dataset.patientId, btn.dataset.patientName),
    );
  });
  document.querySelectorAll("[data-action='consult']").forEach((btn) => {
    btn.addEventListener("click", () =>
      showConsultationModal(btn.dataset.patientId, btn.dataset.patientName),
    );
  });
  document.querySelectorAll("[data-action='prescribe']").forEach((btn) => {
    btn.addEventListener("click", () =>
      showPrescriptionModal(btn.dataset.patientId, btn.dataset.patientName),
    );
  });
}

function viewPatient(patientId, patientName) {
  window.open(`patient-details.html?id=${patientId}`, "_blank");
}
// ============================================
// PATIENT DETAILS - FONCTIONS D'AJOUT
// ============================================

// Ajouter une consultation (dans la page patient-details)
async function addConsultationFromDetails(patientId, patientName) {
  openModal(
    `📋 Nouvelle consultation - ${patientName || "Patient"}`,
    `
        <div id="consultAlert"></div>
        <div class="form-group"><label>Motif principal *</label><input class="modal-input" type="text" id="c_complaint" placeholder="Ex: Douleurs abdominales"></div>
        <div class="form-group"><label>Diagnostic</label><textarea class="modal-input" id="c_diagnosis" rows="3" placeholder="Diagnostic..."></textarea></div>
        <div class="form-group"><label>Traitement prescrit</label><textarea class="modal-input" id="c_treatment" rows="3" placeholder="Traitement..."></textarea></div>
        <div class="form-group"><label>Notes</label><textarea class="modal-input" id="c_notes" rows="2" placeholder="Notes supplémentaires..."></textarea></div>
        <div class="form-group"><label>Honoraires (DA)</label><input class="modal-input" type="number" id="c_fee" placeholder="3000"></div>
        <div class="modal-actions">
            <button class="btn-cancel-modal" onclick="closeModal()">Annuler</button>
            <button class="btn-save-modal" onclick="saveConsultationFromDetails('${patientId}')">Enregistrer</button>
        </div>
    `,
  );
}

async function saveConsultationFromDetails(patientId) {
  const alertEl = document.getElementById("consultAlert");
  alertEl.innerHTML = "";

  const chiefComplaint = document.getElementById("c_complaint").value.trim();
  if (!chiefComplaint) {
    alertEl.innerHTML = `<div class="alert-error">Le motif principal est obligatoire.</div>`;
    return;
  }

  const data = {
    patientId: patientId,
    chiefComplaint: chiefComplaint,
    diagnosis: document.getElementById("c_diagnosis").value.trim(),
    treatmentPlan: document.getElementById("c_treatment").value.trim(),
    notes: document.getElementById("c_notes").value.trim(),
    feePaid: parseFloat(document.getElementById("c_fee").value) || null,
  };

  try {
    await api.createConsultation(data);
    closeModal();
    showToast("Consultation enregistrée avec succès !", "success");
    setTimeout(() => {
      window.location.reload();
    }, 1000);
  } catch (e) {
    alertEl.innerHTML = `<div class="alert-error">❌ ${e.message}</div>`;
  }
}

// Ajouter une ordonnance
async function addPrescriptionFromDetails(patientId, patientName) {
  openModal(
    `💊 Nouvelle ordonnance - ${patientName || "Patient"}`,
    `
        <div id="prescAlert"></div>
        <div class="form-group"><label>Diagnostic</label><input class="modal-input" type="text" id="p_diagnosis" placeholder="Diagnostic..."></div>
        <div id="medicationsList">${medicationRow()}</div>
        <button class="btn-add-med" id="addMedBtn">+ Ajouter un médicament</button>
        <div class="form-group" style="margin-top:12px;"><label>Instructions générales</label><textarea class="modal-input" id="p_instructions" rows="2" placeholder="Ex: À prendre avec de la nourriture"></textarea></div>
        <div class="form-group"><label>Date d'expiration</label><input class="modal-input" type="date" id="p_expires" value="${futureDate(30)}"></div>
        <div class="form-group"><label>Renouvelable</label>
            <select class="modal-input" id="p_renewable">
                <option value="false">Non</option>
                <option value="true">Oui</option>
            </select>
        </div>
        <div class="modal-actions">
            <button class="btn-cancel-modal" onclick="closeModal()">Annuler</button>
            <button class="btn-save-modal" onclick="savePrescriptionFromDetails('${patientId}')">Enregistrer</button>
        </div>
    `,
  );

  document.getElementById("addMedBtn").addEventListener("click", () => {
    document
      .getElementById("medicationsList")
      .insertAdjacentHTML("beforeend", medicationRow());
  });
}

async function savePrescriptionFromDetails(patientId) {
  const alertEl = document.getElementById("prescAlert");
  alertEl.innerHTML = "";

  const rows = document.querySelectorAll(".medication-row");
  const medications = [];
  let valid = true;

  rows.forEach((row) => {
    const name = row.querySelector(".med-name")?.value.trim();
    const dosage = row.querySelector(".med-dosage")?.value.trim();
    const frequency = row.querySelector(".med-frequency")?.value.trim();
    const duration = row.querySelector(".med-duration")?.value.trim();
    if (!name) {
      valid = false;
      return;
    }
    medications.push({ name, dosage, frequency, duration });
  });

  if (!valid || !medications.length) {
    alertEl.innerHTML = `<div class="alert-error">Ajoutez au moins un médicament avec un nom.</div>`;
    return;
  }

  const data = {
    patientId: patientId,
    diagnosis: document.getElementById("p_diagnosis").value.trim(),
    medications: medications,
    instructions: document.getElementById("p_instructions").value.trim(),
    validityDays: 30,
    isRenewable: document.getElementById("p_renewable").value === "true",
  };

  try {
    await api.createPrescription(data);
    closeModal();
    showToast("Ordonnance enregistrée avec succès !", "success");
    setTimeout(() => {
      window.location.reload();
    }, 1000);
  } catch (e) {
    alertEl.innerHTML = `<div class="alert-error">❌ ${e.message}</div>`;
  }
}

// Ajouter une allergie
async function addAllergyFromDetails(patientId) {
  openModal(
    `⚠️ Ajouter une allergie`,
    `
        <div id="allergyAlert"></div>
        <div class="form-group"><label>Nom de l'allergie *</label><input class="modal-input" type="text" id="a_name" placeholder="Ex: Pénicilline"></div>
        <div class="form-group"><label>Type</label>
            <select class="modal-input" id="a_type">
                <option value="medication">Médicament</option>
                <option value="food">Aliment</option>
                <option value="environmental">Environnemental</option>
                <option value="other">Autre</option>
            </select>
        </div>
        <div class="form-group"><label>Sévérité</label>
            <select class="modal-input" id="a_severity">
                <option value="mild">Légère</option>
                <option value="moderate">Modérée</option>
                <option value="severe">Sévère</option>
            </select>
        </div>
        <div class="form-group"><label>Réaction</label><textarea class="modal-input" id="a_reaction" rows="2" placeholder="Description de la réaction..."></textarea></div>
        <div class="modal-actions">
            <button class="btn-cancel-modal" onclick="closeModal()">Annuler</button>
            <button class="btn-save-modal" onclick="saveAllergyFromDetails('${patientId}')">Enregistrer</button>
        </div>
    `,
  );
}

async function saveAllergyFromDetails(patientId) {
  const alertEl = document.getElementById("allergyAlert");
  alertEl.innerHTML = "";

  const allergyName = document.getElementById("a_name").value.trim();
  if (!allergyName) {
    alertEl.innerHTML = `<div class="alert-error">Le nom de l'allergie est obligatoire.</div>`;
    return;
  }

  const data = {
    allergyName: allergyName,
    allergyType: document.getElementById("a_type").value,
    severity: document.getElementById("a_severity").value,
    reaction: document.getElementById("a_reaction").value.trim(),
  };

  try {
    await api.createAllergy(patientId, data);
    closeModal();
    showToast("Allergie ajoutée avec succès !", "success");
    setTimeout(() => {
      window.location.reload();
    }, 1000);
  } catch (e) {
    alertEl.innerHTML = `<div class="alert-error">❌ ${e.message}</div>`;
  }
}

// Supprimer une allergie
async function deleteAllergyFromDetails(allergyId) {
  if (!confirm("Voulez-vous vraiment supprimer cette allergie ?")) return;

  try {
    await api.deleteAllergy(allergyId);
    showToast("Allergie supprimée !", "success");
    setTimeout(() => {
      window.location.reload();
    }, 1000);
  } catch (e) {
    showToast("Erreur lors de la suppression", "error");
  }
}

// ─── Add patient modal ────────────────────────────────────
function showAddPatientModal() {
  openModal(
    "➕ Nouveau patient",
    `
    <div id="addPatientAlert"></div>
    <div class="form-group"><label>Nom complet *</label><input class="modal-input" type="text" id="np_name" placeholder="Mohammed Benali"></div>
    <div class="form-group"><label>Email *</label><input class="modal-input" type="email" id="np_email" placeholder="patient@mail.com"></div>
    <div class="form-group"><label>Téléphone *</label><input class="modal-input" type="tel" id="np_phone" placeholder="0555123456"></div>
    <div class="form-group"><label>Numéro Chifa</label><input class="modal-input" type="text" id="np_chifa" placeholder="(optionnel)"></div>
    <div class="form-group"><label>Mot de passe *</label><input class="modal-input" type="password" id="np_pwd" placeholder="••••••••"></div>
    <div class="modal-actions">
      <button class="btn-cancel-modal" onclick="closeModal()">Annuler</button>
      <button class="btn-save-modal" onclick="saveNewPatient()">Enregistrer</button>
    </div>
  `,
  );
}

async function saveNewPatient() {
  const alertEl = document.getElementById("addPatientAlert");
  alertEl.innerHTML = "";
  const data = {
    fullName: document.getElementById("np_name").value.trim(),
    email: document.getElementById("np_email").value.trim(),
    phoneNumber: document.getElementById("np_phone").value.trim(),
    chifaNumber: document.getElementById("np_chifa").value.trim() || undefined,
    password: document.getElementById("np_pwd").value,
  };
  if (!data.fullName || !data.email || !data.phoneNumber || !data.password) {
    alertEl.innerHTML = `<div class="alert-error">Veuillez remplir tous les champs obligatoires.</div>`;
    return;
  }
  try {
    await api.createPatient(data);
    closeModal();
    showToast("Patient créé avec succès !", "success");
    await loadPatients();
  } catch (e) {
    alertEl.innerHTML = `<div class="alert-error">❌ ${e.message}</div>`;
  }
}

// ─── Consultation modal ───────────────────────────────────
function showConsultationModal(patientId, patientName) {
  openModal(
    `📋 Consultation – ${patientName || "Patient"}`,
    `
    <div id="consultAlert"></div>
    <div class="form-group"><label>Motif principal *</label><input class="modal-input" type="text" id="c_complaint" placeholder="Ex: Douleurs abdominales"></div>
    <div class="form-group"><label>Diagnostic</label><textarea class="modal-input" id="c_diagnosis" rows="3" placeholder="Diagnostic..."></textarea></div>
    <div class="form-group"><label>Plan de traitement</label><textarea class="modal-input" id="c_treatment" rows="3" placeholder="Traitement prescrit..."></textarea></div>
    <div class="form-group"><label>Notes</label><textarea class="modal-input" id="c_notes" rows="2" placeholder="Notes supplémentaires..."></textarea></div>
    <div class="form-group"><label>Honoraires (DA)</label><input class="modal-input" type="number" id="c_fee" placeholder="3000"></div>
    <div class="modal-actions">
      <button class="btn-cancel-modal" onclick="closeModal()">Annuler</button>
      <button class="btn-save-modal" onclick="saveConsultation('${patientId}')">Enregistrer</button>
    </div>
  `,
  );
}

async function saveConsultation(patientId) {
  const alertEl = document.getElementById("consultAlert");
  alertEl.innerHTML = "";

  const chiefComplaint = document.getElementById("c_complaint").value.trim();
  if (!chiefComplaint) {
    alertEl.innerHTML = `<div class="alert-error">Le motif principal est obligatoire.</div>`;
    return;
  }

  const data = {
    patientId: patientId,
    // ❌ NE PAS envoyer doctorId
    chiefComplaint: chiefComplaint,
    diagnosis: document.getElementById("c_diagnosis").value.trim(),
    treatmentPlan: document.getElementById("c_treatment").value.trim(),
    notes: document.getElementById("c_notes").value.trim(),
    feePaid: parseFloat(document.getElementById("c_fee").value) || null,
  };

  try {
    await api.createConsultation(data);
    closeModal();
    showToast("Consultation enregistrée avec succès !", "success");
    await loadPatients();
  } catch (e) {
    alertEl.innerHTML = `<div class="alert-error">❌ ${e.message}</div>`;
  }
}

// ============================================
// PRESCRIPTION MODAL
// ============================================
function showPrescriptionModal(patientId, patientName) {
  openModal(
    `💊 Nouvelle ordonnance - ${patientName || "Patient"}`,
    `
    <div id="prescAlert"></div>
    <div class="form-group"><label>Diagnostic</label><input class="modal-input" type="text" id="p_diagnosis" placeholder="Diagnostic..."></div>
    <div id="medicationsList">${medicationRow()}</div>
    <button class="btn-add-med" id="addMedBtn">+ Ajouter un médicament</button>
    <div class="form-group" style="margin-top:12px;"><label>Instructions générales</label><textarea class="modal-input" id="p_instructions" rows="2" placeholder="Ex: À prendre avec de la nourriture"></textarea></div>
    <div class="modal-actions">
      <button class="btn-cancel-modal" onclick="closeModal()">Annuler</button>
      <button class="btn-save-modal" onclick="savePrescription('${patientId}')">Enregistrer</button>
    </div>
  `,
  );

  document.getElementById("addMedBtn").addEventListener("click", () => {
    document
      .getElementById("medicationsList")
      .insertAdjacentHTML("beforeend", medicationRow());
  });
}

function medicationRow() {
  return `<div class="medication-row">
    <input class="med-input med-name" type="text" placeholder="Médicament *">
    <input class="med-input med-dosage" type="text" placeholder="Dosage (ex: 500mg)">
    <input class="med-input med-frequency" type="text" placeholder="Fréquence (ex: 3x/jour)">
    <input class="med-input med-duration" type="text" placeholder="Durée (ex: 7 jours)">
    <button class="btn-remove-med" onclick="this.closest('.medication-row').remove()">🗑</button>
  </div>`;
}

async function savePrescription(patientId) {
  const alertEl = document.getElementById("prescAlert");
  alertEl.innerHTML = "";

  const rows = document.querySelectorAll(".medication-row");
  const medications = [];
  let valid = true;

  rows.forEach((row) => {
    const name = row.querySelector(".med-name")?.value.trim();
    const dosage = row.querySelector(".med-dosage")?.value.trim();
    const frequency = row.querySelector(".med-frequency")?.value.trim();
    const duration = row.querySelector(".med-duration")?.value.trim();
    if (!name) {
      valid = false;
      return;
    }
    medications.push({ name, dosage, frequency, duration });
  });

  if (!valid || !medications.length) {
    alertEl.innerHTML = `<div class="alert-error">Ajoutez au moins un médicament avec un nom.</div>`;
    return;
  }

  const data = {
    patientId: patientId,
    doctorId: api.getDoctorId(),
    diagnosis: document.getElementById("p_diagnosis").value.trim(),
    medications: medications,
    instructions: document.getElementById("p_instructions").value.trim(),
    validityDays: 30,
    isRenewable: false,
  };

  try {
    await api.createPrescription(data);
    closeModal();
    showToast("Ordonnance enregistrée avec succès !", "success");
    await loadPatients(); // Rafraîchir la liste
  } catch (e) {
    alertEl.innerHTML = `<div class="alert-error">❌ ${e.message}</div>`;
  }
}

// ═══════════════════════════════════════════════════════════// AVAILABILITY (Identique à votre version - gardée telle quelle)
// ═══════════════════════════════════════════════════════════
async function loadAvailability() {
  const DAYS = [
    "Lundi",
    "Mardi",
    "Mercredi",
    "Jeudi",
    "Vendredi",
    "Samedi",
    "Dimanche",
  ];
  let schedule = [];
  try {
    const res = await api.getDoctorSchedule();
    if (res.success) schedule = res.data || [];
  } catch {}
  const schedMap = {};
  schedule.forEach((s) => {
    schedMap[s.dayOfWeek] = s;
  });
  setContent(`
    <div class="card">
      <div class="card-header"><h3>🕐 Horaires de consultation</h3></div>
      <div class="card-body">
        <p class="text-muted" style="margin-bottom:16px;">Activez les jours travaillés et définissez vos plages horaires.</p>
        <div class="schedule-grid" id="schedGrid">${DAYS.map((day, i) => {
          const dayNum = i + 1;
          const s = schedMap[dayNum];
          const isOn = s ? s.isAvailable !== false : dayNum <= 5;
          const start = s?.startTime?.slice(0, 5) || "08:30";
          const end = s?.endTime?.slice(0, 5) || "17:00";
          return `<div class="schedule-card" data-day="${dayNum}">
            <div class="schedule-day-toggle">
              <label class="toggle-switch"><input type="checkbox" class="off-day" ${isOn ? "checked" : ""} onchange="toggleDayTimes(this, ${dayNum})"><span class="toggle-slider"></span></label>
              <h4>${day}</h4>
            </div>
            <div class="time-slots" id="times-${dayNum}" style="${isOn ? "" : "opacity:.35;pointer-events:none;"}">
              <input type="time" class="start-time" value="${start}"><span>à</span><input type="time" class="end-time" value="${end}">
            </div>
          </div>`;
        }).join("")}</div>
        <button class="btn-save-schedule" id="saveSchedBtn">💾 Enregistrer les disponibilités</button>
      </div>
    </div>
  `);
  document
    .getElementById("saveSchedBtn")
    .addEventListener("click", saveAvailability);
}

function toggleDayTimes(checkbox, dayNum) {
  const el = document.getElementById(`times-${dayNum}`);
  el.style.opacity = checkbox.checked ? "1" : ".35";
  el.style.pointerEvents = checkbox.checked ? "" : "none";
}

async function saveAvailability() {
  const cards = document.querySelectorAll(".schedule-card");
  const schedules = [];
  cards.forEach((card) => {
    const dayOfWeek = parseInt(card.dataset.day);
    const isOn = card.querySelector(".off-day").checked;
    const startTime = card.querySelector(".start-time").value || "00:00";
    const endTime = card.querySelector(".end-time").value || "00:00";
    schedules.push({
      dayOfWeek,
      startTime: isOn ? startTime : "00:00",
      endTime: isOn ? endTime : "00:00",
      isAvailable: isOn,
    });
  });
  const btn = document.getElementById("saveSchedBtn");
  btn.disabled = true;
  btn.textContent = "⏳ Enregistrement...";
  try {
    await api.updateDoctorSchedule(schedules);
    showToast("Disponibilités enregistrées !", "success");
  } catch (e) {
    showToast(e.message, "error");
  } finally {
    btn.disabled = false;
    btn.textContent = "💾 Enregistrer les disponibilités";
  }
}

// ═══════════════════════════════════════════════════════════
// REVIEWS (Identique à votre version)
// ═══════════════════════════════════════════════════════════
async function loadReviews() {
  const res = await api.getDoctorReviews();
  const reviews = res.data || [];
  const avg = reviews.length
    ? (reviews.reduce((s, r) => s + r.rating, 0) / reviews.length).toFixed(1)
    : null;
  const dist = [5, 4, 3, 2, 1].map((n) => {
    const count = reviews.filter((r) => r.rating === n).length;
    const pct = reviews.length ? Math.round((count / reviews.length) * 100) : 0;
    return { n, count, pct };
  });
  setContent(`
    ${
      avg
        ? `<div class="card" style="margin-bottom:20px;"><div class="card-body" style="display:flex;gap:32px;align-items:center;flex-wrap:wrap;">
      <div style="text-align:center;"><div style="font-size:52px;font-weight:700;color:var(--primary, #1a6b5a);">${avg}</div>
      <div style="color:#f0a500;font-size:22px;">${"★".repeat(Math.round(avg))}${"☆".repeat(5 - Math.round(avg))}</div>
      <div class="text-muted">${reviews.length} avis</div></div>
      <div style="flex:1;min-width:200px;">${dist
        .map(
          (
            d,
          ) => `<div style="display:flex;align-items:center;gap:8px;margin-bottom:6px;">
        <span style="width:24px;font-size:13px;">${d.n}★</span>
        <div style="flex:1;height:8px;background:#eee;border-radius:4px;overflow:hidden;"><div style="width:${d.pct}%;height:100%;background:#f0a500;border-radius:4px;"></div></div>
        <span style="width:24px;font-size:12px;color:#888;">${d.count}</span>
      </div>`,
        )
        .join("")}</div>
    </div></div>`
        : ""
    }
    <div class="card"><div class="card-header"><h3>⭐ Tous les avis (${reviews.length})</h3></div>
    <div class="card-body">${
      reviews.length
        ? reviews
            .map(
              (
                r,
              ) => `<div class="review-card"><div class="review-header"><span class="reviewer">👤 ${r.user?.fullName || "Patient"}</span>
      <span class="review-rating">${"★".repeat(Math.floor(r.rating))}${"☆".repeat(5 - Math.floor(r.rating))}</span>
      <span class="review-date">${new Date(r.createdAt).toLocaleDateString("fr-FR")}</span></div>
      ${r.comment ? `<p class="review-comment">"${r.comment}"</p>` : ""}</div>`,
            )
            .join("")
        : `<div class="empty-state"><i class="far fa-star"></i><p>Aucun avis pour le moment</p></div>`
    }</div></div>
  `);
}

// ═══════════════════════════════════════════════════════════
// PROFILE (Votre version - gardée telle quelle)
// ═══════════════════════════════════════════════════════════
async function loadProfile() {
  const res = await api.getCurrentDoctor();
  if (!res.success) {
    pageError("Impossible de charger le profil");
    return;
  }
  const doc = res.data;
  const user = STORAGE.getUser() || {};
  setContent(`
    <div class="profile-page">
      <div class="profile-tabs" id="profileTabs">
        <button class="tab-btn active" data-tab="info">📋 Informations</button>
        <button class="tab-btn" data-tab="security">🔐 Sécurité</button>
      </div>
      <div id="tab-info" class="tab-pane">
        <div class="profile-card">
          <div class="profile-avatar-row"><div class="profile-avatar-big">${(doc.doctorName || "DR").slice(0, 2).toUpperCase()}</div>
            <div><div style="font-weight:700;font-size:18px;">${doc.doctorName}</div><div class="text-muted">${doc.specialty?.name || ""}</div>
            <span class="status-badge ${doc.isVerified ? "confirmed" : "pending"}" style="margin-top:6px;display:inline-flex;">${doc.isVerified ? "✓ Compte vérifié" : "⏳ En attente de vérification"}</span></div>
          </div>
          <div id="profileAlert" style="margin-bottom:8px;"></div>
          <div class="form-grid-2">
            <div class="form-group"><label>Nom du médecin *</label><input class="form-control" id="p_name" value="${esc(doc.doctorName || "")}"></div>
            <div class="form-group"><label>Téléphone cabinet</label><input class="form-control" id="p_phone" value="${esc(doc.phone || "")}"></div>
            <div class="form-group"><label>Nom du cabinet</label><input class="form-control" id="p_clinic" value="${esc(doc.clinicName || "")}"></div>
            <div class="form-group"><label>WhatsApp</label><input class="form-control" id="p_whatsapp" value="${esc(doc.whatsappNumber || "")}"></div>
            <div class="form-group" style="grid-column:1/-1;"><label>Adresse du cabinet</label><input class="form-control" id="p_address" value="${esc(doc.clinicAddress || "")}"></div>
            <div class="form-group"><label>Tarif de consultation (DA)</label><input class="form-control" type="number" id="p_fee" value="${doc.consultationFee || ""}"></div>
            <div class="form-group"><label>Années d'expérience</label><input class="form-control" type="number" id="p_exp" value="${doc.yearsOfExperience || ""}"></div>
            <div class="form-group" style="grid-column:1/-1;"><label>Bio / Présentation</label><textarea class="form-control" id="p_bio" rows="4">${doc.bio || ""}</textarea></div>
          </div>
          <div class="form-group" style="margin-top:4px;"><label>Email (non modifiable)</label><input class="form-control" value="${esc(user.email || "")}" disabled style="opacity:.6;"></div>
          <button class="btn-save" id="saveProfileBtn">💾 Enregistrer les modifications</button>
        </div>
      </div>
      <div id="tab-security" class="tab-pane" style="display:none;">
        <div class="profile-card"><h3 style="margin-bottom:16px;">🔐 Changer le mot de passe</h3><div id="passwordAlert" style="margin-bottom:8px;"></div>
          <div class="form-group"><label>Mot de passe actuel *</label><input class="form-control" type="password" id="pwd_current" placeholder="••••••••"></div>
          <div class="form-group"><label>Nouveau mot de passe *</label><input class="form-control" type="password" id="pwd_new" placeholder="••••••••" oninput="renderPwdStrength(this.value)">
            <div style="margin-top:6px;"><div style="height:4px;background:#e5e7eb;border-radius:4px;overflow:hidden;"><div id="pwdBar" style="height:100%;width:0%;border-radius:4px;transition:all .3s;"></div></div><small id="pwdLabel" style="color:#888;"></small></div>
          </div>
          <div class="form-group"><label>Confirmer le nouveau mot de passe *</label><input class="form-control" type="password" id="pwd_confirm" placeholder="••••••••"></div>
          <button class="btn-save" id="savePwdBtn">🔐 Mettre à jour le mot de passe</button>
        </div>
      </div>
    </div>
  `);
  document.querySelectorAll("#profileTabs .tab-btn").forEach((btn) =>
    btn.addEventListener("click", () => {
      document
        .querySelectorAll("#profileTabs .tab-btn")
        .forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      document
        .querySelectorAll(".tab-pane")
        .forEach((p) => (p.style.display = "none"));
      document.getElementById(`tab-${btn.dataset.tab}`).style.display = "block";
    }),
  );
  document
    .getElementById("saveProfileBtn")
    .addEventListener("click", async () => {
      const alert = document.getElementById("profileAlert");
      alert.innerHTML = "";
      const data = {
        doctorName: document.getElementById("p_name").value.trim(),
        clinicName: document.getElementById("p_clinic").value.trim(),
        clinicAddress: document.getElementById("p_address").value.trim(),
        phone: document.getElementById("p_phone").value.trim(),
        whatsappNumber: document.getElementById("p_whatsapp").value.trim(),
        consultationFee:
          parseFloat(document.getElementById("p_fee").value) || null,
        yearsOfExperience:
          parseInt(document.getElementById("p_exp").value) || null,
        bio: document.getElementById("p_bio").value.trim(),
      };
      if (!data.doctorName) {
        alert.innerHTML = `<div class="alert-error">Le nom est obligatoire.</div>`;
        return;
      }
      try {
        await api.updateDoctorProfile(data);
        currentDoctor = { ...currentDoctor, ...data };
        await loadDoctorProfile();
        alert.innerHTML = `<div class="alert-success">✅ Profil mis à jour avec succès !</div>`;
        setTimeout(() => (alert.innerHTML = ""), 3000);
      } catch (e) {
        alert.innerHTML = `<div class="alert-error">❌ ${e.message}</div>`;
      }
    });
  document.getElementById("savePwdBtn").addEventListener("click", async () => {
    const alert = document.getElementById("passwordAlert");
    alert.innerHTML = "";
    const current = document.getElementById("pwd_current").value;
    const newPwd = document.getElementById("pwd_new").value;
    const confirm = document.getElementById("pwd_confirm").value;
    if (!current || !newPwd || !confirm) {
      alert.innerHTML = `<div class="alert-error">Veuillez remplir tous les champs.</div>`;
      return;
    }
    if (newPwd !== confirm) {
      alert.innerHTML = `<div class="alert-error">Les nouveaux mots de passe ne correspondent pas.</div>`;
      return;
    }
    if (newPwd.length < 8) {
      alert.innerHTML = `<div class="alert-error">Minimum 8 caractères.</div>`;
      return;
    }
    try {
      await api.changePassword(current, newPwd);
      alert.innerHTML = `<div class="alert-success">✅ Mot de passe modifié !</div>`;
      ["pwd_current", "pwd_new", "pwd_confirm"].forEach(
        (id) => (document.getElementById(id).value = ""),
      );
      document.getElementById("pwdBar").style.width = "0%";
      document.getElementById("pwdLabel").textContent = "";
      setTimeout(() => (alert.innerHTML = ""), 3000);
    } catch (e) {
      alert.innerHTML = `<div class="alert-error">❌ ${e.message}</div>`;
    }
  });
}

// ─── Modal ─────────────────────────────────────────────────
function setupModal() {
  document
    .getElementById("modalCloseBtn")
    ?.addEventListener("click", closeModal);
  document.getElementById("modalOverlay")?.addEventListener("click", (e) => {
    if (e.target === document.getElementById("modalOverlay")) closeModal();
  });
}

function openModal(title, bodyHTML) {
  const modal = document.getElementById("modalOverlay");
  const titleEl = document.getElementById("modalTitle");
  const bodyEl = document.getElementById("modalBody");

  if (!modal || !titleEl || !bodyEl) {
    console.error("Modal elements not found!");
    return;
  }

  titleEl.textContent = title;
  bodyEl.innerHTML = bodyHTML;
  modal.style.display = "flex";
}

function closeModal() {
  const modal = document.getElementById("modalOverlay");
  if (modal) modal.style.display = "none";
}

// ─── Utils ─────────────────────────────────────────────────
function esc(str) {
  return (str || "").replace(/'/g, "\\'").replace(/"/g, "&quot;");
}

function renderPwdStrength(pwd) {
  let score = 0;
  if (pwd.length >= 8) score++;
  if (/[A-Z]/.test(pwd)) score++;
  if (/[0-9]/.test(pwd)) score++;
  if (/[^A-Za-z0-9]/.test(pwd)) score++;
  const levels = [
    { w: "0%", c: "transparent", t: "" },
    { w: "25%", c: "#e05252", t: "Trop faible" },
    { w: "50%", c: "#f0a500", t: "Faible" },
    { w: "75%", c: "#4a90d9", t: "Moyen" },
    { w: "100%", c: "#3cb371", t: "Fort ✓" },
  ];
  const lvl = levels[score] || levels[0];
  const bar = document.getElementById("pwdBar");
  if (bar) {
    bar.style.width = lvl.w;
    bar.style.background = lvl.c;
  }
  const lbl = document.getElementById("pwdLabel");
  if (lbl) {
    lbl.textContent = lvl.t;
    lbl.style.color = lvl.c;
  }
}

function showToast(message, type = "info") {
  const colors = { success: "#1a6b5a", error: "#e05252", info: "#4a90d9" };
  const toast = document.createElement("div");
  toast.style.cssText = `position:fixed;bottom:24px;right:24px;padding:12px 20px;border-radius:10px;font-size:14px;font-weight:500;z-index:9999;background:${colors[type] || colors.info};color:#fff;box-shadow:0 4px 20px rgba(0,0,0,0.18);transform:translateY(20px);opacity:0;transition:all .3s;`;
  toast.textContent = message;
  document.body.appendChild(toast);
  requestAnimationFrame(() => {
    toast.style.transform = "translateY(0)";
    toast.style.opacity = "1";
  });
  setTimeout(() => {
    toast.style.transform = "translateY(20px)";
    toast.style.opacity = "0";
    setTimeout(() => toast.remove(), 300);
  }, 3200);
}

// ============================================
// WAITING QUEUE (FILE D'ATTENTE)
// ============================================

async function loadWaitingQueuePage() {
  document.getElementById("pageSubtitle").textContent =
    "Gérez la file d'attente des patients";
  await loadWaitingQueue();
}

async function loadWaitingQueue() {
  const doctorId = api.getDoctorId();
  const res = await api.request(`/waiting-queue/doctor/${doctorId}`);
  const queue = res.data || [];

  const inConsultation = queue.find((q) => q.status === "in_consultation");
  const waiting = queue.filter((q) => q.status === "waiting");

  setContent(`
    <div class="waiting-queue-container">
      <div class="current-consultation-card">
        <h3><i class="fas fa-stethoscope"></i> En consultation</h3>
        ${
          inConsultation
            ? `
          <div class="patient-info">
            <div class="patient-name">${inConsultation.patient?.fullName}</div>
            <div class="patient-details">
              ${inConsultation.appointment?.appointmentTime ? `RDV: ${inConsultation.appointment.appointmentTime} | ` : ""}
              Arrivé à: ${new Date(inConsultation.arrivedAt).toLocaleTimeString()}
            </div>
            <button class="btn-complete" onclick="completeConsultation('${inConsultation.id}')">
              <i class="fas fa-check"></i> Terminer consultation
            </button>
          </div>
        `
            : '<div class="empty-state">Aucune consultation en cours</div>'
        }
      </div>
      
      <div class="waiting-list-card">
        <div class="waiting-header">
          <h3><i class="fas fa-users"></i> Patients en attente (${waiting.length})</h3>
          <button class="btn-call-next" onclick="callNextPatient()">
            <i class="fas fa-arrow-right"></i> Appeler suivant
          </button>
        </div>
        
        <div class="waiting-list">
          ${
            waiting.length
              ? waiting
                  .map(
                    (w, index) => `
            <div class="waiting-item priority-${w.priority}">
              <div class="waiting-position">${index + 1}</div>
              <div class="waiting-info">
                <div class="waiting-name">${w.patient?.fullName}</div>
                <div class="waiting-details">
                  ${w.appointment?.appointmentTime ? `RDV: ${w.appointment.appointmentTime} | ` : ""}
                  Arrivé: ${new Date(w.arrivedAt).toLocaleTimeString()}
                  ${w.priority === 0 ? '<span class="urgent-badge">URGENT</span>' : ""}
                </div>
              </div>
              <div class="waiting-actions">
                <button class="btn-urgent" onclick="setUrgent('${w.id}')" title="Passer en urgence">
                  <i class="fas fa-ambulance"></i>
                </button>
                <button class="btn-remove" onclick="removeFromQueue('${w.id}')" title="Retirer">
                  <i class="fas fa-trash"></i>
                </button>
              </div>
            </div>
          `,
                  )
                  .join("")
              : '<div class="empty-state">Aucun patient en attente</div>'
          }
        </div>
        
        <div class="add-patient-section">
          <button class="btn-add-patient" onclick="showAddToQueueModal()">
            <i class="fas fa-user-plus"></i> Ajouter patient à la file
          </button>
        </div>
      </div>
    </div>
  `);
}

async function callNextPatient() {
  const doctorId = api.getDoctorId();
  await api.request(`/waiting-queue/next?doctorId=${doctorId}`, {
    method: "PUT",
  });
  showToast("Patient suivant appelé", "success");
  await loadWaitingQueue();
}

async function completeConsultation(queueId) {
  await api.request(`/waiting-queue/${queueId}/complete`, { method: "PUT" });
  showToast("Consultation terminée", "success");
  await loadWaitingQueue();
}

async function setUrgent(queueId) {
  await api.request(`/waiting-queue/${queueId}/priority`, {
    method: "PUT",
    body: JSON.stringify({ priority: 0 }),
  });
  showToast("Patient passé en urgence", "success");
  await loadWaitingQueue();
}

async function removeFromQueue(queueId) {
  if (!confirm("Retirer ce patient de la file d'attente ?")) return;
  await api.request(`/waiting-queue/${queueId}`, { method: "DELETE" });
  showToast("Patient retiré de la file", "success");
  await loadWaitingQueue();
}

function showAddToQueueModal() {
  // Récupérer la liste des patients du médecin
  const patients = currentPatients;

  openModal(
    "➕ Ajouter patient à la file",
    `
    <div class="form-group">
      <label>Sélectionner un patient</label>
      <select id="queuePatientId" class="modal-input">
        <option value="">Choisir un patient...</option>
        ${patients.map((p) => `<option value="${p.id}">${p.fullName} - ${p.chifaNumber || "Pas de Chifa"}</option>`).join("")}
      </select>
    </div>
    <div class="form-group">
      <label>Priorité</label>
      <select id="queuePriority" class="modal-input">
        <option value="1">Normal (RDV)</option>
        <option value="2">Sans RDV</option>
        <option value="0">Urgence</option>
      </select>
    </div>
    <div class="form-group">
      <label>Notes</label>
      <textarea id="queueNotes" class="modal-input" rows="2" placeholder="Motif, etc..."></textarea>
    </div>
    <div class="modal-actions">
      <button class="btn-cancel-modal" onclick="closeModal()">Annuler</button>
      <button class="btn-save-modal" onclick="saveAddToQueue()">Ajouter</button>
    </div>
  `,
  );
}

async function saveAddToQueue() {
  const patientId = document.getElementById("queuePatientId").value;
  const priority = parseInt(document.getElementById("queuePriority").value);
  const notes = document.getElementById("queueNotes").value;

  if (!patientId) {
    alert("Veuillez sélectionner un patient");
    return;
  }

  const doctorId = api.getDoctorId();

  await api.request("/waiting-queue", {
    method: "POST",
    body: JSON.stringify({ doctorId, patientId, priority, notes }),
  });

  closeModal();
  showToast("Patient ajouté à la file d'attente", "success");
  await loadWaitingQueue();
}
