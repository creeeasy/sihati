// pharmacy/js/pharmacy-translations.js
const PH_TRANSLATIONS = {
  fr: {
    // Pages
    dashboard_title: "Tableau de bord",
    dashboard_subtitle: "Gérez votre pharmacie",
    inventory_title: "Gestion du stock",
    inventory_subtitle: "Gérez vos médicaments en stock",
    medications_title: "Médicaments",
    medications_subtitle: "Recherchez et consultez les médicaments",
    profile_title: "Ma pharmacie",
    profile_subtitle: "Modifiez vos informations",

    // Nav
    nav_navigation: "Navigation",
    brand_sub: "Espace Pharmacie",

    // Sidebar placeholders
    loading_sidebar: "Chargement...",
    logout_confirm: "Voulez-vous vous déconnecter ?",

    // Duty
    on_duty: "De garde",
    off_duty: "Hors garde",
    duty_current: "Statut actuel :",
    activate_duty: "Activer la garde",
    deactivate_duty: "Désactiver la garde",
    duty_activated: "Garde activée",
    duty_deactivated: "Garde désactivée",

    // Stock & dashboard
    meds_in_stock: "Médicaments en stock",
    low_stock: "Stock faible",
    out_of_stock: "Rupture de stock",
    search_med: "Rechercher un médicament",
    search_med_ph: "Nom du médicament...",
    recent_stock: "Stock récent",
    refresh: "Rafraîchir",
    view_all_stock: "Voir tout le stock →",
    duty_section: "Pharmacie de garde",
    med_col: "Médicament",
    qty_col: "Quantité",
    price_col: "Prix",
    status_col: "Statut",
    actions_col: "Actions",
    in_stock: "Disponible",
    stock_low: "Stock faible",
    rupture: "Rupture",

    // Inventory
    inventory_heading: "Gestion du stock",
    filter_ph: "Filtrer...",

    // Medications
    med_search_heading: "Recherche de médicaments",
    med_search_ph: "Rechercher un médicament (nom, DCI, fabricant)...",
    popular_meds: "Médicaments populaires",
    results: "Résultats",
    no_results: "Aucun résultat",
    search_error: "Erreur de recherche",
    prescription: "Prescription",
    see_stock: "Voir stock",

    // Medication details modal
    form_label: "Forme",
    dosage_label: "Dosage",
    manufacturer: "Fabricant",
    prescription_req: "Prescription requise",
    indications: "Indications",
    contraindications: "Contre-indications",
    side_effects: "Effets secondaires",
    update_stock_btn: "Mettre à jour le stock",
    see_pharmacies: "Voir pharmacies avec stock",
    pharmacies_with_stock: "Pharmacies avec ce médicament",
    no_pharmacies: "Aucune pharmacie avec ce médicament",
    call_btn: "Appeler",
    directions_btn: "Itinéraire",
    scan_prompt: "Scannez le code-barres ou entrez le numéro :",
    med_not_found: "Médicament non trouvé",

    // Stock modal
    stock_qty: "Quantité en stock",
    stock_price: "Prix (DA)",
    available: "Disponible",
    yes: "Oui",
    no_rupture: "Non (rupture)",
    stock_updated: "Stock mis à jour",
    save: "Enregistrer",
    cancel: "Annuler",
    modify_stock: "Modifier stock",

    // Profile
    pharmacy_name: "Nom de la pharmacie",
    phone: "Téléphone",
    whatsapp: "WhatsApp",
    email: "Email",
    wilaya: "Wilaya",
    commune: "Commune",
    address: "Adresse",
    save_changes: "Enregistrer les modifications",
    verified: "Compte vérifié",
    pending_verif: "En attente de vérification",
    profile_updated: "Profil mis à jour",
    required_fields: "Champs obligatoires manquants",

    // Loading
    loading: "Chargement en cours...",
    loading_short: "Chargement...",

    // Auth screens
    nav_back_home: "Retour à l'accueil",
    login_title: "Sihati Pharmacie",
    login_subtitle: "Connectez-vous à votre espace professionnel",
    label_email: "Email",
    label_password: "Mot de passe",
    remember_me: "Se souvenir de moi",
    forgot_password: "Mot de passe oublié ?",
    login_btn: "Se connecter",
    logging_in: "Connexion...",
    divider_new: "Nouveau sur Sihati",
    create_account: "Créer un compte pharmacie",
    empty_fields_error: "Veuillez remplir tous les champs",
    no_pharmacy_error: "Aucune pharmacie associée à ce compte",
    login_success: "Connexion réussie ! Redirection...",
    login_error: "Email ou mot de passe incorrect",
    // Register screen
    register_title: "Sihati Pharmacie",
    register_subtitle: "Créez votre espace professionnel",
    label_pharmacy_name: "Nom de la pharmacie",
    label_phone: "Téléphone",
    label_email: "Email",
    label_password: "Mot de passe",
    label_confirm: "Confirmer mot de passe",
    label_address: "Adresse",
    label_wilaya: "Wilaya",
    label_commune: "Commune",
    label_whatsapp: "WhatsApp (optionnel)",
    label_lat: "Latitude",
    label_lng: "Longitude",
    wilaya_placeholder: "Sélectionnez une wilaya",
    get_location: "Utiliser ma position actuelle",
    hours_note:
      "Vous pourrez configurer vos horaires après inscription dans votre profil.",
    register_btn: "Créer mon compte pharmacie",
    registering: "Création du compte...",
    footer_login: "Déjà inscrit ?",
    login_link: "Se connecter",
    success_register: "Compte créé avec succès ! Redirection...",
    err_required: "Veuillez remplir tous les champs obligatoires",
    err_pwd_match: "Les mots de passe ne correspondent pas",
    err_pwd_short: "Le mot de passe doit contenir au moins 8 caractères",
    err_phone: "Numéro de téléphone invalide (ex: 0555123456)",
    err_gps: "Veuillez saisir des coordonnées GPS valides",
    gps_loading: "Récupération de la position...",
    gps_success: "Position GPS récupérée",
    gps_denied: "Permission refusée. Activez la géolocalisation.",
    gps_unavailable: "Position indisponible.",
    gps_timeout: "Délai dépassé.",
    gps_error: "Erreur de géolocalisation.",
    gps_unsupported: "Géolocalisation non supportée",
    server_error: "Erreur lors de l'inscription",
    pwd_strength_note: "Force du mot de passe",
    section_gps: "Localisation GPS",
    section_hours: "Horaires d'ouverture",

    // Forgot password screen
    forgot_title: "Mot de passe oublié",
    forgot_subtitle:
      "Entrez votre email pour recevoir un lien de réinitialisation",
    forgot_email_label: "Adresse email",
    forgot_send_btn: "Envoyer le lien",
    forgot_sending: "Envoi en cours...",
    forgot_success_title: "Email envoyé !",
    forgot_success_msg:
      "Si un compte existe avec cet email, vous recevrez un lien de réinitialisation dans quelques minutes.",
    forgot_back_login: "Retour à la connexion",
    forgot_error: "Une erreur est survenue. Veuillez réessayer.",
  },
  ar: {
    // Pages
    dashboard_title: "لوحة القيادة",
    dashboard_subtitle: "أدر صيدليتك",
    inventory_title: "إدارة المخزون",
    inventory_subtitle: "أدر أدويتك في المخزون",
    medications_title: "الأدوية",
    medications_subtitle: "ابحث واستعرض الأدوية",
    profile_title: "صيدليتي",
    profile_subtitle: "عدّل معلوماتك",

    // Nav
    nav_navigation: "التنقل",
    brand_sub: "فضاء الصيدلية",

    // Sidebar
    loading_sidebar: "جار التحميل...",
    logout_confirm: "هل تريد تسجيل الخروج؟",

    // Duty
    on_duty: "في الحراسة",
    off_duty: "خارج الحراسة",
    duty_current: "الحالة الحالية:",
    activate_duty: "تفعيل الحراسة",
    deactivate_duty: "إلغاء الحراسة",
    duty_activated: "تم تفعيل الحراسة",
    duty_deactivated: "تم إلغاء الحراسة",

    // Stock & dashboard
    meds_in_stock: "أدوية في المخزون",
    low_stock: "مخزون منخفض",
    out_of_stock: "نفاد المخزون",
    search_med: "البحث عن دواء",
    search_med_ph: "اسم الدواء...",
    recent_stock: "المخزون الأخير",
    refresh: "تحديث",
    view_all_stock: "عرض كل المخزون ←",
    duty_section: "صيدلية الحراسة",
    med_col: "الدواء",
    qty_col: "الكمية",
    price_col: "السعر",
    status_col: "الحالة",
    actions_col: "الإجراءات",
    in_stock: "متوفر",
    stock_low: "مخزون منخفض",
    rupture: "نفاد",

    // Inventory
    inventory_heading: "إدارة المخزون",
    filter_ph: "تصفية...",

    // Medications
    med_search_heading: "البحث عن أدوية",
    med_search_ph: "ابحث عن دواء (الاسم، DCI، الصانع)...",
    popular_meds: "الأدوية الأكثر طلبًا",
    results: "نتائج",
    no_results: "لا توجد نتائج",
    search_error: "خطأ في البحث",
    prescription: "وصفة طبية",
    see_stock: "عرض المخزون",

    // Medication details
    form_label: "الشكل",
    dosage_label: "الجرعة",
    manufacturer: "الصانع",
    prescription_req: "يستلزم وصفة طبية",
    indications: "دواعي الاستعمال",
    contraindications: "موانع الاستعمال",
    side_effects: "الآثار الجانبية",
    update_stock_btn: "تحديث المخزون",
    see_pharmacies: "صيدليات مع مخزون",
    pharmacies_with_stock: "الصيدليات التي تملك هذا الدواء",
    no_pharmacies: "لا توجد صيدلية تملك هذا الدواء",
    call_btn: "اتصال",
    directions_btn: "الاتجاهات",
    scan_prompt: "امسح الباركود أو أدخل الرقم:",
    med_not_found: "الدواء غير موجود",

    // Stock modal
    stock_qty: "الكمية في المخزون",
    stock_price: "السعر (د.ج)",
    available: "متوفر",
    yes: "نعم",
    no_rupture: "لا (نفاد)",
    stock_updated: "تم تحديث المخزون",
    save: "حفظ",
    cancel: "إلغاء",
    modify_stock: "تعديل المخزون",

    // Profile
    pharmacy_name: "اسم الصيدلية",
    phone: "الهاتف",
    whatsapp: "واتساب",
    email: "البريد الإلكتروني",
    wilaya: "الولاية",
    commune: "البلدية",
    address: "العنوان",
    save_changes: "حفظ التعديلات",
    verified: "حساب موثّق",
    pending_verif: "بانتظار التحقق",
    profile_updated: "تم تحديث الملف",
    required_fields: "حقول مطلوبة مفقودة",

    // Loading
    loading: "جار التحميل...",
    loading_short: "تحميل...",

    // Auth screens
    nav_back_home: "العودة إلى الصفحة الرئيسية",
    login_title: "صحتي صيدلية",
    login_subtitle: "سجّل دخولك إلى مساحتك المهنية",
    label_email: "البريد الإلكتروني",
    label_password: "كلمة المرور",
    remember_me: "تذكّرني",
    forgot_password: "نسيت كلمة المرور؟",
    login_btn: "تسجيل الدخول",
    logging_in: "جار التسجيل...",
    divider_new: "جديد على صحتي",
    create_account: "إنشاء حساب صيدلية",
    empty_fields_error: "يرجى ملء جميع الحقول",
    no_pharmacy_error: "لا توجد صيدلية مرتبطة بهذا الحساب",
    login_success: "تم تسجيل الدخول! جار التوجيه...",
    login_error: "البريد الإلكتروني أو كلمة المرور غير صحيحة",

    // Register screen
    register_title: "صحتي صيدلية",
    register_subtitle: "أنشئ فضاءك المهني",
    label_pharmacy_name: "اسم الصيدلية",
    label_phone: "الهاتف",
    label_email: "البريد الإلكتروني",
    label_password: "كلمة المرور",
    label_confirm: "تأكيد كلمة المرور",
    label_address: "العنوان",
    label_wilaya: "الولاية",
    label_commune: "البلدية",
    label_whatsapp: "واتساب (اختياري)",
    label_lat: "خط العرض",
    label_lng: "خط الطول",
    wilaya_placeholder: "اختر ولاية",
    get_location: "استخدام موقعي الحالي",
    hours_note: "يمكنك ضبط أوقات العمل بعد التسجيل من ملفك الشخصي.",
    register_btn: "إنشاء حسابي كصيدلية",
    registering: "جارٍ الإنشاء...",
    footer_login: "مسجّل بالفعل؟",
    login_link: "تسجيل الدخول",
    success_register: "تم إنشاء الحساب! جارٍ التوجيه...",
    err_required: "يرجى ملء جميع الحقول الإلزامية",
    err_pwd_match: "كلمتا المرور غير متطابقتين",
    err_pwd_short: "كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل",
    err_phone: "رقم الهاتف غير صالح (مثال: 0555123456)",
    err_gps: "يرجى إدخال إحداثيات GPS صحيحة",
    gps_loading: "جارٍ تحديد الموقع...",
    gps_success: "تم الحصول على الموقع GPS",
    gps_denied: "تم رفض الإذن. فعّل تحديد الموقع.",
    gps_unavailable: "الموقع غير متاح.",
    gps_timeout: "انتهت المهلة.",
    gps_error: "خطأ في تحديد الموقع.",
    gps_unsupported: "الجيولوكيشن غير مدعوم",
    server_error: "خطأ أثناء التسجيل",
    pwd_strength_note: "قوة كلمة المرور",
    section_gps: "الموقع الجغرافي",
    section_hours: "أوقات العمل",

    // Forgot password screen
    forgot_title: "نسيت كلمة المرور",
    forgot_subtitle: "أدخل بريدك الإلكتروني لاستلام رابط إعادة التعيين",
    forgot_email_label: "عنوان البريد الإلكتروني",
    forgot_send_btn: "إرسال الرابط",
    forgot_sending: "جار الإرسال...",
    forgot_success_title: "تم الإرسال!",
    forgot_success_msg:
      "إذا كان الحساب موجوداً، ستتلقى رابط إعادة التعيين في غضون دقائق.",
    forgot_back_login: "العودة إلى تسجيل الدخول",
    forgot_error: "حدث خطأ. يرجى المحاولة مجدداً.",
  },
};

let phLang = localStorage.getItem("sihati_lang") || "fr";

function pt(key) {
  const translations = PH_TRANSLATIONS[phLang] || PH_TRANSLATIONS["fr"];
  return translations[key] || key;
}

function setPhLanguage(lang) {
  phLang = lang;
  localStorage.setItem("sihati_lang", lang);
  document.documentElement.lang = lang;
  document.documentElement.dir = lang === "ar" ? "rtl" : "ltr";
}

// Init on load
setPhLanguage(phLang);
