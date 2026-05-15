let queuePatients = [];

document.addEventListener('DOMContentLoaded', async () => {
  const ok = await initPage();
  if (!ok) return;
  // Pre-load patients for the add-to-queue modal
  try {
    const res = await api.getDoctorAppointments();
    const map = new Map();
    (res.data || []).forEach(a => { if (a.patient && !map.has(a.patientId)) map.set(a.patientId, a.patient); });
    queuePatients = [...map.values()];
  } catch {}
  await loadWaitingQueue();
});

async function loadWaitingQueue() {
  showPageLoading();
  setContent(`<div class="waiting-queue-container">${skeletonList(2)}</div>`);
  try {
    const doctorId = api.getDoctorId();
    const res = await api.request(`/waiting-queue/doctor/${doctorId}`);
    const queue = res.data || [];
    const inConsultation = queue.find(q => q.status === 'in_consultation');
    const waiting        = queue.filter(q => q.status === 'waiting');

    setContent(`
      <div class="waiting-queue-container">
        <div class="current-consultation-card">
          <h3><i class="fas fa-stethoscope"></i> ${t('in_consultation')}</h3>
          ${inConsultation
            ? `<div class="patient-info-queue">
                <div class="patient-name">${inConsultation.patient?.fullName}</div>
                <div class="patient-details">
                  ${inConsultation.appointment?.appointmentTime ? `${t('rdv_label')}: ${inConsultation.appointment.appointmentTime} | ` : ''}
                  ${t('arrived_at')}: ${new Date(inConsultation.arrivedAt).toLocaleTimeString()}
                </div>
                <button class="btn-complete-consult" id="completeBtn" data-id="${inConsultation.id}">
                  <i class="fas fa-check-circle"></i> Terminer consultation
                </button>
              </div>`
            : `<div class="empty-state" style="padding:24px 0;">${t('no_consultation')}</div>`}
        </div>

        <div class="waiting-list-card">
          <div class="waiting-header">
            <h3><i class="fas fa-users"></i> ${t('patients_waiting')} (${waiting.length})</h3>
            <button class="btn-call-next" id="callNextBtn">
              <i class="fas fa-bell"></i> ${t('call_next')}
            </button>
          </div>
          <div class="waiting-list">
            ${waiting.length
              ? waiting.map((w, i) => `
                  <div class="waiting-item priority-${w.priority}">
                    <div class="waiting-position">${i + 1}</div>
                    <div class="waiting-info">
                      <div class="waiting-name">${w.patient?.fullName}</div>
                      <div class="waiting-details">
                        ${w.appointment?.appointmentTime ? `${t('rdv_label')}: ${w.appointment.appointmentTime} | ` : ''}
                        ${t('arrived_at')}: ${new Date(w.arrivedAt).toLocaleTimeString()}
                        ${w.priority === 0 ? `<span class="urgent-badge">${t('urgent_badge')}</span>` : ''}
                      </div>
                    </div>
                    <div class="waiting-actions">
                      <button class="btn-urgent" data-queue-id="${w.id}" title="Urgence"><i class="fas fa-ambulance"></i></button>
                      <button class="btn-remove" data-queue-id="${w.id}" title="Retirer"><i class="fas fa-trash"></i></button>
                    </div>
                  </div>`).join('')
              : `<div class="empty-state" style="padding:24px 0;">${t('no_waiting')}</div>`}
          </div>
          <div class="add-patient-section">
            <button class="btn-add-patient" id="addToQueueBtn">
              <i class="fas fa-user-plus"></i> ${t('add_to_queue')}
            </button>
          </div>
        </div>
      </div>
    `);

    // Bind buttons
    document.getElementById('completeBtn')?.addEventListener('click', async e => {
      const btn = e.currentTarget;
      btn.classList.add('btn-loading'); btn.disabled = true;
      await completeConsultation(btn.dataset.id);
    });

    document.getElementById('callNextBtn')?.addEventListener('click', async e => {
      const btn = e.currentTarget;
      btn.classList.add('btn-loading'); btn.disabled = true;
      await callNextPatient();
    });

    document.querySelectorAll('.btn-urgent').forEach(btn =>
      btn.addEventListener('click', async () => {
        btn.classList.add('btn-loading');
        await setUrgent(btn.dataset.queueId);
      })
    );

    document.querySelectorAll('.btn-remove').forEach(btn =>
      btn.addEventListener('click', async () => {
        if (!confirm(t('remove_confirm'))) return;
        btn.classList.add('btn-loading');
        await removeFromQueue(btn.dataset.queueId);
      })
    );

    document.getElementById('addToQueueBtn')?.addEventListener('click', () =>
      showAddToQueueModal(queuePatients)
    );

  } catch (e) { pageError(e.message); }
  hidePageLoading();
}

async function callNextPatient() {
  try {
    const doctorId = api.getDoctorId();
    await api.request(`/waiting-queue/next?doctorId=${doctorId}`, { method: 'PUT' });
    showToast(t('call_next'), 'success');
  } catch (e) { showToast(e.message, 'error'); }
  await loadWaitingQueue();
}

async function completeConsultation(queueId) {
  try {
    await api.request(`/waiting-queue/${queueId}/complete`, { method: 'PUT' });
    showToast(t('appoint_completed_toast'), 'success');
  } catch (e) { showToast(e.message, 'error'); }
  await loadWaitingQueue();
}

async function setUrgent(queueId) {
  try {
    await api.request(`/waiting-queue/${queueId}/priority`, { method: 'PUT', body: JSON.stringify({ priority: 0 }) });
    showToast(t('urgent_badge'), 'info');
  } catch (e) { showToast(e.message, 'error'); }
  await loadWaitingQueue();
}

async function removeFromQueue(queueId) {
  try {
    await api.request(`/waiting-queue/${queueId}`, { method: 'DELETE' });
    showToast(t('no_waiting'), 'success');
  } catch (e) { showToast(e.message, 'error'); }
  await loadWaitingQueue();
}

window.saveAddToQueue = async function() {
  const patientId = document.getElementById('queuePatientId').value;
  const priority  = parseInt(document.getElementById('queuePriority').value);
  const notes     = document.getElementById('queueNotes').value;
  if (!patientId) { alert(t('select_patient')); return; }
  const btn = document.querySelector('#modalBody .btn-save-modal');
  if (btn) btn.classList.add('btn-loading');
  try {
    const doctorId = api.getDoctorId();
    await api.request('/waiting-queue', { method: 'POST', body: JSON.stringify({ doctorId, patientId, priority, notes }) });
    closeModal(); showToast(t('add_to_queue'), 'success');
    await loadWaitingQueue();
  } catch (e) { showToast(e.message, 'error'); }
  finally { if (btn) btn.classList.remove('btn-loading'); }
};

function setContent(html) { document.getElementById('pageContent').innerHTML = html; }
function pageError(msg)   { document.getElementById('pageContent').innerHTML = `<div class="empty-state"><i class="fas fa-exclamation-circle"></i><p>${msg}</p></div>`; }
window.closeModal = closeModal;
window.showAddToQueueModal = showAddToQueueModal;
