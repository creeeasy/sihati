let allAppointments = [];

document.addEventListener('DOMContentLoaded', async () => {
  const ok = await initPage();
  if (!ok) return;
  await loadAppointments();
});

async function loadAppointments() {
  showPageLoading();
  // Show skeleton while loading
  setContent(skeletonList(5));
  try {
    const res = await api.getDoctorAppointments();
    allAppointments = res.data || [];

    const counts = {
      '':          allAppointments.length,
      pending:     allAppointments.filter(a => a.status === 'pending').length,
      confirmed:   allAppointments.filter(a => a.status === 'confirmed').length,
      completed:   allAppointments.filter(a => a.status === 'completed').length,
      cancelled:   allAppointments.filter(a => a.status === 'cancelled').length,
    };

    setContent(`
      <div class="filter-tabs" id="apptTabs">
        <button class="tab-btn active" data-filter="">${t('all')} (${counts['']})</button>
        <button class="tab-btn" data-filter="pending">${t('filter_pending')} (${counts.pending})</button>
        <button class="tab-btn" data-filter="confirmed">${t('filter_confirmed')} (${counts.confirmed})</button>
        <button class="tab-btn" data-filter="completed">${t('filter_completed')} (${counts.completed})</button>
        <button class="tab-btn" data-filter="cancelled">${t('filter_cancelled')} (${counts.cancelled})</button>
      </div>
      <div id="apptList">
        ${allAppointments.length
          ? allAppointments.map(renderApptCard).join('')
          : `<div class="empty-state"><i class="fas fa-calendar"></i><p>${t('no_appointments')}</p></div>`}
      </div>
    `);

    bindApptButtons(allAppointments);

    document.querySelectorAll('#apptTabs .tab-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('#apptTabs .tab-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        const f = btn.dataset.filter;
        const list = f ? allAppointments.filter(a => a.status === f) : allAppointments;
        document.getElementById('apptList').innerHTML = list.length
          ? list.map(renderApptCard).join('')
          : `<div class="empty-state"><i class="fas fa-calendar"></i><p>${t('no_appointments')}</p></div>`;
        bindApptButtons(list);
      });
    });
  } catch (e) { pageError(e.message); }
  hidePageLoading();
}

function renderApptCard(a) {
  const STATUS = {
    pending: t('status_pending'), confirmed: t('status_confirmed'),
    cancelled: t('status_cancelled'), completed: t('status_completed'), no_show: t('status_no_show')
  };
  const date = formatDate(a.appointmentDate);
  const time = (a.appointmentTime || '').slice(0, 5);
  const patient = a.patient || {};
  const diff = Math.round((new Date(`${a.appointmentDate}T${a.appointmentTime}`) - new Date()) / 60000);
  const timeInfo = (diff > 0 && diff <= 60) ? `<span class="time-warning">${t('time_warning', { minutes: diff })}</span>` : '';

  let actions = '';
  if (a.status === 'pending') {
    actions = `<div class="appointment-actions">
      <button class="btn-sm btn-confirm" data-id="${a.id}" data-action="confirm">${t('confirm_btn')}</button>
      <button class="btn-sm btn-cancel"  data-id="${a.id}" data-action="cancel">${t('cancel_btn')}</button>
    </div>`;
  } else if (a.status === 'confirmed') {
    actions = `<div class="appointment-actions">
      <button class="btn-sm btn-cancel"   data-id="${a.id}" data-action="cancel">${t('cancel_btn')}</button>
      <button class="btn-sm btn-complete" data-id="${a.id}" data-action="complete">${t('complete_btn')}</button>
    </div>`;
  }

  return `<div class="appointment-card ${a.status}">
    <div class="appointment-header">
      <span class="patient-name">${patient.fullName || 'Patient'}</span>
      <span class="status-badge ${a.status}">${STATUS[a.status] || a.status}</span>
      ${timeInfo}
    </div>
    <div class="appointment-datetime"><i class="fas fa-clock"></i> ${date} à ${time}</div>
    ${patient.phoneNumber ? `<div class="appointment-reason"><i class="fas fa-phone"></i> ${t('phone_label')} ${patient.phoneNumber}</div>` : ''}
    ${a.reason ? `<div class="appointment-reason"><i class="fas fa-notes-medical"></i> ${t('reason_label')} ${a.reason}</div>` : ''}
    ${actions}
  </div>`;
}

function bindApptButtons(list) {
  document.querySelectorAll('[data-action]').forEach(btn => {
    btn.addEventListener('click', async () => {
      btn.classList.add('btn-loading');
      await doApptAction(btn.dataset.id, btn.dataset.action);
      btn.classList.remove('btn-loading');
    });
  });
}

async function doApptAction(id, action) {
  try {
    if (action === 'confirm') {
      await api.confirmAppointment(id); showToast(t('appoint_confirmed_toast'), 'success');
    } else if (action === 'cancel') {
      const reason = prompt(t('cancel_reason_prompt')) ?? '';
      await api.cancelAppointment(id, reason); showToast(t('appoint_cancelled_toast'), 'success');
    } else if (action === 'complete') {
      await api.completeAppointment(id); showToast(t('appoint_completed_toast'), 'success');
    }
    await loadAppointments();
  } catch (e) { showToast(e.message, 'error'); }
}

function setContent(html) { document.getElementById('pageContent').innerHTML = html; }
function pageError(msg)   { document.getElementById('pageContent').innerHTML = `<div class="empty-state"><i class="fas fa-exclamation-circle"></i><p>${msg}</p></div>`; }
