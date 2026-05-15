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
      <button class="btn-save-modal" onclick="window.saveNewPatient()">Enregistrer</button>
    </div>
  `,
  );
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
      <button class="btn-save-modal" onclick="window.saveConsultation('${patientId}')">Enregistrer</button>
    </div>
  `,
  );
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
    <div class="form-group"><label>Renouvelable</label>
      <select class="modal-input" id="p_renewable">
        <option value="false">Non</option>
        <option value="true">Oui</option>
      </select>
    </div>
    <div class="modal-actions">
      <button class="btn-cancel-modal" onclick="closeModal()">Annuler</button>
      <button class="btn-save-modal" onclick="window.savePrescription('${patientId}')">Enregistrer</button>
    </div>
  `,
  );
  const addBtn = document.getElementById("addMedBtn");
  if (addBtn) {
    addBtn.addEventListener("click", () => {
      document
        .getElementById("medicationsList")
        .insertAdjacentHTML("beforeend", medicationRow());
    });
  }
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

function showAddToQueueModal(patients) {
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
    <div class="modal-actions"><button class="btn-cancel-modal" onclick="closeModal()">Annuler</button><button class="btn-save-modal" onclick="window.saveAddToQueue()">Ajouter</button></div>
  `,
  );
}
