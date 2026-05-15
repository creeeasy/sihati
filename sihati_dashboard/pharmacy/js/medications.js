// pharmacy/js/medications.js
document.addEventListener('DOMContentLoaded', async () => {
  const ok = await phInitPage();
  if (!ok) return;
  await loadMedicationsPage();
});

async function loadMedicationsPage() {
  document.getElementById('pageContent').innerHTML = `
    <div class="card">
      <div class="card-header"><h3><i class="fas fa-search" style="color:var(--teal)"></i> ${pt('med_search_heading')}</h3></div>
      <div class="card-body">
        <div class="search-bar large">
          <i class="fas fa-search"></i>
          <input type="text" id="globalMedSearch" placeholder="${pt('med_search_ph')}">
          <button id="globalScanBtn" class="btn-icon"><i class="fas fa-camera"></i></button>
        </div>
        <div id="globalSearchResults" style="margin-top:24px;"></div>
      </div>
    </div>
    <div class="card">
      <div class="card-header"><h3><i class="fas fa-star" style="color:var(--teal)"></i> ${pt('popular_meds')}</h3></div>
      <div class="card-body">
        <div id="popularMeds" class="med-grid">${phSkeletonList(4).replace(/skeleton-row/g,'skeleton skeleton-stat')}</div>
      </div>
    </div>
  `;

  // Load popular medications
  try {
    const res = await api.getPopularMedications(8);
    const container = document.getElementById('popularMeds');
    if (container && res.success && res.data?.length) {
      container.innerHTML = res.data.map(m => `
        <div class="med-card" onclick="showMedModal('${m.id}')">
          <i class="fas fa-pills med-icon"></i>
          <div class="med-name">${m.name}</div>
          <div class="med-dosage">${m.dosage || ''}</div>
          ${m.requiresPrescription ? `<span class="prescription-badge">${pt('prescription')}</span>` : ''}
        </div>`).join('');
    } else if (container) {
      container.innerHTML = `<div class="empty-state">${pt('no_results')}</div>`;
    }
  } catch(e) { console.error(e); }

  // Search input
  let timer;
  document.getElementById('globalMedSearch')?.addEventListener('input', e => {
    clearTimeout(timer);
    timer = setTimeout(() => searchGlobal(e.target.value), 500);
  });

  // Barcode
  document.getElementById('globalScanBtn')?.addEventListener('click', () => {
    const bc = prompt(pt('scan_prompt'));
    if (bc) handleGlobalBarcode(bc);
  });
}

async function searchGlobal(query) {
  const res = document.getElementById('globalSearchResults');
  if (!res) return;
  if (query.length < 2) { res.innerHTML = ''; return; }
  res.innerHTML = phSkeletonList(3);
  try {
    const r = await api.searchMedications(query);
    if (r.success && r.data?.length) {
      res.innerHTML = `
        <h4 style="margin-bottom:12px;font-size:13px;color:var(--text-muted);">
          ${pt('results')} (${r.data.length})
        </h4>
        <div class="med-grid">
          ${r.data.map(m => `
            <div class="med-card" onclick="showMedModal('${m.id}')">
              <i class="fas fa-capsules med-icon"></i>
              <div class="med-name">${m.name}</div>
              <div class="med-dosage">${m.dosage || ''}</div>
              ${m.requiresPrescription ? `<span class="prescription-badge">${pt('prescription')}</span>` : ''}
              <button class="btn-view-stock" onclick="event.stopPropagation();showStockModal('${m.id}')">
                ${pt('see_stock')}
              </button>
            </div>`).join('')}
        </div>`;
    } else {
      res.innerHTML = `<div class="empty-state"><i class="fas fa-search"></i><p>${pt('no_results')}</p></div>`;
    }
  } catch {
    res.innerHTML = `<div class="empty-state">${pt('search_error')}</div>`;
  }
}

async function handleGlobalBarcode(bc) {
  try {
    const r = await api.searchByBarcode(bc);
    if (r.success && r.data) showMedModal(r.data.id);
    else phShowToast(pt('med_not_found'), 'error');
  } catch(e) { phShowToast(e.message, 'error'); }
}

async function showMedModal(id) {
  try {
    const r = await api.getMedicationById(id);
    const m = r.data;
    phOpenModal(m.name, `
      <div style="display:flex;flex-direction:column;gap:10px;font-size:13.5px;margin-bottom:16px;">
        <p><strong>${pt('form_label')}:</strong> ${m.form || '-'}</p>
        <p><strong>${pt('dosage_label')}:</strong> ${m.dosage || '-'}</p>
        <p><strong>${pt('manufacturer')}:</strong> ${m.manufacturer || '-'}</p>
        <p><strong>${pt('prescription_req')}:</strong> ${m.requiresPrescription ? pt('yes') : pt('no_rupture').split(' (')[0]}</p>
        ${m.indications ? `<p><strong>${pt('indications')}:</strong> ${m.indications}</p>` : ''}
        ${m.contraindications ? `<p><strong>${pt('contraindications')}:</strong> ${m.contraindications}</p>` : ''}
        ${m.sideEffects ? `<p><strong>${pt('side_effects')}:</strong> ${m.sideEffects}</p>` : ''}
      </div>
      <div class="modal-actions">
        <button class="btn-cancel-modal" onclick="phCloseModal()">${pt('cancel')}</button>
        <button class="btn-primary" onclick="showMedStockEdit('${m.id}','${phEscapeHtml(m.name)}')">${pt('update_stock_btn')}</button>
        <button class="btn-sm" onclick="showStockModal('${m.id}')">${pt('see_pharmacies')}</button>
      </div>
    `);
  } catch(e) { phShowToast(e.message, 'error'); }
}

