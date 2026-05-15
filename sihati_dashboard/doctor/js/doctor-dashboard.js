let currentDoctor = null;

document.addEventListener('DOMContentLoaded', async () => {
  const ok = await initPage(); // from shared.js
  if (!ok) return;
  currentDoctor = await loadSidebarProfile();
  await loadDashboard();
});

async function loadDashboard() {
  showPageLoading();
  try {
    const [statsRes, apptRes] = await Promise.all([
      api.getDoctorStats(),
      api.getDoctorAppointments()
    ]);
    const stats = statsRes;
    const appointments = apptRes.data || [];
    const upcoming = appointments
      .filter(a => a.status === 'pending' || a.status === 'confirmed')
      .sort((a, b) => new Date(a.appointmentDate) - new Date(b.appointmentDate))
      .slice(0, 5);

    const hour = new Date().getHours();
    const greeting = hour < 12 ? t('greeting_morning') : hour < 18 ? t('greeting_afternoon') : t('greeting_evening');
    const locale = currentLang === 'ar' ? 'ar-DZ' : 'fr-FR';
    const today = new Date().toLocaleDateString(locale, { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });

    setContent(`
      <div class="welcome-header">
        <div>
          <h2>${greeting}, ${currentDoctor?.doctorName?.split(' ')[0] || 'Docteur'} 👋</h2>
          <p class="text-muted">${today}</p>
        </div>
        <div class="revenue-chip">
          <i class="fas fa-coins"></i> ${t('revenue_today')}: ${formatCurrency(stats.todayRevenue)}
        </div>
      </div>
      <div class="stats-grid">
        ${skeletonIfNull(stats.total,     'primary', 'fa-calendar-check',  t('total_appointments'))}
        ${skeletonIfNull(stats.pending,   'warning', 'fa-hourglass-half',  t('pending_appointments'))}
        ${skeletonIfNull(stats.confirmed, 'success', 'fa-check-circle',    t('confirmed_appointments'))}
        ${skeletonIfNull(stats.completed, 'info',    'fa-stethoscope',     t('completed_appointments'))}
        ${skeletonIfNull(stats.cancelled, 'danger',  'fa-times-circle',    t('cancelled_appointments'))}
        ${skeletonIfNull(stats.averageRating === 'NaN' ? '0' : stats.averageRating, 'purple', 'fa-star', t('average_rating'))}
      </div>
      <div class="card">
        <div class="card-header">
          <div class="card-title">
            <div class="card-title-icon violet"><i class="fas fa-calendar-alt"></i></div>
            ${t('upcoming_appointments')}
          </div>
          <a href="appointments.html" class="link-more">${t('view_all')} →</a>
        </div>
        <div class="card-body">
          ${upcoming.length
            ? upcoming.map(renderApptCard).join('')
            : `<div class="empty-state"><i class="fas fa-calendar-check"></i><p>${t('no_upcoming')}</p></div>`}
        </div>
      </div>
    `);
    bindApptButtons(upcoming);
  } catch (e) {
    pageError(e.message);
  }
  hidePageLoading();
}

function skeletonIfNull(value, color, icon, label) {
  if (value === undefined || value === null) {
    return `<div class="stat-card ${color} skeleton skeleton-stat"></div>`;
  }
  return statCard(color, icon, value, label);
}

function statCard(color, icon, value, label) {
  const v = (value === '–' || value === undefined) ? '0' : value;
  return `<div class="stat-card ${color}">
    <div class="stat-icon ${color}"><i class="fas ${icon}"></i></div>
    <div class="stat-value">${v ?? '0'}</div>
    <div class="stat-label">${label}</div>
  </div>`;
}

function renderApptCard(a) {
  const STATUS = {
    pending: t('status_pending'), confirmed: t('status_confirmed'),
    cancelled: t('status_cancelled'), completed: t('status_completed'), no_show: t('status_no_show')
  };
  const date = formatDate(a.appointmentDate);
  const time = (a.appointmentTime || '').slice(0, 5);
  const patient = a.patient || {};
  const now = new Date();
  const apptDT = new Date(`${a.appointmentDate}T${a.appointmentTime}`);
  const diff = Math.round((apptDT - now) / 60000);
  const timeInfo = (diff > 0 && diff <= 60)
    ? `<span class="time-warning">${t('time_warning', { minutes: diff })}</span>`
    : '';

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
    await loadDashboard();
  } catch (e) { showToast(e.message, 'error'); }
}

function setContent(html) { document.getElementById('pageContent').innerHTML = html; }
function pageError(msg) {
  document.getElementById('pageContent').innerHTML =
    `<div class="empty-state"><i class="fas fa-exclamation-circle"></i><p>${msg}</p></div>`;
}

window.closeModal = closeModal;
