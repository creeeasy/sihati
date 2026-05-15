// pharmacy/js/inventory.js
document.addEventListener('DOMContentLoaded', async () => {
  const ok = await phInitPage();
  if (!ok) return;
  await loadInventory();
});

async function loadAllStock() {
  try {
    const pharmacyId = api.getPharmacyId();
    if (!pharmacyId) return [];
    const res = await api.request(`/pharmacies/${pharmacyId}/stock`);
    return (res.success && res.data) ? res.data : [];
  } catch {
    return [
      { medication_id:'1', medication_name:'Doliprane 500mg',    quantity:25, price:250,  inStock:true  },
      { medication_id:'2', medication_name:'Amoxicilline 500mg', quantity:5,  price:480,  inStock:true  },
      { medication_id:'3', medication_name:'Spasfon 80mg',       quantity:0,  price:320,  inStock:false },
      { medication_id:'4', medication_name:'Ibuprofene 400mg',   quantity:12, price:400,  inStock:true  },
    ];
  }
}

async function loadInventory() {
  document.getElementById('pageContent').innerHTML =
    `<div class="card"><div class="card-body">${phSkeletonList(6)}</div></div>`;
  const list = await loadAllStock();

  document.getElementById('pageContent').innerHTML = `
    <div class="card">
      <div class="card-header">
        <h3><i class="fas fa-boxes" style="color:var(--teal)"></i> ${pt('inventory_heading')}</h3>
        <input type="text" id="stockFilter" placeholder="${pt('filter_ph')}"
          style="background:var(--surface);border:1px solid var(--border);border-radius:var(--radius-sm);
                 padding:8px 12px;color:var(--text);font-family:var(--font);font-size:13px;outline:none;">
      </div>
      <div class="card-body">
        <div class="stock-table-container">
          <table class="stock-table">
            <thead><tr>
              <th>${pt('med_col')}</th><th>${pt('qty_col')}</th>
              <th>${pt('price_col')}</th><th>${pt('status_col')}</th><th>${pt('actions_col')}</th>
            </tr></thead>
            <tbody id="inventoryBody">
              ${list.length
                ? list.map(renderRow).join('')
                : `<tr><td colspan="5"><div class="empty-state">${pt('no_results')}</div></td></tr>`}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  `;

  document.getElementById('stockFilter')?.addEventListener('input', e => {
    const term = e.target.value.toLowerCase();
    document.querySelectorAll('#inventoryBody tr').forEach(row => {
      row.style.display = row.textContent.toLowerCase().includes(term) ? '' : 'none';
    });
  });

  document.querySelectorAll('.btn-edit-stock').forEach(btn =>
    btn.addEventListener('click', () => showInvEditModal(btn.dataset.mid, btn.dataset.mname))
  );
}

function renderRow(item) {
  const qty  = item.quantity ?? 0;
  const sc   = (!item.inStock || qty === 0) ? 'out-of-stock' : qty < 10 ? 'low-stock' : 'in-stock';
  const st   = (!item.inStock || qty === 0) ? pt('rupture') : qty < 10 ? pt('stock_low') : pt('in_stock');
  const name = item.medication?.name || item.medication_name || '-';
  const mid  = item.medication_id || item.medicationId;
  return `<tr>
    <td><strong>${name}</strong></td>
    <td class="quantity-cell">${qty}</td>
    <td>${item.price ? item.price + ' DA' : '-'}</td>
    <td><span class="stock-badge ${sc}">${st}</span></td>
    <td><button class="btn-edit-stock" data-mid="${mid}" data-mname="${phEscapeHtml(name)}"><i class="fas fa-edit"></i></button></td>
  </tr>`;
}

async function showInvEditModal(medId, medName) {
  let stock = { quantity:0, price:null, inStock:true };
  try { const r = await api.getStock(medId); if (r.success && r.data) stock = r.data; } catch {}
  phOpenModal(`${pt('modify_stock')}: ${medName}`, `
    <div id="invAlert"></div>
    <div class="form-group"><label>${pt('stock_qty')}</label>
      <input type="number" id="invQty" class="modal-input" value="${stock.quantity || 0}" min="0">
    </div>
    <div class="form-group"><label>${pt('stock_price')}</label>
      <input type="number" id="invPrice" class="modal-input" value="${stock.price || ''}" min="0" step="10">
    </div>
    <div class="form-group"><label>${pt('available')}</label>
      <select id="invAvail" class="modal-input">
        <option value="true"  ${stock.inStock !== false ? 'selected':''}>${pt('yes')}</option>
        <option value="false" ${stock.inStock === false  ? 'selected':''}>${pt('no_rupture')}</option>
      </select>
    </div>
    <div class="modal-actions">
      <button class="btn-cancel-modal" onclick="phCloseModal()">${pt('cancel')}</button>
      <button class="btn-save-modal" id="invSaveBtn" onclick="saveInvStock('${medId}','${phEscapeHtml(medName)}')">${pt('save')}</button>
    </div>
  `);
}

async function saveInvStock(medId, medName) {
  const btn = document.getElementById('invSaveBtn');
  if (btn) { btn.classList.add('btn-loading'); btn.disabled = true; }
  try {
    await api.updateStock(medId, {
      quantity: parseInt(document.getElementById('invQty').value) || 0,
      price:    parseFloat(document.getElementById('invPrice').value) || null,
      inStock:  document.getElementById('invAvail').value === 'true'
    });
    phCloseModal();
    phShowToast(`${pt('stock_updated')}: ${medName}`, 'success');
    await loadInventory();
  } catch(e) {
    const al = document.getElementById('invAlert');
    if (al) al.innerHTML = `<div class="alert-error">${e.message}</div>`;
    if (btn) { btn.classList.remove('btn-loading'); btn.disabled = false; }
  }
}

window.saveInvStock = saveInvStock;
window.showInvEditModal = showInvEditModal;
