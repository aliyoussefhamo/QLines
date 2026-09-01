import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryColumn,
  UpdateDateColumn,
} from 'typeorm';
import { BranchEntity } from '../../branches/entities/branch.entity';

@Entity({ name: 'branch_services' })
export class BranchServiceEntity {
  @PrimaryColumn({ type: 'varchar', length: 80 })
  id: string;

  @Column({ name: 'branch_id', type: 'varchar', length: 64 })
  branchId: string;

  @ManyToOne(() => BranchEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'branch_id' })
  branch: BranchEntity;

  @Column({ type: 'varchar', length: 160 })
  name: string;

  @Column({ type: 'text' })
  description: string;

  @Column({ name: 'required_documents', type: 'jsonb', default: () => "'[]'" })
  requiredDocuments: string[];

  @Column({ type: 'jsonb', default: () => "'[]'" })
  requirements: string[];

  @Column({ type: 'jsonb', default: () => "'[]'" })
  steps: string[];

  @Column({ type: 'jsonb', default: () => "'[]'" })
  notes: string[];

  @Column({ name: 'fee_amount', type: 'integer', nullable: true })
  feeAmount: number | null;

  @Column({ type: 'varchar', length: 8, nullable: true })
  currency: string | null;

  @Column({ name: 'people_waiting', type: 'integer', default: 0 })
  peopleWaiting: number;

  @Column({ name: 'bookings_ahead', type: 'integer', default: 0 })
  bookingsAhead: number;

  @Column({ name: 'active_service_counters', type: 'integer', default: 1 })
  activeServiceCounters: number;

  @Column({ name: 'average_service_duration_minutes', type: 'integer' })
  averageServiceDurationMinutes: number;

  @Column({ name: 'is_available', type: 'boolean', default: true })
  isAvailable: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date;
}
