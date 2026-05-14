// Pharmacy Stock Management Module
const PharmacyStock = {
  stockData: [],
  currentPage: 1,
  itemsPerPage: 10,
  searchQuery: '',
  selectedCategory: '',
  
  /**
   * Load stock data from API
   */
  async loadStock() {
    try {
      const response = await API.get(CONFIG.ENDPOINTS.PHARMACY.STOCK, {
        page: this.currentPage,
        limit: this.itemsPerPage,
        search: this.searchQuery,
        category: this.selectedCategory
      });
      
      this.stockData = response.medications || [];
      
      // Update UI
      this.displayStock();
      this.updatePagination(response.totalPages, response.currentPage);
      
      return this.stockData;
    } catch (error) {
      console.error('Load stock error:', error);
      Helpers.showToast('Erreur lors du chargement du stock', 'error');
      throw error;
    }
  },
  
  /**
   * Display stock in table
   */
  displayStock() {
    const tbody = document.getElementById('stockTableBody');
    
    if (!tbody) return;
    
    // Clear existing rows
    tbody.innerHTML = '';
    
    // If no data
    if (this.stockData.length === 0) {
      tbody.innerHTML = `
        <tr>
          <td colspan="6" class="text-center text-muted py-4">
            <i class="bi bi-inbox" style="font-size: 3rem;"></i>
            <p class="mt-2">Aucun médicament trouvé</p>
          </td>
        </tr>
      `;
      return;
    }
    
    // Create rows
    this.stockData.forEach(medication => {
      const row = this.createStockRow(medication);
      tbody.appendChild(row);
    });
  },
  
  /**
   * Create a stock table row
   */
  createStockRow(medication) {
    const tr = document.createElement('tr');
    tr.dataset.medicationId = medication.id;
    
    // Determine status badge
    let statusBadge = '';
    if (medication.quantity === 0) {
      statusBadge = '<span class="badge bg-danger">Rupture</span>';
    } else if (medication.quantity <= medication.minStock) {
      statusBadge = '<span class="badge bg-warning">Stock faible</span>';
    } else {
      statusBadge = '<span class="badge bg-success">Disponible</span>';
    }
    
    tr.innerHTML = `
      <td><strong>${medication.name}</strong></td>
      <td>${medication.category || 'N/A'}</td>
      <td>${medication.quantity}</td>
      <td>${medication.unit || 'Boîtes'}</td>
      <td>${statusBadge}</td>
      <td>
        <button class="btn btn-sm btn-outline-primary edit-stock-btn" data-id="${medication.id}">
          <i class="bi bi-pencil"></i>
        </button>
        <button class="btn btn-sm btn-outline-danger delete-stock-btn" data-id="${medication.id}">
          <i class="bi bi-trash"></i>
        </button>
      </td>
    `;
    
    // Add event listeners
    tr.querySelector('.edit-stock-btn').addEventListener('click', () => {
      this.openEditModal(medication);
    });
    
    tr.querySelector('.delete-stock-btn').addEventListener('click', () => {
      this.deleteMedication(medication.id);
    });
    
    return tr;
  },
  
  /**
   * Add new medication
   */
  async addMedication(medicationData) {
    try {
      // Validate data
      const validation = this.validateMedicationData(medicationData);
      if (!validation.isValid) {
        Object.keys(validation.errors).forEach(field => {
          Helpers.showToast(validation.errors[field], 'error');
        });
        return false;
      }
      
      // Call API
      const response = await API.post(
        CONFIG.ENDPOINTS.PHARMACY.STOCK,
        medicationData
      );
      
      // Show success message
      Helpers.showToast('Médicament ajouté avec succès !', 'success');
      
      // Reload stock
      await this.loadStock();
      
      return response.medication;
    } catch (error) {
      console.error('Add medication error:', error);
      Helpers.showToast(
        error.message || 'Erreur lors de l\'ajout du médicament',
        'error'
      );
      throw error;
    }
  },
  
  /**
   * Update medication
   */
  async updateMedication(medicationId, medicationData) {
    try {
      // Validate data
      const validation = this.validateMedicationData(medicationData);
      if (!validation.isValid) {
        Object.keys(validation.errors).forEach(field => {
          Helpers.showToast(validation.errors[field], 'error');
        });
        return false;
      }
      
      // Call API
      const response = await API.put(
        `${CONFIG.ENDPOINTS.PHARMACY.STOCK}/${medicationId}`,
        medicationData
      );
      
      // Show success message
      Helpers.showToast('Médicament mis à jour avec succès !', 'success');
      
      // Reload stock
      await this.loadStock();
      
      return response.medication;
    } catch (error) {
      console.error('Update medication error:', error);
      Helpers.showToast(
        error.message || 'Erreur lors de la mise à jour',
        'error'
      );
      throw error;
    }
  },
  
  /**
   * Delete medication
   */
  async deleteMedication(medicationId) {
    // Confirm deletion
    if (!Helpers.confirm('Êtes-vous sûr de vouloir supprimer ce médicament ?')) {
      return;
    }
    
    try {
      // Call API
      await API.delete(`${CONFIG.ENDPOINTS.PHARMACY.STOCK}/${medicationId}`);
      
      // Show success message
      Helpers.showToast('Médicament supprimé avec succès !', 'success');
      
      // Reload stock
      await this.loadStock();
    } catch (error) {
      console.error('Delete medication error:', error);
      Helpers.showToast(
        error.message || 'Erreur lors de la suppression',
        'error'
      );
      throw error;
    }
  },
  
  /**
   * Validate medication data
   */
  validateMedicationData(data) {
    const errors = {};
    
    // Name
    if (Validator.isEmpty(data.name)) {
      errors.name = 'Le nom du médicament est requis';
    }
    
    // Quantity
    if (data.quantity === undefined || data.quantity === null || data.quantity < 0) {
      errors.quantity = 'La quantité doit être un nombre positif';
    }
    
    // Unit
    if (Validator.isEmpty(data.unit)) {
      errors.unit = 'L\'unité est requise';
    }
    
    return {
      isValid: Object.keys(errors).length === 0,
      errors: errors
    };
  },
  
  /**
   * Search medications
   */
  search(query) {
    this.searchQuery = query;
    this.currentPage = 1;
    this.loadStock();
  },
  
  /**
   * Filter by category
   */
  filterByCategory(category) {
    this.selectedCategory = category;
    this.currentPage = 1;
    this.loadStock();
  },
  
  /**
   * Update pagination
   */
  updatePagination(totalPages, currentPage) {
    const pagination = document.querySelector('.pagination');
    
    if (!pagination) return;
    
    pagination.innerHTML = '';
    
    // Previous button
    const prevItem = document.createElement('li');
    prevItem.className = `page-item ${currentPage === 1 ? 'disabled' : ''}`;
    prevItem.innerHTML = `<a class="page-link" href="#">Précédent</a>`;
    if (currentPage > 1) {
      prevItem.addEventListener('click', (e) => {
        e.preventDefault();
        this.goToPage(currentPage - 1);
      });
    }
    pagination.appendChild(prevItem);
    
    // Page numbers
    for (let i = 1; i <= totalPages; i++) {
      const pageItem = document.createElement('li');
      pageItem.className = `page-item ${i === currentPage ? 'active' : ''}`;
      pageItem.innerHTML = `<a class="page-link" href="#">${i}</a>`;
      pageItem.addEventListener('click', (e) => {
        e.preventDefault();
        this.goToPage(i);
      });
      pagination.appendChild(pageItem);
    }
    
    // Next button
    const nextItem = document.createElement('li');
    nextItem.className = `page-item ${currentPage === totalPages ? 'disabled' : ''}`;
    nextItem.innerHTML = `<a class="page-link" href="#">Suivant</a>`;
    if (currentPage < totalPages) {
      nextItem.addEventListener('click', (e) => {
        e.preventDefault();
        this.goToPage(currentPage + 1);
      });
    }
    pagination.appendChild(nextItem);
  },
  
  /**
   * Go to specific page
   */
  goToPage(page) {
    this.currentPage = page;
    this.loadStock();
  },
  
  /**
   * Open add medication modal
   */
  openAddModal() {
    // This would open a Bootstrap modal
    // For now, we'll use a simple prompt
    const name = prompt('Nom du médicament:');
    if (!name) return;
    
    const category = prompt('Catégorie:');
    const quantity = parseInt(prompt('Quantité:'));
    const unit = prompt('Unité (ex: Boîtes):') || 'Boîtes';
    
    this.addMedication({
      name: name,
      category: category,
      quantity: quantity,
      unit: unit
    });
  },
  
  /**
   * Open edit medication modal
   */
  openEditModal(medication) {
    // This would open a Bootstrap modal with pre-filled data
    // For now, we'll use prompts
    const quantity = parseInt(prompt('Nouvelle quantité:', medication.quantity));
    if (isNaN(quantity)) return;
    
    this.updateMedication(medication.id, {
      name: medication.name,
      category: medication.category,
      quantity: quantity,
      unit: medication.unit
    });
  },
  
  /**
   * Initialize stock management
   */
  init() {
    // Load initial stock
    this.loadStock();
    
    // Search input handler
    const searchInput = document.getElementById('searchMedication');
    if (searchInput) {
      searchInput.addEventListener('input', Helpers.debounce((e) => {
        this.search(e.target.value);
      }, 500));
    }
    
    // Category filter handler
    const categorySelect = document.querySelector('.stock-header select');
    if (categorySelect) {
      categorySelect.addEventListener('change', (e) => {
        this.filterByCategory(e.target.value);
      });
    }
    
    // Add medication button
    const addBtn = document.getElementById('addMedicationBtn');
    if (addBtn) {
      addBtn.addEventListener('click', () => {
        this.openAddModal();
      });
    }
  }
};

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    if (document.getElementById('stockSection')) {
      PharmacyStock.init();
    }
  });
} else {
  if (document.getElementById('stockSection')) {
    PharmacyStock.init();
  }
}