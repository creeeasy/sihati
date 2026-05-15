document.addEventListener('DOMContentLoaded', async () => {
  const ok = await initPage();
  if (!ok) return;
  await loadReviews();
});

async function loadReviews() {
  showPageLoading();
  setContent(skeletonList(4));
  try {
    const res = await api.getDoctorReviews();
    const reviews = res.data || [];
    const avg = reviews.length
      ? (reviews.reduce((s, r) => s + +r.rating, 0) / reviews.length).toFixed(1)
      : null;
    const dist = [5, 4, 3, 2, 1].map(n => {
      const count = reviews.filter(r => +r.rating === n).length;
      const pct   = reviews.length ? Math.round(count / reviews.length * 100) : 0;
      return { n, count, pct };
    });

    setContent(`
      ${avg ? `
        <div class="card" style="margin-bottom:18px;">
          <div class="card-body" style="display:flex;gap:32px;align-items:center;flex-wrap:wrap;">
            <div style="text-align:center;">
              <div style="font-size:52px;font-weight:800;color:var(--violet);font-family:var(--mono);">${avg}</div>
              <div style="color:var(--gold);font-size:22px;">${'★'.repeat(Math.round(avg))}${'☆'.repeat(5 - Math.round(avg))}</div>
              <div class="text-muted">${reviews.length} ${t('reviews_count')}</div>
            </div>
            <div style="flex:1;min-width:200px;">
              ${dist.map(d => `
                <div style="display:flex;align-items:center;gap:8px;margin-bottom:6px;">
                  <span style="width:24px;font-size:13px;">${d.n}★</span>
                  <div style="flex:1;height:8px;background:var(--surface);border-radius:4px;overflow:hidden;">
                    <div style="width:${d.pct}%;height:100%;background:var(--gold);border-radius:4px;transition:width 0.6s;"></div>
                  </div>
                  <span style="width:24px;font-size:12px;color:var(--text-dim);">${d.count}</span>
                </div>`).join('')}
            </div>
          </div>
        </div>` : ''}
      <div class="card">
        <div class="card-header">
          <div class="card-title">
            <div class="card-title-icon gold"><i class="fas fa-star"></i></div>
            ${t('reviews_title')} (${reviews.length})
          </div>
        </div>
        <div class="card-body">
          ${reviews.length
            ? reviews.map(r => `
                <div class="review-card">
                  <div class="review-header">
                    <span class="reviewer">${r.user?.fullName || 'Patient'}</span>
                    <span class="review-rating">${'★'.repeat(Math.floor(+r.rating))}${'☆'.repeat(5 - Math.floor(+r.rating))}</span>
                    <span class="review-date">${formatDate(r.createdAt)}</span>
                  </div>
                  ${r.comment ? `<p class="review-comment">"${r.comment}"</p>` : ''}
                </div>`).join('')
            : `<div class="empty-state"><i class="far fa-star"></i><p>${t('no_reviews')}</p></div>`}
        </div>
      </div>
    `);
  } catch (e) { pageError(e.message); }
  hidePageLoading();
}

function setContent(html) { document.getElementById('pageContent').innerHTML = html; }
function pageError(msg)   { document.getElementById('pageContent').innerHTML = `<div class="empty-state"><i class="fas fa-exclamation-circle"></i><p>${msg}</p></div>`; }
