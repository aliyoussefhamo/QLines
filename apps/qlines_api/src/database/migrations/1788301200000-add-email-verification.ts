import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddEmailVerification1788301200000 implements MigrationInterface {
  name = 'AddEmailVerification1788301200000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "users"
      ADD COLUMN "is_email_verified" boolean NOT NULL DEFAULT false
    `);
    await queryRunner.query(`
      UPDATE "users" SET "is_email_verified" = true
    `);
    await queryRunner.query(`
      CREATE TABLE "email_verification_codes" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL,
        "code_hash" varchar(64) NOT NULL,
        "expires_at" timestamptz NOT NULL,
        "attempt_count" integer NOT NULL DEFAULT 0,
        "last_sent_at" timestamptz NOT NULL,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT "CHK_email_verification_attempts"
          CHECK ("attempt_count" >= 0 AND "attempt_count" <= 5),
        CONSTRAINT "PK_email_verification_codes" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_email_verification_user" UNIQUE ("user_id"),
        CONSTRAINT "FK_email_verification_user" FOREIGN KEY ("user_id")
          REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP TABLE "email_verification_codes"');
    await queryRunner.query(
      'ALTER TABLE "users" DROP COLUMN "is_email_verified"',
    );
  }
}
