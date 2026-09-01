import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateOrganizations1788283200000 implements MigrationInterface {
  name = 'CreateOrganizations1788283200000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "organizations" (
        "id" varchar(64) NOT NULL,
        "name" varchar(160) NOT NULL,
        "category" varchar(120) NOT NULL,
        "branch_count" integer NOT NULL DEFAULT 0,
        "is_active" boolean NOT NULL DEFAULT true,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT "CHK_organizations_branch_count" CHECK ("branch_count" >= 0),
        CONSTRAINT "PK_organizations" PRIMARY KEY ("id")
      )
    `);

    await queryRunner.query(
      `
        INSERT INTO "organizations"
          ("id", "name", "category", "branch_count", "is_active")
        VALUES
          ($1, $2, $3, $4, true),
          ($5, $6, $7, $8, true),
          ($9, $10, $11, $12, true)
      `,
      [
        'citizen-center',
        'مركز خدمة المواطن',
        'خدمات حكومية',
        3,
        'telecom',
        'شركة الاتصالات',
        'اتصالات',
        2,
        'university',
        'مركز الخدمات الجامعية',
        'تعليم',
        1,
      ],
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP TABLE "organizations"');
  }
}
