import { Injectable } from '@nestjs/common';
import { BranchService } from './models/branch-service';

@Injectable()
export class BranchServicesService {
  private readonly branchServices: BranchService[] = [
    {
      id: 'mazzeh-civil-record',
      branchId: 'citizen-center-mazzeh',
      name: 'إخراج قيد مدني',
      description: 'إصدار وثيقة قيد مدني للمواطن',
      requiredDocuments: ['البطاقة الشخصية', 'صورة عن البطاقة الشخصية'],
      requirements: ['حضور صاحب العلاقة أو وكيله القانوني'],
      steps: ['حجز الدور', 'تقديم الوثائق', 'دفع الرسوم', 'استلام الوثيقة'],
      notes: ['يجب أن تكون البطاقة الشخصية سارية المفعول'],
      feeAmount: 5000,
      currency: 'SYP',
      averageServiceDurationMinutes: 8,
      isAvailable: true,
    },
    {
      id: 'mazzeh-document-certification',
      branchId: 'citizen-center-mazzeh',
      name: 'تصديق الوثائق',
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
      feeAmount: 7500,
      currency: 'SYP',
      averageServiceDurationMinutes: 12,
      isAvailable: true,
    },
    {
      id: 'baramekeh-civil-record',
      branchId: 'citizen-center-baramekeh',
      name: 'إخراج قيد مدني',
      description: 'إصدار وثيقة قيد مدني للمواطن',
      requiredDocuments: ['البطاقة الشخصية', 'صورة عن البطاقة الشخصية'],
      requirements: ['حضور صاحب العلاقة أو وكيله القانوني'],
      steps: ['حجز الدور', 'تقديم الوثائق', 'دفع الرسوم', 'استلام الوثيقة'],
      notes: ['يجب أن تكون البطاقة الشخصية سارية المفعول'],
      feeAmount: 5000,
      currency: 'SYP',
      averageServiceDurationMinutes: 8,
      isAvailable: true,
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
      requirements: ['أن يكون مقدم الطلب أحد أفراد الأسرة أو وكيلاً قانونياً'],
      steps: [
        'حجز الدور',
        'تقديم الطلب والوثائق',
        'دفع الرسوم',
        'استلام البيان',
      ],
      notes: ['قد يلزم تحديث بيانات الأسرة قبل إصدار البيان'],
      feeAmount: 6000,
      currency: 'SYP',
      averageServiceDurationMinutes: 10,
      isAvailable: true,
    },
    {
      id: 'bab-touma-document-certification',
      branchId: 'citizen-center-bab-touma',
      name: 'تصديق الوثائق',
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
      feeAmount: 7500,
      currency: 'SYP',
      averageServiceDurationMinutes: 12,
      isAvailable: true,
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
      averageServiceDurationMinutes: 5,
      isAvailable: true,
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
      averageServiceDurationMinutes: 10,
      isAvailable: true,
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
      averageServiceDurationMinutes: 10,
      isAvailable: true,
    },
  ];

  findAll(): BranchService[] {
    return this.branchServices;
  }

  findById(serviceId: string): BranchService | undefined {
    return this.branchServices.find(
      (service) => service.id === serviceId && service.isAvailable,
    );
  }

  findByBranchId(branchId: string): BranchService[] {
    return this.branchServices.filter(
      (service) => service.branchId === branchId && service.isAvailable,
    );
  }
}
