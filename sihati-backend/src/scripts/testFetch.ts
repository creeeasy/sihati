import sequelize from '../config/database';
import { QueryTypes } from 'sequelize';

async function updateUser() {
  try {
    await sequelize.authenticate();

    await sequelize.query(
      `UPDATE users SET full_name = 'Ourma' WHERE email = 'amina@test.com'`,
      { type: QueryTypes.UPDATE }
    );

    console.log('✅ User updated');

    const updated = await sequelize.query(
      `SELECT id, email, full_name FROM users WHERE email = 'amina@test.com'`,
      { type: QueryTypes.SELECT }
    );

    console.log(updated);

    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

updateUser();