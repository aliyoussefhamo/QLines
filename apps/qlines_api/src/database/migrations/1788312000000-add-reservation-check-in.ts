import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddReservationCheckIn1788312000000 implements MigrationInterface {
  name = 'AddReservationCheckIn1788312000000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TYPE "reservation_status" ADD VALUE IF NOT EXISTS 'checked_in'
    `);
  }

  async down(): Promise<void> {
    // PostgreSQL enum values require rebuilding the enum to remove safely.
  }
}
