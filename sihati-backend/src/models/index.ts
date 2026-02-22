import sequelize from '../config/database';

// Import all models
import User from './User';
import Specialty from './Specialty';
import Doctor from './Doctor';
import Pharmacy from './Pharmacy';
import Medication from './Medication';
import PharmacyMedication from './PharmacyMedication';
import Conversation from './Conversation';
import Review from './Review';

// Register models on the sequelize instance
// (needed for cross-model association lookups via sequelize.models)
const models = {
  User,
  Specialty,
  Doctor,
  Pharmacy,
  Medication,
  PharmacyMedication,
  Conversation,
  Review,
};

// Run all associations after all models are registered
Object.values(models).forEach((model) => {
  if (typeof (model as any).associate === 'function') {
    (model as any).associate();
  }
});

export {
  sequelize,
  User,
  Specialty,
  Doctor,
  Pharmacy,
  Medication,
  PharmacyMedication,
  Conversation,
  Review,
};

export default models;