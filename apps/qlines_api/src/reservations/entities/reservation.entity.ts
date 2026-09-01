import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryColumn,
  Unique,
  UpdateDateColumn,
} from 'typeorm';
import { BranchServiceEntity } from '../../branch-services/entities/branch-service.entity';
import { BranchEntity } from '../../branches/entities/branch.entity';
import { ReservationStatus } from '../models/reservation-status';

@Entity({ name: 'reservations' })
@Unique('UQ_reservations_branch_ticket', ['branchId', 'ticketNumber'])
export class ReservationEntity {
  @PrimaryColumn({ type: 'uuid' })
  id: string;

  @Column({ name: 'user_id', type: 'varchar', length: 128 })
  userId: string;

  @Column({ name: 'branch_id', type: 'varchar', length: 64 })
  branchId: string;

  @ManyToOne(() => BranchEntity, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'branch_id' })
  branch: BranchEntity;

  @Column({ name: 'service_id', type: 'varchar', length: 80 })
  serviceId: string;

  @ManyToOne(() => BranchServiceEntity, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'service_id' })
  service: BranchServiceEntity;

  @Column({ name: 'ticket_number', type: 'integer' })
  ticketNumber: number;

  @Column({
    type: 'enum',
    enum: ReservationStatus,
    enumName: 'reservation_status',
    default: ReservationStatus.Waiting,
  })
  status: ReservationStatus;

  @Column({ name: 'estimated_turn_at', type: 'timestamptz' })
  estimatedTurnAt: Date;

  @Column({ name: 'qr_token', type: 'uuid', unique: true })
  qrToken: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date;
}
