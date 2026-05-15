// pharmacy/js/pharmacy-dashboard.js
document.addEventListener('DOMContentLoaded', async () => {
  const ok = await phInitPage();
  if (!ok) return;
  await loadDashboard();
});

async function loadAllStock() {
  try {
    const pharmacyId = api.getPharmacyId();
    if (!pharmacyId) return [];
    const res = await api.request(`/pharmacies/${pharmacyId}/stock`);
    return (res.success && res.data) ? res.data : [];
  } catch {
    return [
      { medication_id:'1', medication_name:'Doliprane 500mg',   quantity:25, price:250,  inStock:true  },
      { medication_id:'2', medication_name:'Amoxicilline 500mg',quantity:5,  price:480,  inStock:true  },
      { medication_id:'3', medication_name:'Spasfon 80mg',      quantity:0,  price:320,  inStock:false },
      { medication_id:'4', medication_name:'Ibuprofene 400mg',  quantity:12, price:400,  inStock:true  },
      { medication_id:'5', medication_name:'Ventoline 100mcg',  quantity:8,  price:1800, inStock:true  },
    ];
  }
}

async function loadDashboard() {
  // Skeleton while loading
  document.getElementById('pageContent').innerHTML = `
    ${phSkeletonStats(3)}
    <div class="card"><div class="card-body">${phSkeletonList(3)}</div></div>
  `;

  const stockList = await loadAllStock();
  const total   = stockList.length;
  const lowCnt  = stockList.filter(s => s.quantity > 0 && s.quantity < 10).length;
  const outCnt  = stockList.filter(s => !s.inStock || s.quantity === 0).length;

  document.getElementById('pageContent').innerHTML = `
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon primary"><i class="fas fa-pills"></i></div>
        <div class="stat-body"><div class="stat-value">${total}</div><div class="stat-label">${pt('meds_in_stock')}</div></div>
      </div>
      <div class="stat-card">
        <div class="stat-icon warning"><i class="fas fa-exclamation-triangle"></i></div>
        <div class="stat-body"><div class="stat-value">${lowCnt}</div><div class="stat-label">${pt('low_stock')}</div></div>
      </div>
      <div class="stat-card">
        <div class="stat-icon danger"><i class="fas fa-ban"></i></div>
        <div class="stat-body"><div class="stat-value">${outCnt}</div><div class="stat-label">${pt('out_of_stock')}</div></div>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        <h3><i class="fas fa-search" style="color:var(--teal)"></i> ${pt('search_med')}</h3>
      </div>
      <div class="card-body">
        <div class="search-bar">
          <i class="fas fa-search"></i>
          <input type="text" id="medSearchInput" placeholder="${pt('search_med_ph')}" autocomplete="off">
          <button id="scanBarcodeBtn" class="btn-icon"><i class="fas fa-camera"></i></button>
        </div>
        <div id="searchResults" style="margin-top:16px;"></div>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        <h3><i class="fas fa-boxes" style="color:var(--teal)"></i> ${pt('recent_stock')}</h3>
        <button id="refreshStockBtn" class="btn-sm"><i class="fas fa-sync-alt"></i> ${pt('refresh')}</button>
      </div>
      <div class="card-body">
        <div class="stock-table-container">
          <table class="stock-table">
            <thead><tr>
              <th>${pt('med_col')}</th><th>${pt('qty_col')}</th>
              <th>${pt('price_col')}</th><th>${pt('status_col')}</th><th>${pt('actions_col')}</th>
            </tr></thead>
            <tbody id="stockTableBody">
              ${stockList.slice(0, 10).map(renderStockRow).join('')}
            </tbody>
          </table>
          ${stockList.length > 10
            ? `<div class="view-all"><a href="inventory.html" class="link-more">${pt('view_all_stock')}</a></div>`
            : ''}
        </div>
      </div>
    </div>

    <div class="card">
      <div class="card-header"><h3><i class="fas fa-moon" style="color:var(--teal)"></i> ${pt('duty_section')}</h3></div>
      <div class="card-body">
        <div class="duty-toggle">
          <div class="duty-status">
            ${pt('duty_current')}
            <span class="stock-badge ${currentPharmacy?.isOnDutyTonight ? 'in-stock' : 'out-of-stock'}" style="margin-left:8px;">
              ${currentPharmacy?.isOnDutyTonight ? pt('on_duty') : pt('off_duty')}
            </span>
          </div>
          <button id="toggleDutyBtn" class="${currentPharmacy?.isOnDutyTonight ? 'btn-danger' : 'btn-success'}">
            <i class="fas ${currentPharmacy?.isOnDutyTonight ? 'fa-power-off' : 'fa-bell'}"></i>
            ${currentPharmacy?.isOnDutyTonight ? pt('deactivate_duty') : pt('activate_duty')}
          </button>
        </div>
      </div>
    </div>
  `;

  // Bind events
  let timer;
  document.getElementById('medSearchInput')?.addEventListener('input', e => {
    clearTimeout(timer);
    timer = setTimeout(() => searchMedications(e.target.value), 500);
  });
  document.getElementById('scanBarcodeBtn')?.addEventListener('click', () => {
    const bc = prompt(pt('scan_prompt'));
    if (bc) handleBarcode(bc);
  });
  document.getElementById('refreshStockBtn')?.addEventListener('click', loadDashboard);
  document.getElementById('toggleDutyBtn')?.addEventListener('click', async (e) => {
    const btn = e.currentTarget;
    btn.classList.add('btn-loading'); btn.disabled = true;
    await toggleDuty();
    btn.classList.remove('btn-loading'); btn.disabled = false;
  });
  bindEditButtons();
}

