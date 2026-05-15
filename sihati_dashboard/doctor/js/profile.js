document.addEventListener('DOMContentLoaded', async () => {
  const ok = await initPage();
  if (!ok) return;
  await loadProfile();
});

async function loadProfile() {
  showPageLoading();
  // Show skeleton form while loading
  setContent(`
    <div class="profile-page">
      <div class="profile-card">
        <div class="profile-avatar-row">
          <div class="skeleton" style="width:60px;height:60px;border-radius:14px;flex-shrink:0;"></div>
          <div style="flex:1;">
            <div class="skeleton skeleton-text long"></div>
            <div class="skeleton skeleton-text short" style="margin-top:8px;"></div>
          </div>
        </div>
        <div class="form-grid-2">
          ${Array(6).fill('<div class="skeleton skeleton-text" style="height:44px;"></div>').join('')}
        </div>
      </div>
    </div>
  `);

  try {
    const res = await api.getCurrentDoctor();
    if (!res.success) { pageError('Impossible de charger le profil'); hidePageLoading(); return; }
    const doc  = res.data;
    const user = STORAGE.getUser() || {};

    setContent(`
      <div class="profile-page">
        <div class="profile-tabs" id="profileTabs">
          <button class="tab-btn active" data-tab="info">${t('info_tab')}</button>
          <button class="tab-btn"        data-tab="security">${t('security_tab')}</button>
        </div>
        <div id="tab-info" class="tab-pane active">
          <div class="profile-card">
            <div class="profile-avatar-row">
              <div class="profile-avatar-big">${(doc.doctorName || 'DR').slice(0, 2).toUpperCase()}</div>
              <div>
                <div style="font-weight:700;font-size:18px;">${doc.doctorName}</div>
                <div class="text-muted">${doc.specialty?.name || ''}</div>
                <span class="status-badge ${doc.isVerified ? 'confirmed' : 'pending'}" style="margin-top:6px;display:inline-flex;">
                  ${doc.isVerified ? t('profile_verified') : t('profile_pending')}
                </span>
              </div>
            </div>
            <div id="profileAlert"></div>
            <div class="form-grid-2">
              <div class="form-group"><label>${t('name_label')}</label><input class="form-control" id="p_name" value="${escapeHtml(doc.doctorName||'')}"></div>
              <div class="form-group"><label>${t('phone_office_label')}</label><input class="form-control" id="p_phone" value="${escapeHtml(doc.phone||'')}"></div>
              <div class="form-group"><label>${t('clinic_name_label')}</label><input class="form-control" id="p_clinic" value="${escapeHtml(doc.clinicName||'')}"></div>
              <div class="form-group"><label>${t('whatsapp_label')}</label><input class="form-control" id="p_whatsapp" value="${escapeHtml(doc.whatsappNumber||'')}"></div>
              <div class="form-group" style="grid-column:1/-1"><label>${t('address_label')}</label><input class="form-control" id="p_address" value="${escapeHtml(doc.clinicAddress||'')}"></div>
              <div class="form-group"><label>${t('fee_label')}</label><input class="form-control" type="number" id="p_fee" value="${doc.consultationFee||''}"></div>
              <div class="form-group"><label>${t('exp_label')}</label><input class="form-control" type="number" id="p_exp" value="${doc.yearsOfExperience||''}"></div>
              <div class="form-group" style="grid-column:1/-1"><label>${t('bio_label')}</label><textarea class="form-control" id="p_bio" rows="4">${doc.bio||''}</textarea></div>
            </div>
            <div class="form-group"><label>${t('email_label')}</label><input class="form-control" value="${escapeHtml(user.email||'')}" disabled style="opacity:.6;"></div>
            <button class="btn-save" id="saveProfileBtn"><i class="fas fa-save"></i> ${t('save_profile_btn')}</button>
          </div>
        </div>
        <div id="tab-security" class="tab-pane">
          <div class="profile-card">
            <h3 style="margin-bottom:16px;">${t('change_pwd_title')}</h3>
            <div id="passwordAlert"></div>
            <div class="form-group"><label>${t('current_pwd_label')}</label><input class="form-control" type="password" id="pwd_current" placeholder="8+ caractères"></div>
            <div class="form-group"><label>${t('new_pwd_label')}</label>
              <input class="form-control" type="password" id="pwd_new" placeholder="8+ caractères" oninput="renderPwdStrength(this.value)">
              <div class="pwd-strength-bar"><div id="pwdBar" class="pwd-strength-fill"></div></div>
              <small id="pwdLabel" style="color:var(--text-dim);"></small>
            </div>
            <div class="form-group"><label>${t('confirm_pwd_label')}</label><input class="form-control" type="password" id="pwd_confirm" placeholder="8+ caractères"></div>
            <button class="btn-save" id="savePwdBtn"><i class="fas fa-lock"></i> ${t('update_pwd_btn')}</button>
          </div>
        </div>
      </div>
    `);

    // Tab switching
    document.querySelectorAll('#profileTabs .tab-btn').forEach(btn =>
      btn.addEventListener('click', () => {
        document.querySelectorAll('#profileTabs .tab-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
        btn.classList.add('active');
        document.getElementById(`tab-${btn.dataset.tab}`).classList.add('active');
      })
    );

    // Save profile
    document.getElementById('saveProfileBtn').addEventListener('click', async () => {
      const alertEl = document.getElementById('profileAlert');
      const btn = document.getElementById('saveProfileBtn');
      alertEl.innerHTML = '';
      const data = {
        doctorName:        document.getElementById('p_name').value.trim(),
        clinicName:        document.getElementById('p_clinic').value.trim(),
        clinicAddress:     document.getElementById('p_address').value.trim(),
        phone:             document.getElementById('p_phone').value.trim(),
        whatsappNumber:    document.getElementById('p_whatsapp').value.trim(),
        consultationFee:   parseFloat(document.getElementById('p_fee').value) || null,
        yearsOfExperience: parseInt(document.getElementById('p_exp').value)   || null,
        bio:               document.getElementById('p_bio').value.trim()
      };
      if (!data.doctorName) { alertEl.innerHTML = `<div class="alert-error">${t('name_required')}</div>`; return; }
      btn.classList.add('btn-loading'); btn.disabled = true;
      try {
        await api.updateDoctorProfile(data);
        await loadSidebarProfile();
        alertEl.innerHTML = `<div class="alert-success">${t('profile_updated')}</div>`;
        setTimeout(() => alertEl.innerHTML = '', 3000);
      } catch (e) { alertEl.innerHTML = `<div class="alert-error">${e.message}</div>`; }
      finally { btn.classList.remove('btn-loading'); btn.disabled = false; }
    });

    // Save password
    document.getElementById('savePwdBtn').addEventListener('click', async () => {
      const alertEl = document.getElementById('passwordAlert');
      const btn = document.getElementById('savePwdBtn');
      alertEl.innerHTML = '';
      const current = document.getElementById('pwd_current').value;
      const newPwd  = document.getElementById('pwd_new').value;
      const confirm = document.getElementById('pwd_confirm').value;
      if (!current || !newPwd || !confirm) { alertEl.innerHTML = `<div class="alert-error">${t('fill_all_fields')}</div>`; return; }
      if (newPwd !== confirm) { alertEl.innerHTML = `<div class="alert-error">${t('passwords_mismatch')}</div>`; return; }
      if (newPwd.length < 8)  { alertEl.innerHTML = `<div class="alert-error">${t('pwd_min_length')}</div>`; return; }
      btn.classList.add('btn-loading'); btn.disabled = true;
      try {
        await api.changePassword(current, newPwd);
        alertEl.innerHTML = `<div class="alert-success">${t('pwd_updated')}</div>`;
        ['pwd_current','pwd_new','pwd_confirm'].forEach(id => document.getElementById(id).value = '');
        document.getElementById('pwdBar').style.width = '0%';
        setTimeout(() => alertEl.innerHTML = '', 3000);
      } catch (e) { alertEl.innerHTML = `<div class="alert-error">${e.message}</div>`; }
      finally { btn.classList.remove('btn-loading'); btn.disabled = false; }
    });
  } catch (e) { pageError(e.message); }
  hidePageLoading();
}

window.renderPwdStrength = function(pwd) {
  let score = 0;
  if (pwd.length >= 8)           score++;
  if (/[A-Z]/.test(pwd))        score++;
  if (/[0-9]/.test(pwd))        score++;
  if (/[^A-Za-z0-9]/.test(pwd)) score++;
  const levels = [
    { w: '0%',   c: 'transparent', tx: '' },
    { w: '25%',  c: 'var(--rose)',   tx: t('pwd_too_weak') },
    { w: '50%',  c: 'var(--amber)',  tx: t('pwd_weak') },
    { w: '75%',  c: 'var(--violet)', tx: t('pwd_medium') },
    { w: '100%', c: 'var(--green)',  tx: t('pwd_strong') },
  ];
  const lvl = levels[score] || levels[0];
  const bar = document.getElementById('pwdBar');
  const lbl = document.getElementById('pwdLabel');
  if (bar) { bar.style.width = lvl.w; bar.style.background = lvl.c; }
  if (lbl) { lbl.textContent = lvl.tx; lbl.style.color = lvl.c; }
};

function setContent(html) { document.getElementById('pageContent').innerHTML = html; }
function pageError(msg)   { document.getElementById('pageContent').innerHTML = `<div class="empty-state"><i class="fas fa-exclamation-circle"></i><p>${msg}</p></div>`; }
