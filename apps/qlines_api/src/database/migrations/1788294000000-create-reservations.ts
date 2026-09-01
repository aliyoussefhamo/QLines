import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReservations1788294000000 implements MigrationInterface {
  name = 'CreateReservations1788294000000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TYPE "reservation_status" AS ENUM
        ('waiting', 'called', 'completed', 'cancelled')
    `);
    await queryRunner.query(`
      CREATE TABLE "reservations" (
        "id" uuid NOT NULL,
        "user_id" varchar(128) NOT NULL,
        "branch_id" varchar(64) NOT NULL,
        "service_id" varchar(80) NOT NULL,
        "ticket_number" integer NOT NULL,
        "status" "reservation_status" NOT NULL DEFAULT 'waiting',
        "estimated_turn_at" timestamptz NOT NULL,
        "qr_token" uuid NOT NULL,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT "CHK_reservations_ticket" CHECK ("ticket_number" > 0),
        CONSTRAINT "PK_reservations" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_reservations_qr_token" UNIQUE ("qr_token"),
        CONSTRAINT "UQ_reservations_branch_ticket"
          UNIQUE ("branch_id", "ticket_number"),
        CONSTRAINT "FK_reservations_branch" FOREIGN KEY ("branch_id")
          REFERENCES "branches"("id") ON DELETE RESTRICT,
        CONSTRAINT "FK_reservations_service" FOREIGN KEY ("service_id")
          REFERENCES "branch_services"("id") ON DELETE RESTRICT
      )
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_reservations_queue"
      ON "reservations" ("branch_id", "service_id", "status")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_reservations_user_created"
      ON "reservations" ("user_id", "created_at" DESC)
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP TABLE "reservations"');
    await queryRunner.query('DROP TYPE "reservation_status"');
  }
}