function renderStockRow(item) {
  const qty = item.quantity ?? 0;
  const sc  = (!item.inStock || qty === 0) ? 'out-of-stock' : qty < 10 ? 'low-stock' : 'in-stock';
  const st  = (!item.inStock || qty === 0) ? pt('rupture') : qty < 10 ? pt('stock_low') : pt('in_stock');
  const name= item.medication?.name || item.medication_name || item.medicationName || '-';
  const mid = item.medication_id || item.medicationId;
  return `<tr>
    <td><strong>${name}</strong></td>
    <td class="quantity-cell">${qty}</td>
    <td>${item.price ? item.price + ' DA' : '-'}</td>
    <td><span class="stock-badge ${sc}">${st}</span></td>
    <td><button class="btn-edit-stock" data-mid="${mid}" data-mname="${phEscapeHtml(name)}"><i class="fas fa-edit"></i></button></td>
  </tr>`;
}

function bindEditButtons() {
  document.querySelectorAll('.btn-edit-stock').forEach(btn => {
    btn.addEventListener('click', () => showEditStockModal(btn.dataset.mid, btn.dataset.mname));
  });
}

async function searchMedications(query) {
  const res = document.getElementById('searchResults');
  if (!res) return;
  if (query.length < 2) { res.innerHTML = ''; return; }
  res.innerHTML = phSkeletonList(3);
  try {
    const r = await api.searchMedications(query);
    if (r.success && r.data?.length) {
      res.innerHTML = `<div class="search-results-list">${r.data.map(m =>
        `<div class="search-result-item" onclick="showMedDetails('${m.id}')">
           <strong>${m.name}</strong> ${m.dosage ? `— ${m.dosage}` : ''}
           <button class="btn-edit-stock-small" onclick="event.stopPropagation();showEditStockModal('${m.id}','${phEscapeHtml(m.name)}')">${pt('modify_stock')}</button>
         </div>`).join('')}</div>`;
    } else {
      res.innerHTML = `<div class="empty-state">${pt('no_results')}</div>`;
    }
  } catch {
    res.innerHTML = `<div class="empty-state">${pt('search_error')}</div>`;
  }
}

async function handleBarcode(bc) {
  try {
    const r = await api.searchByBarcode(bc);
    if (r.success && r.data) showMedDetails(r.data.id);
    else phShowToast(pt('med_not_found'), 'error');
  } catch(e) { phShowToast(e.message, 'error'); }
}

