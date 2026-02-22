'use strict';

const bcrypt = require('bcrypt');

module.exports = {
  async up(queryInterface) {
    const hash = (pwd) => bcrypt.hashSync(pwd, 10);

    await queryInterface.bulkInsert('users', [
      {
        email: 'ahmed@test.com',
        password: hash('password123'),
        full_name: 'Ahmed Benali',
        phone_number: '0551234567',
        role: 'patient',
        is_active: true,
        wilaya: 'Alger',
        created_at: new Date(),
        updated_at: new Date(),
      },
      {
        email: 'amina@test.com',
        password: hash('password123'),
        full_name: 'Amina Khelifi',
        phone_number: '0661234567',
        role: 'patient',
        is_active: true,
        wilaya: 'Oran',
        created_at: new Date(),
        updated_at: new Date(),
      },
      {
        email: 'karim@test.com',
        password: hash('password123'),
        full_name: 'Karim Mansouri',
        phone_number: '0771234567',
        role: 'patient',
        is_active: true,
        wilaya: 'Constantine',
        created_at: new Date(),
        updated_at: new Date(),
      },
      {
        email: 'pharmacy@test.com',
        password: hash('password123'),
        full_name: 'Pharmacie Al Amal',
        phone_number: '0552345678',
        role: 'pharmacy',
        is_active: true,
        wilaya: 'Alger',
        created_at: new Date(),
        updated_at: new Date(),
      },
      {
        email: 'doctor@test.com',
        password: hash('password123'),
        full_name: 'Dr. Fatima Zerrouki',
        phone_number: '0662345678',
        role: 'doctor',
        is_active: true,
        wilaya: 'Alger',
        created_at: new Date(),
        updated_at: new Date(),
      },
      {
        email: 'doctor2@test.com',
        password: hash('password123'),
        full_name: 'Dr. Youcef Hadj',
        phone_number: '0772345678',
        role: 'doctor',
        is_active: true,
        wilaya: 'Oran',
        created_at: new Date(),
        updated_at: new Date(),
      },
    ]);
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete('users', null, {});
  },
};