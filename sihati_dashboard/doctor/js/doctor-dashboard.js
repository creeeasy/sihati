let currentDoctor = null;
let currentPage = "dashboard";
let allAppointments = [];
let currentPatients = [];

document.addEventListener("DOMContentLoaded", async () => {
  await checkAuth();
  await loadDoctorProfile();
  setupNav();
  setupModal();
  await loadDashboard();
});

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
      "Medecin";
  } catch (e) {
    console.error("Erreur profil:", e);
  }
}

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
      await api.logout();
      window.location.href = "doctor-login.html";
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
    dashboard: ["Tableau de bord", "Bienvenue dans votre espace professionnel"],
    appointments: ["Rendez-vous", "Consultez et gerez tous vos rendez-vous"],
    patients: ["Patients", "Gerez et recherchez vos patients"],
    availability: ["Disponibilites", "Definissez vos horaires de consultation"],
    reviews: ["Avis patients", "Consultez les avis de vos patients"],
    profile: ["Mon profil", "Modifiez vos informations personnelles"],
    "waiting-queue": [
      "File d'attente",
      "Gerez la file d'attente de votre cabinet",
    ],
  };
  const [title, subtitle] = titles[page] || ["-", ""];
  document.getElementById("pageTitle").textContent = title;
  document.getElementById("pageSubtitle").textContent = subtitle;
  pageLoading();
  try {
    if (page === "dashboard") await loadDashboard();
    else if (page === "appointments") await loadAppointments();
    else if (page === "patients") await loadPatients();
    else if (page === "availability") await loadAvailability();
    else if (page === "reviews") await loadReviews();
    else if (page === "profile") await loadProfile();
    else if (page === "waiting-queue") await loadWaitingQueuePage();
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

  const hour = new Date().getHours();
  let greeting = "Bonjour";
  if (hour < 12) greeting = "Bonjour";
  else if (hour < 18) greeting = "Bon apres-midi";
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
      <div class="revenue-chip">
        <i class="fas fa-coins"></i> Revenus du jour: ${stats.todayRevenue || 0} DA
      </div>
    </div>

    <div class="stats-grid">
      ${statCard("primary", "fa-calendar-check", stats.total, "Total rendez-vous")}
      ${statCard("warning", "fa-hourglass-half", stats.pending, "En attente")}
      ${statCard("success", "fa-check-circle", stats.confirmed, "Confirmes")}
      ${statCard("info", "fa-stethoscope", stats.completed, "Termines")}
      ${statCard("danger", "fa-times-circle", stats.cancelled, "Annules")}
      ${statCard("purple", "fa-star", stats.averageRating, "Note moyenne")}
    </div>

    <div class="card">
      <div class="card-header">
        <h3>Prochains rendez-vous</h3>
        <a href="#" class="link-more" onclick="navigateTo('appointments');return false;">Voir tout →</a>
      </div>
      <div class="card-body">
        ${upcoming.length ? upcoming.map(renderApptCard).join("") : `<div class="empty-state"><i class="fas fa-calendar-check"></i><p>Aucun rendez-vous a venir</p></div>`}
      </div>
    </div>
  `);
  bindApptButtons(upcoming);
  const revenueChip = document.getElementById("revenueChip");
  if (revenueChip) {
    revenueChip.style.display = "flex";
    document.getElementById("revenueDisplay").textContent =
      `${stats.todayRevenue || 0} DA`;
  }
}

function statCard(color, icon, value, label) {
  return `<div class="stat-card ${color}"><div class="stat-icon ${color}"><i class="fas ${icon}"></i></div><div class="stat-value">${value ?? "-"}</div><div class="stat-label">${label}</div></div>`;
}

function renderApptCard(a) {
  const STATUS = {
    pending: "En attente",
    confirmed: "Confirme",
    cancelled: "Annule",
    completed: "Termine",
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

  const now = new Date();
  const apptDateTime = new Date(`${a.appointmentDate}T${a.appointmentTime}`);
  const diffMinutes = Math.round((apptDateTime - now) / (1000 * 60));
  let timeInfo = "";
  if (diffMinutes > 0 && diffMinutes <= 60) {
    timeInfo = `<span class="time-warning">DANS ${diffMinutes} MIN</span>`;
  }

  let actions = "";
  if (a.status === "pending") {
    actions = `<div class="appointment-actions">
      <button class="btn-sm btn-confirm" data-id="${a.id}" data-action="confirm">Confirmer</button>
      <button class="btn-sm btn-cancel" data-id="${a.id}" data-action="cancel">Annuler</button>
    </div>`;
  } else if (a.status === "confirmed") {
    actions = `<div class="appointment-actions">
      <button class="btn-sm btn-cancel" data-id="${a.id}" data-action="cancel">Annuler</button>
      <button class="btn-sm btn-complete" data-id="${a.id}" data-action="complete">Terminer</button>
    </div>`;
  }

  return `
    <div class="appointment-card ${a.status}">
      <div class="appointment-header">
        <span class="patient-name">${patient.fullName || "Patient"}</span>
        <span class="status-badge ${a.status}">${STATUS[a.status] || a.status}</span>
        ${timeInfo}
      </div>
      <div class="appointment-datetime">${date} a ${time}</div>
      ${patient.phoneNumber ? `<div class="appointment-reason">Tel: ${patient.phoneNumber}</div>` : ""}
      ${a.reason ? `<div class="appointment-reason">Motif: ${a.reason}</div>` : ""}
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
      showToast("Rendez-vous confirme", "success");
    } else if (action === "cancel") {
      const reason = prompt("Raison de l'annulation (optionnel) :") ?? "";
      await api.cancelAppointment(id, reason);
      showToast("Rendez-vous annule", "success");
    } else if (action === "complete") {
      await api.completeAppointment(id);
      showToast("Rendez-vous termine", "success");
    }
    if (currentPage === "dashboard") await loadDashboard();
    else await loadAppointments();
  } catch (e) {
    showToast(e.message, "error");
  }
}

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
      <button class="tab-btn" data-filter="confirmed">Confirmes (${counts.confirmed})</button>
      <button class="tab-btn" data-filter="completed">Termines (${counts.completed})</button>
      <button class="tab-btn" data-filter="cancelled">Annules (${counts.cancelled})</button>
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

