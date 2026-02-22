import {
  Model,
  DataTypes,
  Optional,
} from 'sequelize';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import env from '../config/env';
import sequelize from '../config/database';

export interface UserAttributes {
  id: number;
  email: string;
  password: string;
  fullName: string;
  phoneNumber: string;
  role: 'patient' | 'pharmacy' | 'doctor';
  isActive: boolean;
  wilaya?: string;
  address?: string;
  profileImage?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface UserCreationAttributes
  extends Optional<UserAttributes, 'id' | 'isActive' | 'role'> {}

class User
  extends Model<UserAttributes, UserCreationAttributes>
  implements UserAttributes
{
  public id!: number;
  public email!: string;
  public password!: string;
  public fullName!: string;
  public phoneNumber!: string;
  public role!: 'patient' | 'pharmacy' | 'doctor';
  public isActive!: boolean;
  public wilaya?: string;
  public address?: string;
  public profileImage?: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  // Compare plain password with hashed password
  public async comparePassword(password: string): Promise<boolean> {
    return bcrypt.compare(password, this.password);
  }

  // Generate JWT token
  public generateToken(): string {
return jwt.sign(
  { id: this.id, email: this.email, role: this.role },
  env.JWT_SECRET!,
  { expiresIn: env.JWT_EXPIRES_IN as jwt.SignOptions["expiresIn"] }
);
  }

  // Never return password in JSON responses
  public toJSON(): Omit<UserAttributes, 'password'> {
    const values = super.toJSON() as UserAttributes;
    delete (values as any).password;
    return values;
  }

  // Associations
  public static associate(): void {
    const { Conversation } = sequelize.models;
    User.hasMany(Conversation, { foreignKey: 'userId', as: 'conversations' });
  }
}

User.init(
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true,
      },
    },
    password: {
      type: DataTypes.STRING(100),
      allowNull: false,
      validate: {
        len: [60, 100], // bcrypt hash length
      },
    },
    fullName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    phoneNumber: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        is: /^0[0-9]{9}$/, // Algerian format: 0XXXXXXXXX
      },
    },
    role: {
      type: DataTypes.ENUM('patient', 'pharmacy', 'doctor'),
      allowNull: false,
      defaultValue: 'patient',
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    wilaya: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    address: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    profileImage: {
      type: DataTypes.STRING,
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'users',
    timestamps: true,
    underscored: true,
    hooks: {
      beforeCreate: async (user: User) => {
        user.password = await bcrypt.hash(user.password, 10);
      },
      beforeUpdate: async (user: User) => {
        if (user.changed('password')) {
          user.password = await bcrypt.hash(user.password, 10);
        }
      },
    },
  }
);

export default User;