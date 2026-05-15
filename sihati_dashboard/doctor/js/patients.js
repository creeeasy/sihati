let allAppointments = [];
let currentPatients  = [];

document.addEventListener('DOMContentLoaded', async () => {
  const ok = await initPage();
  if (!ok) return;
  showPageLoading();
  await loadPatients();
});

async function loadPatients() {
  showPageLoading();
  try {
    const res = await api.getDoctorAppointments();
    allAppointments = res.data || [];
    const map = new Map();
    allAppointments.forEach(a => { if (a.patient && !map.has(a.patientId)) map.set(a.patientId, a.patient); });
    currentPatients = [...map.values()];
    renderPatientsPage(currentPatients);
  } catch (e) { pageError(e.message); }
  hidePageLoading();
}

function renderPatientsPage(patients) {
  setContent(`
    <div class="patients-toolbar">
      <div class="search-bar">
        <i class="fas fa-search"></i>
        <input type="text" id="patientSearchInput" placeholder="${t('search_placeholder')}">
      </div>
      <button class="btn-primary-sm" id="addPatientBtn">
        <i class="fas fa-user-plus"></i> ${t('add_patient_btn')}
      </button>
    </div>
    <div id="patientsList">${renderPatientCards(patients)}</div>
  `);

  let timer;
  document.getElementById('patientSearchInput').addEventListener('input', e => {
    clearTimeout(timer);
    timer = setTimeout(async () => {
      const q = e.target.value.trim();
      if (!q) { document.getElementById('patientsList').innerHTML = renderPatientCards(currentPatients); bindPatientButtons(); return; }
      document.getElementById('patientsList').innerHTML = skeletonList(3);
      try {
        const res = await api.searchPatientsByChifa(q);
        document.getElementById('patientsList').innerHTML = renderPatientCards(res.data || []);
        bindPatientButtons();
      } catch {
        document.getElementById('patientsList').innerHTML =
          `<div class="empty-state"><i class="fas fa-exclamation-circle"></i><p>${t('error_loading')}</p></div>`;
      }
    }, 500);
  });

  document.getElementById('addPatientBtn').addEventListener('click', () => showAddPatientModal());
  bindPatientButtons();
}

function renderPatientCards(patients) {
  if (!patients.length) return `<div class="empty-state"><i class="fas fa-users"></i><p>${t('no_patients')}</p></div>`;
  return patients.map(p => `
    <div class="patient-card">
      <div class="patient-avatar-ring">${(p.fullName || '?').slice(0, 2).toUpperCase()}</div>
      <div class="patient-info">
        <h4>${p.fullName || t('patient_name_unknown')}</h4>
        <p><i class="fas fa-phone"></i> ${p.phoneNumber || t('phone_not_provided')}</p>
        <p><i class="fas fa-id-card"></i> Chifa: ${p.chifaNumber || t('chifa_not_provided')}</p>
      </div>
      <div class="patient-actions">
        <button class="btn-view"         data-patient-id="${p.id}" data-patient-name="${escapeHtml(p.fullName||'')}"><i class="fas fa-eye"></i> ${t('view_details')}</button>
        <button class="btn-consult"      data-patient-id="${p.id}" data-patient-name="${escapeHtml(p.fullName||'')}"><i class="fas fa-stethoscope"></i> ${t('consultation')}</button>
        <button class="btn-prescription" data-patient-id="${p.id}" data-patient-name="${escapeHtml(p.fullName||'')}"><i class="fas fa-file-medical"></i> ${t('prescription')}</button>
      </div>
    </div>`).join('');
}

function bindPatientButtons() {
  document.querySelectorAll('.btn-view').forEach(btn =>
    btn.addEventListener('click', () => window.open(`patient-details.html?id=${btn.dataset.patientId}`, '_blank')));
  document.querySelectorAll('.btn-consult').forEach(btn =>
    btn.addEventListener('click', () => showConsultationModal(btn.dataset.patientId, btn.dataset.patientName)));
  document.querySelectorAll('.btn-prescription').forEach(btn =>
    btn.addEventListener('click', () => showPrescriptionModal(btn.dataset.patientId, btn.dataset.patientName)));
}

