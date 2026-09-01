import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateBranchServices1788290400000 implements MigrationInterface {
  name = 'CreateBranchServices1788290400000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "branch_services" (
        "id" varchar(80) NOT NULL,
        "branch_id" varchar(64) NOT NULL,
        "name" varchar(160) NOT NULL,
        "description" text NOT NULL,
        "required_documents" jsonb NOT NULL DEFAULT '[]',
        "requirements" jsonb NOT NULL DEFAULT '[]',
        "steps" jsonb NOT NULL DEFAULT '[]',
        "notes" jsonb NOT NULL DEFAULT '[]',
        "fee_amount" integer,
        "currency" varchar(8),
        "people_waiting" integer NOT NULL DEFAULT 0,
        "bookings_ahead" integer NOT NULL DEFAULT 0,
        "active_service_counters" integer NOT NULL DEFAULT 1,
        "average_service_duration_minutes" integer NOT NULL,
        "is_available" boolean NOT NULL DEFAULT true,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT "CHK_branch_services_values" CHECK (
          "fee_amount" IS NULL OR "fee_amount" >= 0
        ),
        CONSTRAINT "CHK_branch_services_queue" CHECK (
          "people_waiting" >= 0 AND "bookings_ahead" >= 0 AND
          "active_service_counters" > 0 AND
          "average_service_duration_minutes" > 0
        ),
        CONSTRAINT "PK_branch_services" PRIMARY KEY ("id"),
        CONSTRAINT "FK_branch_services_branch" FOREIGN KEY ("branch_id")
          REFERENCES "branches"("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_branch_services_branch_available"
      ON "branch_services" ("branch_id", "is_available")
    `);

    const commonCivilRecord = {
      description: 'إصدار وثيقة قيد مدني للمواطن',
      requiredDocuments: ['البطاقة الشخصية', 'صورة عن البطاقة الشخصية'],
      requirements: ['حضور صاحب العلاقة أو وكيله القانوني'],
      steps: ['حجز الدور', 'تقديم الوثائق', 'دفع الرسوم', 'استلام الوثيقة'],
      notes: ['يجب أن تكون البطاقة الشخصية سارية المفعول'],
    };
    const commonCertification = {
      description: 'تدقيق وتصديق الوثائق الرسمية',
      requiredDocuments: [
        'الوثيقة الأصلية',
        'صورة عن الوثيقة',
        'البطاقة الشخصية',
      ],
      requirements: ['أن تكون الوثيقة صادرة عن جهة معترف بها'],
      steps: [
        'حجز الدور',
        'تدقيق الوثيقة',
        'دفع الرسوم',
        'استلام الوثيقة المصدقة',
      ],
      notes: ['قد تُطلب نسخة إضافية بحسب نوع الوثيقة'],
    };
    const services = [
      {
        id: 'mazzeh-civil-record',
        branchId: 'citizen-center-mazzeh',
        name: 'إخراج قيد مدني',
        ...commonCivilRecord,
        feeAmount: 5000,
        currency: 'SYP',
        peopleWaiting: 6,
        bookingsAhead: 2,
        activeServiceCounters: 2,
        averageServiceDurationMinutes: 8,
      },
      {
        id: 'mazzeh-document-certification',
        branchId: 'citizen-center-mazzeh',
        name: 'تصديق الوثائق',
        ...commonCertification,
        feeAmount: 7500,
        currency: 'SYP',
        peopleWaiting: 4,
        bookingsAhead: 2,
        activeServiceCounters: 1,
        averageServiceDurationMinutes: 12,
      },
      {
        id: 'baramekeh-civil-record',
        branchId: 'citizen-center-baramekeh',
        name: 'إخراج قيد مدني',
        ...commonCivilRecord,
        feeAmount: 5000,
        currency: 'SYP',
        peopleWaiting: 4,
        bookingsAhead: 1,
        activeServiceCounters: 2,
        averageServiceDurationMinutes: 8,
      },
      {
        id: 'baramekeh-family-record',
        branchId: 'citizen-center-baramekeh',
        name: 'بيان عائلي',
        description: 'إصدار وثيقة بيان عائلي',
        requiredDocuments: [
          'البطاقة الشخصية',
          'دفتر العائلة أو بيانات أفراد الأسرة',
        ],
        requirements: [
          'أن يكون مقدم الطلب أحد أفراد الأسرة أو وكيلاً قانونياً',
        ],
        steps: [
          'حجز الدور',
          'تقديم الطلب والوثائق',
          'دفع الرسوم',
          'استلام البيان',
        ],
        notes: ['قد يلزم تحديث بيانات الأسرة قبل إصدار البيان'],
        feeAmount: 6000,
        currency: 'SYP',
        peopleWaiting: 3,
        bookingsAhead: 2,
        activeServiceCounters: 1,
        averageServiceDurationMinutes: 10,
      },
      {
        id: 'bab-touma-document-certification',
        branchId: 'citizen-center-bab-touma',
        name: 'تصديق الوثائق',
        ...commonCertification,
        feeAmount: 7500,
        currency: 'SYP',
        peopleWaiting: 8,
        bookingsAhead: 3,
        activeServiceCounters: 2,
        averageServiceDurationMinutes: 12,
      },
      {
        id: 'telecom-mazzeh-bill-payment',
        branchId: 'telecom-mazzeh',
        name: 'تسديد فاتورة',
        description: 'تسديد فواتير الهاتف والإنترنت',
        requiredDocuments: ['رقم الهاتف أو رقم الاشتراك', 'الفاتورة إن وجدت'],
        requirements: ['معرفة رقم الحساب المطلوب تسديده'],
        steps: [
          'حجز الدور',
          'تقديم رقم الحساب',
          'تأكيد المبلغ',
          'دفع الفاتورة واستلام الإيصال',
        ],
        notes: ['احتفظ بإيصال الدفع'],
        feeAmount: null,
        currency: null,
        peopleWaiting: 5,
        bookingsAhead: 1,
        activeServiceCounters: 2,
        averageServiceDurationMinutes: 5,
      },
      {
        id: 'telecom-victoria-internet-support',
        branchId: 'telecom-victoria',
        name: 'دعم خدمات الإنترنت',
        description: 'تقديم طلب أو متابعة مشكلة الإنترنت',
        requiredDocuments: [
          'البطاقة الشخصية',
          'رقم اشتراك الإنترنت',
          'رقم هاتف للتواصل',
        ],
        requirements: ['أن يكون الاشتراك باسم مقدم الطلب أو يحمل تفويضاً'],
        steps: [
          'حجز الدور',
          'شرح المشكلة',
          'تسجيل طلب الدعم',
          'استلام رقم المتابعة',
        ],
        notes: ['دوّن رسائل الخطأ أو أحضر صورة عنها إن أمكن'],
        feeAmount: null,
        currency: null,
        peopleWaiting: 7,
        bookingsAhead: 2,
        activeServiceCounters: 2,
        averageServiceDurationMinutes: 10,
      },
      {
        id: 'university-enrollment-document',
        branchId: 'university-baramekeh',
        name: 'مصدقة تسجيل',
        description: 'إصدار مصدقة تسجيل جامعية',
        requiredDocuments: [
          'البطاقة الجامعية',
          'البطاقة الشخصية',
          'إيصال الرسوم إن طُلب',
        ],
        requirements: ['أن يكون الطالب مسجلاً في الفصل الحالي'],
        steps: [
          'حجز الدور',
          'تقديم بيانات الطالب',
          'دفع الرسوم',
          'استلام المصدقة',
        ],
        notes: ['تحقق من كتابة الاسم باللغة المطلوبة قبل الطباعة'],
        feeAmount: 3000,
        currency: 'SYP',
        peopleWaiting: 9,
        bookingsAhead: 3,
        activeServiceCounters: 3,
        averageServiceDurationMinutes: 10,
      },
    ];

    for (const service of services) {
      await queryRunner.query(
        `INSERT INTO "branch_services" (
          "id", "branch_id", "name", "description", "required_documents",
          "requirements", "steps", "notes", "fee_amount", "currency",
          "people_waiting", "bookings_ahead", "active_service_counters",
          "average_service_duration_minutes", "is_available"
        ) VALUES ($1,$2,$3,$4,$5::jsonb,$6::jsonb,$7::jsonb,$8::jsonb,$9,$10,$11,$12,$13,$14,true)`,
        [
          service.id,
          service.branchId,
          service.name,
          service.description,
          JSON.stringify(service.requiredDocuments),
          JSON.stringify(service.requirements),
          JSON.stringify(service.steps),
          JSON.stringify(service.notes),
          service.feeAmount,
          service.currency,
          service.peopleWaiting,
          service.bookingsAhead,
          service.activeServiceCounters,
          service.averageServiceDurationMinutes,
        ],
      );
    }
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP TABLE "branch_services"');
  }
}