function renderPatientsPage(patients) {
  setContent(`
    <div class="patients-toolbar">
      <div class="search-bar">
        <i class="fas fa-search"></i>
        <input type="text" id="patientSearchInput" placeholder="Rechercher par numero Carte Chifa...">
      </div>
      <button class="btn-primary-sm" id="addPatientBtn"><i class="fas fa-user-plus"></i> Nouveau patient</button>
    </div>
    <div id="patientsList">${renderPatientCards(patients)}</div>
  `);

  let timer;
  document
    .getElementById("patientSearchInput")
    .addEventListener("input", (e) => {
      clearTimeout(timer);
      timer = setTimeout(async () => {
        const chifaNumber = e.target.value.trim();
        if (!chifaNumber) {
          document.getElementById("patientsList").innerHTML =
            renderPatientCards(currentPatients);
          bindPatientButtons();
          return;
        }
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
    return `<div class="empty-state"><i class="fas fa-users"></i><p>Aucun patient trouve</p></div>`;
  }
  return patients
    .map(
      (p) => `
    <div class="patient-card">
      <div class="patient-avatar-ring">${(p.fullName || "?").slice(0, 2).toUpperCase()}</div>
      <div class="patient-info">
        <h4>${p.fullName || "Nom inconnu"}</h4>
        <p><i class="fas fa-phone"></i> ${p.phoneNumber || "Non renseigne"}</p>
        <p><i class="fas fa-id-card"></i> Chifa: ${p.chifaNumber || "Non renseigne"}</p>
      </div>
      <div class="patient-actions">
        <button class="btn-view" data-patient-id="${p.id}" data-patient-name="${escapeHtml(p.fullName || "")}" data-action="view">Voir details</button>
        <button class="btn-consult" data-patient-id="${p.id}" data-patient-name="${escapeHtml(p.fullName || "")}" data-action="consult">Consultation</button>
        <button class="btn-prescription" data-patient-id="${p.id}" data-patient-name="${escapeHtml(p.fullName || "")}" data-action="prescribe">Ordonnance</button>
      </div>
    </div>
  `,
    )
    .join("");
}

function bindPatientButtons() {
  document.querySelectorAll("[data-action='view']").forEach((btn) => {
    btn.addEventListener("click", () =>
      window.open(`patient-details.html?id=${btn.dataset.patientId}`, "_blank"),
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

function showAddPatientModal() {
  openModal(
    "Nouveau patient",
    `
    <div id="addPatientAlert"></div>
    <div class="form-group"><label>Nom complet</label><input class="modal-input" type="text" id="np_name" placeholder="Mohammed Benali"></div>
    <div class="form-group"><label>Email</label><input class="modal-input" type="email" id="np_email" placeholder="patient@mail.com"></div>
    <div class="form-group"><label>Telephone</label><input class="modal-input" type="tel" id="np_phone" placeholder="0555123456"></div>
    <div class="form-group"><label>Numero Chifa</label><input class="modal-input" type="text" id="np_chifa" placeholder="Optionnel"></div>
    <div class="form-group"><label>Mot de passe</label><input class="modal-input" type="password" id="np_pwd" placeholder="8 caracteres minimum"></div>
    <div class="modal-actions">
      <button class="btn-cancel-modal" onclick="closeModal()">Annuler</button>
      <button class="btn-save-modal" onclick="saveNewPatient()">Enregistrer</button>
    </div>
  `,
  );
}

async function saveNewPatient() {
  const alertEl = document.getElementById("addPatientAlert");
  const data = {
    fullName: document.getElementById("np_name").value.trim(),
    email: document.getElementById("np_email").value.trim(),
    phoneNumber: document.getElementById("np_phone").value.trim(),
    chifaNumber: document.getElementById("np_chifa").value.trim() || undefined,
    password: document.getElementById("np_pwd").value,
    role: "patient",
  };
  if (!data.fullName || !data.email || !data.phoneNumber || !data.password) {
    alertEl.innerHTML = `<div class="alert-error">Veuillez remplir tous les champs obligatoires.</div>`;
    return;
  }
  if (data.password.length < 8) {
    alertEl.innerHTML = `<div class="alert-error">Le mot de passe doit contenir au moins 8 caracteres.</div>`;
    return;
  }
  try {
    await api.createPatient(data);
    closeModal();
    showToast("Patient cree avec succes", "success");
    await loadPatients();
  } catch (e) {
    alertEl.innerHTML = `<div class="alert-error">${e.message}</div>`;
  }
}

function showConsultationModal(patientId, patientName) {
  openModal(
    `Consultation - ${patientName || "Patient"}`,
    `
    <div id="consultAlert"></div>
    <div class="form-group"><label>Motif principal</label><input class="modal-input" type="text" id="c_complaint" placeholder="Ex: Douleurs abdominales"></div>
    <div class="form-group"><label>Diagnostic</label><textarea class="modal-input" id="c_diagnosis" rows="3" placeholder="Diagnostic..."></textarea></div>
    <div class="form-group"><label>Plan de traitement</label><textarea class="modal-input" id="c_treatment" rows="3" placeholder="Traitement prescrit..."></textarea></div>
    <div class="form-group"><label>Notes</label><textarea class="modal-input" id="c_notes" rows="2" placeholder="Notes supplementaires..."></textarea></div>
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
    showToast("Consultation enregistree", "success");
    await loadPatients();
  } catch (e) {
    alertEl.innerHTML = `<div class="alert-error">${e.message}</div>`;
  }
}

function showPrescriptionModal(patientId, patientName) {
  openModal(
    `Ordonnance - ${patientName || "Patient"}`,
    `
    <div id="prescAlert"></div>
    <div class="form-group"><label>Diagnostic</label><input class="modal-input" type="text" id="p_diagnosis" placeholder="Diagnostic..."></div>
    <div id="medicationsList">${medicationRow()}</div>
    <button class="btn-add-med" id="addMedBtn">Ajouter un medicament</button>
    <div class="form-group"><label>Instructions generales</label><textarea class="modal-input" id="p_instructions" rows="2" placeholder="Instructions..."></textarea></div>
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
    <input class="med-input med-name" type="text" placeholder="Medicament">
    <input class="med-input med-dosage" type="text" placeholder="Dosage">
    <input class="med-input med-frequency" type="text" placeholder="Frequence">
    <input class="med-input med-duration" type="text" placeholder="Duree (jours)">
    <button class="btn-remove-med" onclick="this.closest('.medication-row').remove()">X</button>
  </div>`;
}

async function savePrescription(patientId) {
  const alertEl = document.getElementById("prescAlert");
  const rows = document.querySelectorAll(".medication-row");
  const medications = [];
  let valid = true;
  rows.forEach((row) => {
    const name = row.querySelector(".med-name")?.value.trim();
    if (!name) {
      valid = false;
      return;
    }
    medications.push({
      name: name,
      dosage: row.querySelector(".med-dosage")?.value.trim(),
      frequency: row.querySelector(".med-frequency")?.value.trim(),
      durationDays: row.querySelector(".med-duration")?.value.trim(),
    });
  });
  if (!valid || !medications.length) {
    alertEl.innerHTML = `<div class="alert-error">Ajoutez au moins un medicament avec un nom.</div>`;
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
    showToast("Ordonnance enregistree", "success");
    await loadPatients();
  } catch (e) {
    alertEl.innerHTML = `<div class="alert-error">${e.message}</div>`;
  }
}

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
      <div class="card-header"><h3>Horaires de consultation</h3></div>
      <div class="card-body">
        <p class="text-muted" style="margin-bottom:16px;">Activez les jours travailles et definissez vos plages horaires.</p>
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
              <input type="time" class="start-time" value="${start}"><span>a</span><input type="time" class="end-time" value="${end}">
            </div>
          </div>`;
        }).join("")}</div>
        <button class="btn-save-schedule" id="saveSchedBtn">Enregistrer les disponibilites</button>
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
  btn.textContent = "Enregistrement...";
  try {
    await api.updateDoctorSchedule(schedules);
    showToast("Disponibilites enregistrees", "success");
  } catch (e) {
    showToast(e.message, "error");
  } finally {
    btn.disabled = false;
    btn.textContent = "Enregistrer les disponibilites";
  }
}

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
        ? `<div class="card"><div class="card-body" style="display:flex;gap:32px;align-items:center;flex-wrap:wrap;">
      <div style="text-align:center;"><div style="font-size:52px;font-weight:700;color:var(--teal);">${avg}</div>
      <div style="color:var(--amber);font-size:22px;">${"★".repeat(Math.round(avg))}${"☆".repeat(5 - Math.round(avg))}</div>
      <div class="text-muted">${reviews.length} avis</div></div>
      <div style="flex:1;min-width:200px;">${dist
        .map(
          (
            d,
          ) => `<div style="display:flex;align-items:center;gap:8px;margin-bottom:6px;">
        <span style="width:24px;font-size:13px;">${d.n}★</span>
        <div style="flex:1;height:8px;background:var(--surface);border-radius:4px;overflow:hidden;"><div style="width:${d.pct}%;height:100%;background:var(--amber);border-radius:4px;"></div></div>
        <span style="width:24px;font-size:12px;color:var(--text-dim);">${d.count}</span>
      </div>`,
        )
        .join("")}</div>
    </div></div>`
        : ""
    }
    <div class="card"><div class="card-header"><h3>Tous les avis (${reviews.length})</h3></div>
    <div class="card-body">${
      reviews.length
        ? reviews
            .map(
              (
                r,
              ) => `<div class="review-card"><div class="review-header"><span class="reviewer">${r.user?.fullName || "Patient"}</span>
      <span class="review-rating">${"★".repeat(Math.floor(r.rating))}${"☆".repeat(5 - Math.floor(r.rating))}</span>
      <span class="review-date">${new Date(r.createdAt).toLocaleDateString("fr-FR")}</span></div>
      ${r.comment ? `<p class="review-comment">"${r.comment}"</p>` : ""}</div>`,
            )
            .join("")
        : `<div class="empty-state"><i class="far fa-star"></i><p>Aucun avis pour le moment</p></div>`
    }</div></div>
  `);
}

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
        <button class="tab-btn active" data-tab="info">Informations</button>
        <button class="tab-btn" data-tab="security">Securite</button>
      </div>
      <div id="tab-info" class="tab-pane active">
        <div class="profile-card">
          <div class="profile-avatar-row"><div class="profile-avatar-big">${(doc.doctorName || "DR").slice(0, 2).toUpperCase()}</div>
            <div><div style="font-weight:700;font-size:18px;">${doc.doctorName}</div><div class="text-muted">${doc.specialty?.name || ""}</div>
            <span class="status-badge ${doc.isVerified ? "confirmed" : "pending"}" style="margin-top:6px;display:inline-flex;">${doc.isVerified ? "Compte verifie" : "En attente de verification"}</span></div>
          </div>
          <div id="profileAlert"></div>
          <div class="form-grid-2">
            <div class="form-group"><label>Nom du medecin</label><input class="form-control" id="p_name" value="${escapeHtml(doc.doctorName || "")}"></div>
            <div class="form-group"><label>Telephone cabinet</label><input class="form-control" id="p_phone" value="${escapeHtml(doc.phone || "")}"></div>
            <div class="form-group"><label>Nom du cabinet</label><input class="form-control" id="p_clinic" value="${escapeHtml(doc.clinicName || "")}"></div>
            <div class="form-group"><label>WhatsApp</label><input class="form-control" id="p_whatsapp" value="${escapeHtml(doc.whatsappNumber || "")}"></div>
            <div class="form-group full-width"><label>Adresse du cabinet</label><input class="form-control" id="p_address" value="${escapeHtml(doc.clinicAddress || "")}"></div>
            <div class="form-group"><label>Tarif de consultation (DA)</label><input class="form-control" type="number" id="p_fee" value="${doc.consultationFee || ""}"></div>
            <div class="form-group"><label>Annees d'experience</label><input class="form-control" type="number" id="p_exp" value="${doc.yearsOfExperience || ""}"></div>
            <div class="form-group full-width"><label>Bio / Presentation</label><textarea class="form-control" id="p_bio" rows="4">${doc.bio || ""}</textarea></div>
          </div>
          <div class="form-group"><label>Email (non modifiable)</label><input class="form-control" value="${escapeHtml(user.email || "")}" disabled style="opacity:.6;"></div>
          <button class="btn-save" id="saveProfileBtn">Enregistrer les modifications</button>
        </div>
      </div>
      <div id="tab-security" class="tab-pane">
        <div class="profile-card"><h3 style="margin-bottom:16px;">Changer le mot de passe</h3><div id="passwordAlert"></div>
          <div class="form-group"><label>Mot de passe actuel</label><input class="form-control" type="password" id="pwd_current" placeholder="8 caracteres minimum"></div>
          <div class="form-group"><label>Nouveau mot de passe</label><input class="form-control" type="password" id="pwd_new" placeholder="8 caracteres minimum" oninput="renderPwdStrength(this.value)">
            <div class="pwd-strength-bar"><div id="pwdBar" class="pwd-strength-fill"></div></div><small id="pwdLabel" style="color:var(--text-dim);"></small>
          </div>
          <div class="form-group"><label>Confirmer le nouveau mot de passe</label><input class="form-control" type="password" id="pwd_confirm" placeholder="8 caracteres minimum"></div>
          <button class="btn-save" id="savePwdBtn">Mettre a jour le mot de passe</button>
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
        .forEach((p) => p.classList.remove("active"));
      document.getElementById(`tab-${btn.dataset.tab}`).classList.add("active");
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
        alert.innerHTML = `<div class="alert-success">Profil mis a jour</div>`;
        setTimeout(() => (alert.innerHTML = ""), 3000);
      } catch (e) {
        alert.innerHTML = `<div class="alert-error">${e.message}</div>`;
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
      alert.innerHTML = `<div class="alert-error">Minimum 8 caracteres.</div>`;
      return;
    }
    try {
      await api.changePassword(current, newPwd);
      alert.innerHTML = `<div class="alert-success">Mot de passe modifie</div>`;
      ["pwd_current", "pwd_new", "pwd_confirm"].forEach(
        (id) => (document.getElementById(id).value = ""),
      );
      document.getElementById("pwdBar").style.width = "0%";
      setTimeout(() => (alert.innerHTML = ""), 3000);
    } catch (e) {
      alert.innerHTML = `<div class="alert-error">${e.message}</div>`;
    }
  });
}

async function loadWaitingQueuePage() {
  document.getElementById("pageSubtitle").textContent =
    "Gerez la file d'attente des patients";
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
            ? `<div class="patient-info-queue"><div class="patient-name">${inConsultation.patient?.fullName}</div>
          <div class="patient-details">${inConsultation.appointment?.appointmentTime ? `RDV: ${inConsultation.appointment.appointmentTime} | ` : ""}Arrive a: ${new Date(inConsultation.arrivedAt).toLocaleTimeString()}</div>
          <button class="btn-complete-consult" onclick="completeConsultation('${inConsultation.id}')">Terminer consultation</button></div>`
            : '<div class="empty-state">Aucune consultation en cours</div>'
        }
      </div>
      <div class="waiting-list-card">
        <div class="waiting-header"><h3><i class="fas fa-users"></i> Patients en attente (${waiting.length})</h3>
          <button class="btn-call-next" onclick="callNextPatient()">Appeler suivant</button>
        </div>
        <div class="waiting-list">${
          waiting.length
            ? waiting
                .map(
                  (
                    w,
                    index,
                  ) => `<div class="waiting-item priority-${w.priority}">
          <div class="waiting-position">${index + 1}</div>
          <div class="waiting-info"><div class="waiting-name">${w.patient?.fullName}</div>
            <div class="waiting-details">${w.appointment?.appointmentTime ? `RDV: ${w.appointment.appointmentTime} | ` : ""}Arrive: ${new Date(w.arrivedAt).toLocaleTimeString()}${w.priority === 0 ? '<span class="urgent-badge">URGENT</span>' : ""}</div>
          </div>
          <div class="waiting-actions"><button class="btn-urgent" onclick="setUrgent('${w.id}')"><i class="fas fa-ambulance"></i></button>
          <button class="btn-remove" onclick="removeFromQueue('${w.id}')"><i class="fas fa-trash"></i></button></div>
        </div>`,
                )
                .join("")
            : '<div class="empty-state">Aucun patient en attente</div>'
        }</div>
        <div class="add-patient-section"><button class="btn-add-patient" onclick="showAddToQueueModal()">Ajouter patient a la file</button></div>
      </div>
    </div>
  `);
}

async function callNextPatient() {
  const doctorId = api.getDoctorId();
  await api.request(`/waiting-queue/next?doctorId=${doctorId}`, {
    method: "PUT",
  });
  showToast("Patient suivant appele", "success");
  await loadWaitingQueue();
}

async function completeConsultation(queueId) {
  await api.request(`/waiting-queue/${queueId}/complete`, { method: "PUT" });
  showToast("Consultation terminee", "success");
  await loadWaitingQueue();
}

async function setUrgent(queueId) {
  await api.request(`/waiting-queue/${queueId}/priority`, {
    method: "PUT",
    body: JSON.stringify({ priority: 0 }),
  });
  showToast("Patient passe en urgence", "success");
  await loadWaitingQueue();
}

async function removeFromQueue(queueId) {
  if (!confirm("Retirer ce patient de la file d'attente ?")) return;
  await api.request(`/waiting-queue/${queueId}`, { method: "DELETE" });
  showToast("Patient retire de la file", "success");
  await loadWaitingQueue();
}

function showAddToQueueModal() {
  const patients = currentPatients;
  openModal(
    "Ajouter patient a la file",
    `
    <div class="form-group"><label>Selectionner un patient</label>
      <select id="queuePatientId" class="modal-input">
        <option value="">Choisir un patient...</option>
        ${patients.map((p) => `<option value="${p.id}">${p.fullName} - ${p.chifaNumber || "Pas de Chifa"}</option>`).join("")}
      </select>
    </div>
    <div class="form-group"><label>Priorite</label>
      <select id="queuePriority" class="modal-input">
        <option value="1">Normal (RDV)</option>
        <option value="2">Sans RDV</option>
        <option value="0">Urgence</option>
      </select>
    </div>
    <div class="form-group"><label>Notes</label><textarea id="queueNotes" class="modal-input" rows="2" placeholder="Motif, etc..."></textarea></div>
    <div class="modal-actions"><button class="btn-cancel-modal" onclick="closeModal()">Annuler</button><button class="btn-save-modal" onclick="saveAddToQueue()">Ajouter</button></div>
  `,
  );
}

async function saveAddToQueue() {
  const patientId = document.getElementById("queuePatientId").value;
  const priority = parseInt(document.getElementById("queuePriority").value);
  const notes = document.getElementById("queueNotes").value;
  if (!patientId) {
    alert("Veuillez selectionner un patient");
    return;
  }
  const doctorId = api.getDoctorId();
  await api.request("/waiting-queue", {
    method: "POST",
    body: JSON.stringify({ doctorId, patientId, priority, notes }),
  });
  closeModal();
  showToast("Patient ajoute a la file d'attente", "success");
  await loadWaitingQueue();
}

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
    .replace(
      /[&<>]/g,
      (m) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;" })[m] || m,
    )
    .replace(/['"]/g, (m) => ({ "'": "&#39;", '"': "&quot;" })[m] || m);
}

function renderPwdStrength(pwd) {
  let score = 0;
  if (pwd.length >= 8) score++;
  if (/[A-Z]/.test(pwd)) score++;
  if (/[0-9]/.test(pwd)) score++;
  if (/[^A-Za-z0-9]/.test(pwd)) score++;
  const levels = [
    { w: "0%", c: "transparent", t: "" },
    { w: "25%", c: "var(--rose)", t: "Trop faible" },
    { w: "50%", c: "var(--amber)", t: "Faible" },
    { w: "75%", c: "var(--blue)", t: "Moyen" },
    { w: "100%", c: "var(--green)", t: "Fort" },
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
  const colors = {
    success: "var(--green)",
    error: "var(--rose)",
    info: "var(--blue)",
  };
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

window.showMedicationDetails = () => {};
window.showStockForMedication = () => {};
window.showEditStockModal = () => {};
window.saveStock = () => {};
window.closeModal = closeModal;
window.navigateTo = navigateTo;
window.completeConsultation = completeConsultation;
window.callNextPatient = callNextPatient;
window.setUrgent = setUrgent;
window.removeFromQueue = removeFromQueue;
window.saveAddToQueue = saveAddToQueue;
window.showAddToQueueModal = showAddToQueueModal;
window.saveNewPatient = saveNewPatient;
window.saveConsultation = saveConsultation;
window.savePrescription = savePrescription;
window.toggleDayTimes = toggleDayTimes;
window.saveAvailability = saveAvailability;
