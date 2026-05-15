function formatCurrency(amount) {
  if (!amount && amount !== 0) return "—";
  const value = typeof amount === "string" ? parseFloat(amount) : amount;
  if (isNaN(value)) return "—";
  if (value === 0) return "0 DZD";
  return new Intl.NumberFormat("en-US").format(Math.round(value)) + " DZD";
}

function formatDate(dateString) {
  const date = new Date(dateString);
  return date.toLocaleDateString("fr-FR", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });
}

function formatDateTime(dateString) {
  const date = new Date(dateString);
  return date.toLocaleDateString("fr-FR", {
    day: "numeric",
    month: "long",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function showPageLoading() {
  const content = document.getElementById("pageContent");
  if (content) {
    content.innerHTML =
      '<div class="loading"><div class="spinner"></div><p>Chargement en cours...</p></div>';
  }
}

function hidePageLoading() {
  const loadingEl = document.querySelector("#pageContent .loading");
  if (loadingEl) loadingEl.remove();
}

function showToast(message, type = "info") {
  const colors = {
    success: "var(--green)",
    error: "var(--rose)",
    info: "var(--violet)",
  };
  const toast = document.createElement("div");
  toast.className = `toast ${type}`;
  toast.innerHTML = `<i class="fas ${type === "success" ? "fa-check-circle" : type === "error" ? "fa-exclamation-circle" : "fa-info-circle"}"></i> ${message}`;
  document.body.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = "0";
    toast.style.transform = "translateY(20px)";
    setTimeout(() => toast.remove(), 300);
  }, 3200);
}

function escapeHtml(str) {
  if (!str) return "";
  return str
    .replace(/[&<>]/g, (m) => {
      if (m === "&") return "&amp;";
      if (m === "<") return "&lt;";
      if (m === ">") return "&gt;";
      return m;
    })
    .replace(/['"]/g, (m) => {
      if (m === "'") return "&#39;";
      if (m === '"') return "&quot;";
      return m;
    });
}
