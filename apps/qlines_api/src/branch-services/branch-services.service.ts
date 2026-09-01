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
      averageServiceDurationMinutes: 8,
      isAvailable: true,
    },
    {
      id: 'mazzeh-document-certification',
      branchId: 'citizen-center-mazzeh',
      name: 'تصديق الوثائق',
      description: 'تدقيق وتصديق الوثائق الرسمية',
      averageServiceDurationMinutes: 12,
      isAvailable: true,
    },
    {
      id: 'baramekeh-civil-record',
      branchId: 'citizen-center-baramekeh',
      name: 'إخراج قيد مدني',
      description: 'إصدار وثيقة قيد مدني للمواطن',
      averageServiceDurationMinutes: 8,
      isAvailable: true,
    },
    {
      id: 'baramekeh-family-record',
      branchId: 'citizen-center-baramekeh',
      name: 'بيان عائلي',
      description: 'إصدار وثيقة بيان عائلي',
      averageServiceDurationMinutes: 10,
      isAvailable: true,
    },
    {
      id: 'bab-touma-document-certification',
      branchId: 'citizen-center-bab-touma',
      name: 'تصديق الوثائق',
      description: 'تدقيق وتصديق الوثائق الرسمية',
      averageServiceDurationMinutes: 12,
      isAvailable: true,
    },
    {
      id: 'telecom-mazzeh-bill-payment',
      branchId: 'telecom-mazzeh',
      name: 'تسديد فاتورة',
      description: 'تسديد فواتير الهاتف والإنترنت',
      averageServiceDurationMinutes: 5,
      isAvailable: true,
    },
    {
      id: 'telecom-victoria-internet-support',
      branchId: 'telecom-victoria',
      name: 'دعم خدمات الإنترنت',
      description: 'تقديم طلب أو متابعة مشكلة الإنترنت',
      averageServiceDurationMinutes: 10,
      isAvailable: true,
    },
    {
      id: 'university-enrollment-document',
      branchId: 'university-baramekeh',
      name: 'مصدقة تسجيل',
      description: 'إصدار مصدقة تسجيل جامعية',
      averageServiceDurationMinutes: 10,
      isAvailable: true,
    },
  ];

  findAll(): BranchService[] {
    return this.branchServices;
  }

  findByBranchId(branchId: string): BranchService[] {
    return this.branchServices.filter(
      (service) => service.branchId === branchId && service.isAvailable,
    );
  }
}