async function toggleDuty() {
  const newStatus = !currentPharmacy?.isOnDutyTonight;
  try {
    await api.setDutyStatus(newStatus);
    phShowToast(newStatus ? pt('duty_activated') : pt('duty_deactivated'), 'success');
    await phLoadSidebarProfile();
    await loadDashboard();
  } catch(e) { phShowToast(e.message, 'error'); }
}

async function showMedDetails(id) {
  try {
    const r = await api.getMedicationById(id);
    const m = r.data;
    phOpenModal(m.name, `
      <div class="med-details" style="display:flex;flex-direction:column;gap:10px;font-size:13.5px;">
        <p><strong>${pt('form_label')}:</strong> ${m.form || '-'}</p>
        <p><strong>${pt('dosage_label')}:</strong> ${m.dosage || '-'}</p>
        <p><strong>${pt('manufacturer')}:</strong> ${m.manufacturer || '-'}</p>
        <p><strong>${pt('prescription_req')}:</strong> ${m.requiresPrescription ? pt('yes') : pt('no_rupture').replace(' (rupture)','').replace(' (نفاد)','')}</p>
        ${m.indications ? `<p><strong>${pt('indications')}:</strong> ${m.indications}</p>` : ''}
        ${m.contraindications ? `<p><strong>${pt('contraindications')}:</strong> ${m.contraindications}</p>` : ''}
      </div>
      <div class="modal-actions">
        <button class="btn-primary" onclick="showEditStockModal('${m.id}','${phEscapeHtml(m.name)}')">${pt('update_stock_btn')}</button>
        <button class="btn-cancel-modal" onclick="phCloseModal()">${pt('cancel')}</button>
      </div>
    `);
  } catch(e) { phShowToast(e.message, 'error'); }
}

async function showEditStockModal(medId, medName) {
  let stock = { quantity: 0, price: null, inStock: true };
  try {
    const r = await api.getStock(medId);
    if (r.success && r.data) stock = r.data;
  } catch {}
  phOpenModal(`${pt('modify_stock')}: ${medName}`, `
    <div id="stockAlert"></div>
    <div class="form-group"><label>${pt('stock_qty')}</label>
      <input type="number" id="stockQty" class="modal-input" value="${stock.quantity || 0}" min="0">
    </div>
    <div class="form-group"><label>${pt('stock_price')}</label>
      <input type="number" id="stockPrice" class="modal-input" value="${stock.price || ''}" min="0" step="10">
    </div>
    <div class="form-group"><label>${pt('available')}</label>
      <select id="stockAvail" class="modal-input">
        <option value="true"  ${stock.inStock !== false ? 'selected' : ''}>${pt('yes')}</option>
        <option value="false" ${stock.inStock === false ? 'selected' : ''}>${pt('no_rupture')}</option>
      </select>
    </div>
    <div class="modal-actions">
      <button class="btn-cancel-modal" onclick="phCloseModal()">${pt('cancel')}</button>
      <button class="btn-save-modal" id="saveStockBtn" onclick="saveStock('${medId}','${phEscapeHtml(medName)}')">${pt('save')}</button>
    </div>
  `);
}

async function saveStock(medId, medName) {
  const btn = document.getElementById('saveStockBtn');
  if (btn) { btn.classList.add('btn-loading'); btn.disabled = true; }
  const qty   = parseInt(document.getElementById('stockQty').value)   || 0;
  const price = parseFloat(document.getElementById('stockPrice').value) || null;
  const inSt  = document.getElementById('stockAvail').value === 'true';
  try {
    await api.updateStock(medId, { quantity: qty, price, inStock: inSt });
    phCloseModal();
    phShowToast(`${pt('stock_updated')}: ${medName}`, 'success');
    await loadDashboard();
  } catch(e) {
    const al = document.getElementById('stockAlert');
    if (al) al.innerHTML = `<div class="alert-error">${e.message}</div>`;
    if (btn) { btn.classList.remove('btn-loading'); btn.disabled = false; }
  }
}

window.showMedDetails    = showMedDetails;
window.showEditStockModal = showEditStockModal;
window.saveStock         = saveStock;
