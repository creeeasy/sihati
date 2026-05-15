// pharmacy/js/ph-profile.js
document.addEventListener('DOMContentLoaded', async () => {
  const ok = await phInitPage();
  if (!ok) return;
  await loadPhProfile();
});

async function loadPhProfile() {
  // Skeleton while loading
  document.getElementById('pageContent').innerHTML = `
    <div class="profile-card">
      <div class="profile-header">
        <div class="skeleton" style="width:56px;height:56px;border-radius:14px;flex-shrink:0;"></div>
        <div style="flex:1;">
          <div class="skeleton skeleton-text" style="width:55%;height:18px;margin-bottom:8px;"></div>
          <div class="skeleton skeleton-text short"></div>
        </div>
      </div>
      <div class="form-grid">
        ${Array(6).fill('<div class="skeleton skeleton-text" style="height:44px;"></div>').join('')}
      </div>
    </div>
  `;

  try {
    const res = await api.getCurrentPharmacy();
    if (!res.success) { phShowError('Impossible de charger le profil'); return; }
    const ph = res.data;

    document.getElementById('pageContent').innerHTML = `
      <div class="profile-card">
        <div class="profile-header">
          <div class="profile-avatar">${(ph.pharmacyName || 'PH').slice(0, 2).toUpperCase()}</div>
          <div class="profile-info">
            <h2>${ph.pharmacyName || ''}</h2>
            <p class="verified-badge ${ph.isVerified ? 'verified' : 'pending'}">
              <i class="fas ${ph.isVerified ? 'fa-check-circle' : 'fa-clock'}"></i>
              ${ph.isVerified ? pt('verified') : pt('pending_verif')}
            </p>
          </div>
        </div>
        <div id="profileAlert"></div>
        <div class="form-grid">
          <div class="form-group">
            <label>${pt('pharmacy_name')}</label>
            <input id="p_name" class="form-control" value="${phEscapeHtml(ph.pharmacyName || '')}">
          </div>
          <div class="form-group">
            <label>${pt('phone')}</label>
            <input id="p_phone" class="form-control" value="${phEscapeHtml(ph.phone || '')}">
          </div>
          <div class="form-group">
            <label>${pt('whatsapp')}</label>
            <input id="p_whatsapp" class="form-control" value="${phEscapeHtml(ph.whatsappNumber || '')}">
          </div>
          <div class="form-group">
            <label>${pt('email')}</label>
            <input id="p_email" class="form-control" value="${phEscapeHtml(ph.email || '')}">
          </div>
          <div class="form-group">
            <label>${pt('wilaya')}</label>
            <input id="p_wilaya" class="form-control" value="${phEscapeHtml(ph.wilaya || '')}">
          </div>
          <div class="form-group">
            <label>${pt('commune')}</label>
            <input id="p_commune" class="form-control" value="${phEscapeHtml(ph.commune || '')}">
          </div>
          <div class="form-group full-width">
            <label>${pt('address')}</label>
            <input id="p_address" class="form-control" value="${phEscapeHtml(ph.address || '')}">
          </div>
        </div>
        <button id="saveProfileBtn" class="btn-save">
          <i class="fas fa-save"></i> ${pt('save_changes')}
        </button>
      </div>
    `;

    document.getElementById('saveProfileBtn').addEventListener('click', async () => {
      const alertEl = document.getElementById('profileAlert');
      const btn     = document.getElementById('saveProfileBtn');
      alertEl.innerHTML = '';

      const data = {
        pharmacyName:  document.getElementById('p_name').value.trim(),
        phone:         document.getElementById('p_phone').value.trim(),
        whatsappNumber:document.getElementById('p_whatsapp').value.trim(),
        email:         document.getElementById('p_email').value.trim(),
        wilaya:        document.getElementById('p_wilaya').value.trim(),
        commune:       document.getElementById('p_commune').value.trim(),
        address:       document.getElementById('p_address').value.trim(),
      };

      if (!data.pharmacyName || !data.phone || !data.address) {
        alertEl.innerHTML = `<div class="alert-error" style="margin:0 28px 16px;">${pt('required_fields')}</div>`;
        return;
      }

      btn.classList.add('btn-loading'); btn.disabled = true;
      try {
        await api.updatePharmacyProfile(data);
        alertEl.innerHTML = `<div class="alert-success" style="margin:0 28px 16px;">${pt('profile_updated')}</div>`;
        await phLoadSidebarProfile();
        setTimeout(() => { alertEl.innerHTML = ''; }, 3000);
      } catch(e) {
        alertEl.innerHTML = `<div class="alert-error" style="margin:0 28px 16px;">${e.message}</div>`;
      } finally {
        btn.classList.remove('btn-loading'); btn.disabled = false;
      }
    });

  } catch(e) { phShowError(e.message); }
}

function phShowError(msg) {
  document.getElementById('pageContent').innerHTML =
    `<div class="empty-state"><i class="fas fa-exclamation-circle"></i><p>${msg}</p></div>`;
}
