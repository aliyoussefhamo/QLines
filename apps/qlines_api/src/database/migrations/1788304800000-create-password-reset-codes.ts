import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreatePasswordResetCodes1788304800000 implements MigrationInterface {
  name = 'CreatePasswordResetCodes1788304800000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "password_reset_codes" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL,
        "code_hash" varchar(64) NOT NULL,
        "expires_at" timestamptz NOT NULL,
        "attempt_count" integer NOT NULL DEFAULT 0,
        "last_sent_at" timestamptz NOT NULL,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT "CHK_password_reset_attempts"
          CHECK ("attempt_count" >= 0 AND "attempt_count" <= 5),
        CONSTRAINT "PK_password_reset_codes" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_password_reset_user" UNIQUE ("user_id"),
        CONSTRAINT "FK_password_reset_user" FOREIGN KEY ("user_id")
          REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP TABLE "password_reset_codes"');
  }
}
