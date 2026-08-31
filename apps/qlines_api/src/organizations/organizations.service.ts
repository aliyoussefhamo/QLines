import { Injectable } from '@nestjs/common';
import { Organization } from './models/organization';

@Injectable()
export class OrganizationsService {
  private readonly organizations: Organization[] = [
    {
      id: 'citizen-center',
      name: 'مركز خدمة المواطن',
      category: 'خدمات حكومية',
      branchCount: 3,
      isActive: true,
    },

    {
      id: 'telecom',
      name: 'شركة الاتصالات',
      category: 'اتصالات',
      branchCount: 2,
      isActive: true,
    },

    {
      id: 'university',
      name: 'مركز الخدمات الجامعية',
      category: 'تعليم',
      branchCount: 1,
      isActive: true,
    },
  ];

  findAll(): Organization[] {
    return this.organizations;
  }
}
