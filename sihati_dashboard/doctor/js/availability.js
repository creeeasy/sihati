document.addEventListener('DOMContentLoaded', async () => {
  const ok = await initPage();
  if (!ok) return;
  await loadAvailability();
});

async function loadAvailability() {
  showPageLoading();
  // Show skeleton grid while loading
  setContent(`
    <div class="card">
      <div class="card-header">
        <div class="card-title"><div class="card-title-icon violet"><i class="fas fa-calendar-check"></i></div>${t('schedule_heading')}</div>
      </div>
      <div class="card-body">
        <p class="text-muted" style="margin-bottom:16px;">${t('schedule_description')}</p>
        <div class="schedule-grid">${skeletonList(7).replace(/skeleton-row/g, 'skeleton skeleton-stat')}</div>
      </div>
    </div>
  `);

  const DAYS = t('days');
  let schedule = [];
  try {
    const res = await api.getDoctorSchedule();
    if (res.success) schedule = res.data || [];
  } catch {}

  const schedMap = {};
  schedule.forEach(s => { schedMap[s.dayOfWeek] = s; });

  setContent(`
    <div class="card">
      <div class="card-header">
        <div class="card-title"><div class="card-title-icon violet"><i class="fas fa-calendar-check"></i></div>${t('schedule_heading')}</div>
      </div>
      <div class="card-body">
        <p class="text-muted" style="margin-bottom:16px;">${t('schedule_description')}</p>
        <div class="schedule-grid" id="schedGrid">
          ${DAYS.map((day, i) => {
            const dayNum = i + 1;
            const s = schedMap[dayNum];
            const isOn  = s ? s.isAvailable !== false : dayNum <= 5;
            const start = s?.startTime?.slice(0, 5) || '08:30';
            const end   = s?.endTime?.slice(0, 5)   || '17:00';
            return `<div class="schedule-card" data-day="${dayNum}">
              <div class="schedule-day-toggle">
                <label class="toggle-switch">
                  <input type="checkbox" class="off-day" ${isOn ? 'checked' : ''} onchange="toggleDayTimes(this,${dayNum})">
                  <span class="toggle-slider"></span>
                </label>
                <h4>${day}</h4>
              </div>
              <div class="time-slots" id="times-${dayNum}" style="${isOn ? '' : 'opacity:.35;pointer-events:none;'}">
                <input type="time" class="start-time" value="${start}">
                <span>à</span>
                <input type="time" class="end-time"   value="${end}">
              </div>
            </div>`;
          }).join('')}
        </div>
        <button class="btn-save-schedule" id="saveSchedBtn">
          <i class="fas fa-save"></i> ${t('save_schedule_btn')}
        </button>
      </div>
    </div>
  `);

  document.getElementById('saveSchedBtn').addEventListener('click', saveAvailability);
  hidePageLoading();
}

window.toggleDayTimes = function(checkbox, dayNum) {
  const el = document.getElementById(`times-${dayNum}`);
  el.style.opacity = checkbox.checked ? '1' : '.35';
  el.style.pointerEvents = checkbox.checked ? '' : 'none';
};

async function saveAvailability() {
  const btn = document.getElementById('saveSchedBtn');
  btn.classList.add('btn-loading');
  btn.disabled = true;
  const savingText = t('saving_schedule');
  const origHTML = btn.innerHTML;
  btn.innerHTML = `<i class="fas fa-spinner fa-spin"></i> ${savingText}`;

  const schedules = [];
  document.querySelectorAll('.schedule-card').forEach(card => {
    const dayOfWeek = parseInt(card.dataset.day);
    const isOn      = card.querySelector('.off-day').checked;
    const startTime = card.querySelector('.start-time').value || '00:00';
    const endTime   = card.querySelector('.end-time').value   || '00:00';
    schedules.push({ dayOfWeek, startTime: isOn ? startTime : '00:00', endTime: isOn ? endTime : '00:00', isAvailable: isOn });
  });

  try {
    await api.updateDoctorSchedule(schedules);
    showToast(t('schedule_saved'), 'success');
  } catch (e) {
    showToast(e.message, 'error');
  } finally {
    btn.disabled = false;
    btn.classList.remove('btn-loading');
    btn.innerHTML = origHTML;
  }
}

function setContent(html) { document.getElementById('pageContent').innerHTML = html; }
