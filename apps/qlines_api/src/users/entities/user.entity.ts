import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { UserRole } from '../models/user-role';

@Entity({ name: 'users' })
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'full_name', type: 'varchar', length: 160 })
  fullName: string;

  @Column({ type: 'varchar', length: 254, unique: true })
  email: string;

  @Column({ name: 'password_hash', type: 'varchar', length: 256 })
  passwordHash: string;

  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive: boolean;

  @Column({ name: 'is_email_verified', type: 'boolean', default: false })
  isEmailVerified: boolean;

  @Column({ type: 'varchar', length: 20, default: UserRole.Customer })
  role: UserRole;

  @Column({
    name: 'employee_branch_id',
    type: 'varchar',
    length: 64,
    nullable: true,
  })
  employeeBranchId: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date;
}
