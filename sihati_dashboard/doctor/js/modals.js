function openModal(title, bodyHTML) {
  const modal   = document.getElementById('modalOverlay');
  const titleEl = document.getElementById('modalTitle');
  const bodyEl  = document.getElementById('modalBody');
  if (!modal || !titleEl || !bodyEl) return;
  titleEl.textContent = title;
  bodyEl.innerHTML    = bodyHTML;
  modal.style.display = 'flex';
}

function closeModal() {
  const modal = document.getElementById('modalOverlay');
  if (modal) modal.style.display = 'none';
}

function showAddPatientModal() {
  openModal(t('modal_new_patient'), `
    <div id="addPatientAlert"></div>
    <div class="form-group">
      <label>${t('full_name_label')}</label>
      <input class="modal-input" type="text" id="np_name" placeholder="Mohammed Benali">
    </div>
    <div class="form-group">
      <label>${t('email_label_modal')}</label>
      <input class="modal-input" type="email" id="np_email" placeholder="patient@mail.com">
    </div>
    <div class="form-group">
      <label>${t('phone_label_modal')}</label>
      <input class="modal-input" type="tel" id="np_phone" placeholder="0555123456">
    </div>
    <div class="form-group">
      <label>${t('chifa_label_modal')}</label>
      <input class="modal-input" type="text" id="np_chifa" placeholder="${t('optional') || 'Optionnel'}">
    </div>
    <div class="form-group">
      <label>${t('password_label_modal')}</label>
      <input class="modal-input" type="password" id="np_pwd" placeholder="8+ ${t('characters') || 'caractères'}">
    </div>
    <div class="modal-actions">
      <button class="btn-cancel-modal" onclick="closeModal()">${t('cancel_modal')}</button>
      <button class="btn-save-modal"   onclick="window.saveNewPatient()">${t('save_btn')}</button>
    </div>
  `);
}

function showConsultationModal(patientId, patientName) {
  openModal(`${t('modal_consultation')} — ${patientName || 'Patient'}`, `
    <div id="consultAlert"></div>
    <div class="form-group">
      <label>${t('chief_complaint')}</label>
      <input class="modal-input" type="text" id="c_complaint" placeholder="Ex: Douleurs abdominales">
    </div>
    <div class="form-group">
      <label>${t('diagnosis')}</label>
      <textarea class="modal-input" id="c_diagnosis" rows="3" placeholder="${t('diagnosis')}..."></textarea>
    </div>
    <div class="form-group">
      <label>${t('treatment_plan')}</label>
      <textarea class="modal-input" id="c_treatment" rows="3" placeholder="${t('treatment_plan')}..."></textarea>
    </div>
    <div class="form-group">
      <label>${t('notes')}</label>
      <textarea class="modal-input" id="c_notes" rows="2" placeholder="${t('notes')}..."></textarea>
    </div>
    <div class="form-group">
      <label>${t('fee_modal')}</label>
      <input class="modal-input" type="number" id="c_fee" placeholder="3000">
    </div>
    <div class="modal-actions">
      <button class="btn-cancel-modal" onclick="closeModal()">${t('cancel_modal')}</button>
      <button class="btn-save-modal"   onclick="window.saveConsultation('${patientId}')">${t('save_btn')}</button>
    </div>
  `);
}

function showPrescriptionModal(patientId, patientName) {
  openModal(`${t('modal_prescription')} — ${patientName || 'Patient'}`, `
    <div id="prescAlert"></div>
    <div class="form-group">
      <label>${t('diagnosis')}</label>
      <input class="modal-input" type="text" id="p_diagnosis" placeholder="${t('diagnosis')}...">
    </div>
    <div id="medicationsList">${medicationRow()}</div>
    <button class="btn-add-med" id="addMedBtn">
      <i class="fas fa-plus"></i> ${t('add_medication')}
    </button>
    <div class="form-group">
      <label>${t('instructions')}</label>
      <textarea class="modal-input" id="p_instructions" rows="2" placeholder="${t('instructions')}..."></textarea>
    </div>
    <div class="form-group">
      <label>${t('renewable')}</label>
      <select class="modal-input" id="p_renewable">
        <option value="false">${t('no')}</option>
        <option value="true">${t('yes')}</option>
      </select>
    </div>
    <div class="modal-actions">
      <button class="btn-cancel-modal" onclick="closeModal()">${t('cancel_modal')}</button>
      <button class="btn-save-modal"   onclick="window.savePrescription('${patientId}')">${t('save_btn')}</button>
    </div>
  `);
  document.getElementById('addMedBtn')?.addEventListener('click', () =>
    document.getElementById('medicationsList').insertAdjacentHTML('beforeend', medicationRow())
  );
}

function medicationRow() {
  return `<div class="medication-row">
    <input class="med-input med-name"      type="text" placeholder="${t('medication_name')}">
    <input class="med-input med-dosage"    type="text" placeholder="${t('dosage')}">
    <input class="med-input med-frequency" type="text" placeholder="${t('frequency')}">
    <input class="med-input med-duration"  type="text" placeholder="${t('duration')}">
    <button class="btn-remove-med" onclick="this.closest('.medication-row').remove()">✕</button>
  </div>`;
}

function showAddToQueueModal(patients) {
  openModal(t('modal_add_to_queue'), `
    <div class="form-group">
      <label>${t('select_patient')}</label>
      <select id="queuePatientId" class="modal-input">
        <option value="">${t('select_patient')}</option>
        ${(patients || []).map(p => `<option value="${p.id}">${p.fullName} — ${p.chifaNumber || 'N/A'}</option>`).join('')}
      </select>
    </div>
    <div class="form-group">
      <label>${t('priority')}</label>
      <select id="queuePriority" class="modal-input">
        <option value="1">${t('priority_normal')}</option>
        <option value="2">${t('priority_walkin')}</option>
        <option value="0">${t('priority_urgent')}</option>
      </select>
    </div>
    <div class="form-group">
      <label>${t('notes_queue')}</label>
      <textarea id="queueNotes" class="modal-input" rows="2" placeholder="${t('notes')}..."></textarea>
    </div>
    <div class="modal-actions">
      <button class="btn-cancel-modal" onclick="closeModal()">${t('cancel_modal')}</button>
      <button class="btn-save-modal"   onclick="window.saveAddToQueue()">${t('save_btn')}</button>
    </div>
  `);
}

// ── Expose as globals for onclick attributes ────────────────────────────────
window.openModal             = openModal;
window.closeModal            = closeModal;
window.showConsultationModal = showConsultationModal;
window.showPrescriptionModal = showPrescriptionModal;
window.showAddPatientModal   = showAddPatientModal;
window.showAddToQueueModal   = showAddToQueueModal;