async function showStockModal(medId) {
  try {
    const r = await api.getPharmaciesWithStock(medId);
    const items = r.data || [];
    phOpenModal(pt('pharmacies_with_stock'), `
      <div>
        ${items.length ? items.map(item => `
          <div style="border-bottom:1px solid var(--border);padding:14px 0;">
            <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;">
              <div>
                <strong>${item.pharmacy.pharmacyName}</strong>
                ${item.pharmacy.isOnDutyTonight
                  ? `<span style="background:var(--green-dim);color:var(--green);padding:2px 8px;border-radius:12px;font-size:11px;margin-left:8px;">${pt('on_duty')}</span>`
                  : ''}
              </div>
              <div style="text-align:end;">
                <span style="font-weight:700;color:var(--teal);">${item.price} DA</span>
                <span style="font-size:12px;color:var(--text-muted);margin-left:8px;">${pt('qty_col')}: ${item.quantity}</span>
              </div>
            </div>
            <div style="margin-top:6px;color:var(--text-muted);font-size:12px;">
              ${item.pharmacy.address}, ${item.pharmacy.wilaya}
            </div>
            <div style="margin-top:8px;display:flex;gap:8px;">
              <a href="tel:${item.pharmacy.phone}" style="background:var(--green-dim);color:var(--green);padding:5px 12px;border-radius:6px;text-decoration:none;font-size:12px;">
                <i class="fas fa-phone"></i> ${pt('call_btn')}
              </a>
              <a href="https://www.google.com/maps?q=${item.pharmacy.latitude},${item.pharmacy.longitude}" target="_blank"
                 style="background:var(--teal-dim);color:var(--teal);padding:5px 12px;border-radius:6px;text-decoration:none;font-size:12px;">
                <i class="fas fa-map-marker-alt"></i> ${pt('directions_btn')}
              </a>
            </div>
          </div>`).join('')
          : `<div class="empty-state"><i class="fas fa-store"></i><p>${pt('no_pharmacies')}</p></div>`}
      </div>
    `);
  } catch(e) { phShowToast(e.message, 'error'); }
}

async function showMedStockEdit(medId, medName) {
  let stock = { quantity:0, price:null, inStock:true };
  try { const r = await api.getStock(medId); if (r.success && r.data) stock = r.data; } catch {}
  phOpenModal(`${pt('modify_stock')}: ${medName}`, `
    <div id="medStockAlert"></div>
    <div class="form-group"><label>${pt('stock_qty')}</label>
      <input type="number" id="medStockQty" class="modal-input" value="${stock.quantity || 0}" min="0">
    </div>
    <div class="form-group"><label>${pt('stock_price')}</label>
      <input type="number" id="medStockPrice" class="modal-input" value="${stock.price || ''}" min="0" step="10">
    </div>
    <div class="form-group"><label>${pt('available')}</label>
      <select id="medStockAvail" class="modal-input">
        <option value="true"  ${stock.inStock !== false ? 'selected':''}>${pt('yes')}</option>
        <option value="false" ${stock.inStock === false  ? 'selected':''}>${pt('no_rupture')}</option>
      </select>
    </div>
    <div class="modal-actions">
      <button class="btn-cancel-modal" onclick="phCloseModal()">${pt('cancel')}</button>
      <button class="btn-save-modal" id="medStockSaveBtn" onclick="saveMedStock('${medId}','${phEscapeHtml(medName)}')">${pt('save')}</button>
    </div>
  `);
}

async function saveMedStock(medId, medName) {
  const btn = document.getElementById('medStockSaveBtn');
  if (btn) { btn.classList.add('btn-loading'); btn.disabled = true; }
  try {
    await api.updateStock(medId, {
      quantity: parseInt(document.getElementById('medStockQty').value) || 0,
      price:    parseFloat(document.getElementById('medStockPrice').value) || null,
      inStock:  document.getElementById('medStockAvail').value === 'true'
    });
    phCloseModal();
    phShowToast(`${pt('stock_updated')}: ${medName}`, 'success');
  } catch(e) {
    const al = document.getElementById('medStockAlert');
    if (al) al.innerHTML = `<div class="alert-error">${e.message}</div>`;
    if (btn) { btn.classList.remove('btn-loading'); btn.disabled = false; }
  }
}

window.showMedModal    = showMedModal;
window.showStockModal  = showStockModal;
window.showMedStockEdit= showMedStockEdit;
window.saveMedStock    = saveMedStock;