window.saveNewPatient = async function() {
  const alertEl = document.getElementById('addPatientAlert');
  const data = {
    fullName: document.getElementById('np_name').value.trim(),
    email: document.getElementById('np_email').value.trim(),
    phoneNumber: document.getElementById('np_phone').value.trim(),
    chifaNumber: document.getElementById('np_chifa').value.trim() || undefined,
    password: document.getElementById('np_pwd').value,
    role: 'patient'
  };
  if (!data.fullName || !data.email || !data.phoneNumber || !data.password) {
    alertEl.innerHTML = `<div class="alert-error">${t('fill_all_fields')}</div>`; return;
  }
  if (data.password.length < 8) {
    alertEl.innerHTML = `<div class="alert-error">${t('pwd_min_length')}</div>`; return;
  }
  const btn = document.querySelector('#modalBody .btn-save-modal');
  if (btn) btn.classList.add('btn-loading');
  try {
    await api.createPatient(data);
    closeModal(); showToast(t('patient_created') || 'Patient créé', 'success');
    await loadPatients();
  } catch(e) {
    alertEl.innerHTML = `<div class="alert-error">${e.message}</div>`;
  } finally { if (btn) btn.classList.remove('btn-loading'); }
};

window.saveConsultation = async function(patientId) {
  const alertEl = document.getElementById('consultAlert');
  const chiefComplaint = document.getElementById('c_complaint').value.trim();
  if (!chiefComplaint) { alertEl.innerHTML = `<div class="alert-error">${t('fill_all_fields')}</div>`; return; }
  const data = {
    patientId, chiefComplaint,
    diagnosis:     document.getElementById('c_diagnosis').value.trim(),
    treatmentPlan: document.getElementById('c_treatment').value.trim(),
    notes:         document.getElementById('c_notes').value.trim(),
    feePaid: parseFloat(document.getElementById('c_fee').value) || null
  };
  const btn = document.querySelector('#modalBody .btn-save-modal');
  if (btn) btn.classList.add('btn-loading');
  try {
    await api.createConsultation(data);
    closeModal(); showToast(t('consultation_saved') || 'Consultation enregistrée', 'success');
    await loadPatients();
  } catch(e) { alertEl.innerHTML = `<div class="alert-error">${e.message}</div>`; }
  finally { if (btn) btn.classList.remove('btn-loading'); }
};

window.savePrescription = async function(patientId) {
  const alertEl = document.getElementById('prescAlert');
  const rows = document.querySelectorAll('.medication-row');
  const medications = [];
  let valid = true;
  rows.forEach(row => {
    const name = row.querySelector('.med-name')?.value.trim();
    if (!name) { valid = false; return; }
    medications.push({ name, dosage: row.querySelector('.med-dosage')?.value.trim(), frequency: row.querySelector('.med-frequency')?.value.trim(), durationDays: row.querySelector('.med-duration')?.value.trim() });
  });
  if (!valid || !medications.length) { alertEl.innerHTML = `<div class="alert-error">${t('add_medication') || 'Ajoutez au moins un médicament'}</div>`; return; }
  const data = { patientId, doctorId: api.getDoctorId(), diagnosis: document.getElementById('p_diagnosis').value.trim(), medications, instructions: document.getElementById('p_instructions').value.trim(), validityDays: 30, isRenewable: document.getElementById('p_renewable')?.value === 'true' };
  const btn = document.querySelector('#modalBody .btn-save-modal');
  if (btn) btn.classList.add('btn-loading');
  try {
    await api.createPrescription(data);
    closeModal(); showToast(t('prescription_saved') || 'Ordonnance enregistrée', 'success');
    await loadPatients();
  } catch(e) { alertEl.innerHTML = `<div class="alert-error">${e.message}</div>`; }
  finally { if (btn) btn.classList.remove('btn-loading'); }
};

function setContent(html) { document.getElementById('pageContent').innerHTML = html; }
function pageError(msg) { document.getElementById('pageContent').innerHTML = `<div class="empty-state"><i class="fas fa-exclamation-circle"></i><p>${msg}</p></div>`; }
window.closeModal = closeModal;
