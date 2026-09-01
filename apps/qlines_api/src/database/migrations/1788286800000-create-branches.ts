import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateBranches1788286800000 implements MigrationInterface {
  name = 'CreateBranches1788286800000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "branches" (
        "id" varchar(64) NOT NULL,
        "organization_id" varchar(64) NOT NULL,
        "name" varchar(160) NOT NULL,
        "address" varchar(240) NOT NULL,
        "latitude" double precision NOT NULL,
        "longitude" double precision NOT NULL,
        "people_waiting" integer NOT NULL DEFAULT 0,
        "bookings_ahead" integer NOT NULL DEFAULT 0,
        "active_service_counters" integer NOT NULL DEFAULT 1,
        "average_service_duration_minutes" integer NOT NULL,
        "is_active" boolean NOT NULL DEFAULT true,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT "CHK_branches_queue_values" CHECK (
          "people_waiting" >= 0 AND "bookings_ahead" >= 0 AND
          "active_service_counters" > 0 AND
          "average_service_duration_minutes" > 0
        ),
        CONSTRAINT "PK_branches" PRIMARY KEY ("id"),
        CONSTRAINT "FK_branches_organization" FOREIGN KEY ("organization_id")
          REFERENCES "organizations"("id") ON DELETE CASCADE
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_branches_organization_active"
      ON "branches" ("organization_id", "is_active")
    `);

    await queryRunner.query(
      `INSERT INTO "branches" (
        "id", "organization_id", "name", "address", "latitude", "longitude",
        "people_waiting", "bookings_ahead", "active_service_counters",
        "average_service_duration_minutes", "is_active"
      ) VALUES
        ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,true),
        ($11,$12,$13,$14,$15,$16,$17,$18,$19,$20,true),
        ($21,$22,$23,$24,$25,$26,$27,$28,$29,$30,true),
        ($31,$32,$33,$34,$35,$36,$37,$38,$39,$40,true),
        ($41,$42,$43,$44,$45,$46,$47,$48,$49,$50,true),
        ($51,$52,$53,$54,$55,$56,$57,$58,$59,$60,true)`,
      [
        'citizen-center-mazzeh',
        'citizen-center',
        'مركز خدمة المواطن - المزة',
        'المزة، دمشق',
        33.5038,
        36.2501,
        12,
        4,
        2,
        8,
        'citizen-center-baramekeh',
        'citizen-center',
        'مركز خدمة المواطن - البرامكة',
        'البرامكة، دمشق',
        33.5062,
        36.2911,
        7,
        3,
        2,
        8,
        'citizen-center-bab-touma',
        'citizen-center',
        'مركز خدمة المواطن - باب توما',
        'باب توما، دمشق',
        33.5148,
        36.3164,
        18,
        5,
        3,
        8,
        'telecom-mazzeh',
        'telecom',
        'فرع الاتصالات - المزة',
        'المزة، دمشق',
        33.5017,
        36.2478,
        9,
        2,
        2,
        6,
        'telecom-victoria',
        'telecom',
        'فرع الاتصالات - الحريقة',
        'الحريقة، دمشق',
        33.5102,
        36.3047,
        14,
        4,
        2,
        6,
        'university-baramekeh',
        'university',
        'مركز الخدمات الجامعية - البرامكة',
        'البرامكة، دمشق',
        33.5053,
        36.2894,
        20,
        6,
        3,
        10,
      ],
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP TABLE "branches"');
  }
}
