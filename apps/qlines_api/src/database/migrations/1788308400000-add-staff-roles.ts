import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddStaffRoles1788308400000 implements MigrationInterface {
  name = 'AddStaffRoles1788308400000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "users"
      ADD COLUMN "role" varchar(20) NOT NULL DEFAULT 'customer',
      ADD COLUMN "employee_branch_id" varchar(64)
    `);
    await queryRunner.query(`
      ALTER TABLE "users"
      ADD CONSTRAINT "CHK_users_role"
        CHECK ("role" IN ('customer', 'staff', 'admin')),
      ADD CONSTRAINT "FK_users_employee_branch"
        FOREIGN KEY ("employee_branch_id")
        REFERENCES "branches"("id") ON DELETE SET NULL
    `);
    await queryRunner.query(`
      ALTER TYPE "reservation_status" ADD VALUE IF NOT EXISTS 'no_show'
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'ALTER TABLE "users" DROP CONSTRAINT "FK_users_employee_branch"',
    );
    await queryRunner.query(
      'ALTER TABLE "users" DROP CONSTRAINT "CHK_users_role"',
    );
    await queryRunner.query(`
      ALTER TABLE "users"
      DROP COLUMN "employee_branch_id",
      DROP COLUMN "role"
    `);
  }
}
