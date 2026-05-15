function saveCurrentPage(page) {
  localStorage.setItem("doctorCurrentPage", page);
}

function getCurrentPage() {
  return localStorage.getItem("doctorCurrentPage") || "dashboard";
}
