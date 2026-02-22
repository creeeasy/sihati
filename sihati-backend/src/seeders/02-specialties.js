'use strict';

module.exports = {
  async up(queryInterface) {
    await queryInterface.bulkInsert('specialties', [
      { name_fr: 'Médecine Générale',  name_ar: 'الطب العام',               icon: 'stethoscope',  created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Pédiatrie',          name_ar: 'طب الأطفال',               icon: 'baby',          created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Cardiologie',        name_ar: 'طب القلب',                 icon: 'heart',         created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Dermatologie',       name_ar: 'طب الجلد',                 icon: 'skin',          created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Gynécologie',        name_ar: 'أمراض النساء',             icon: 'female',        created_at: new Date(), updated_at: new Date() },
      { name_fr: 'ORL',                name_ar: 'أنف أذن حنجرة',            icon: 'ear',           created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Ophtalmologie',      name_ar: 'طب العيون',                icon: 'eye',           created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Dentiste',           name_ar: 'طب الأسنان',               icon: 'tooth',         created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Psychiatrie',        name_ar: 'الطب النفسي',              icon: 'brain',         created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Neurologie',         name_ar: 'طب الأعصاب',               icon: 'nerve',         created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Orthopédie',         name_ar: 'جراحة العظام',             icon: 'bone',          created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Urologie',           name_ar: 'المسالك البولية',          icon: 'kidney',        created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Gastro-entérologie', name_ar: 'أمراض الجهاز الهضمي',     icon: 'stomach',       created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Pneumologie',        name_ar: 'أمراض الجهاز التنفسي',     icon: 'lungs',         created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Chirurgie Générale', name_ar: 'الجراحة العامة',           icon: 'scalpel',       created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Endocrinologie',     name_ar: 'الغدد الصماء',             icon: 'hormone',       created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Rhumatologie',       name_ar: 'أمراض الروماتيزم',         icon: 'joint',         created_at: new Date(), updated_at: new Date() },
      { name_fr: 'Néphrologie',        name_ar: 'أمراض الكلى',              icon: 'kidney2',       created_at: new Date(), updated_at: new Date() },
    ]);
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete('specialties', null, {});
  },
};