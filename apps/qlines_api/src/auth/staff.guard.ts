import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import type { AuthenticatedRequest } from './auth.guard';
import { UserRole } from '../users/models/user-role';

@Injectable()
export class StaffGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const user = context
      .switchToHttp()
      .getRequest<AuthenticatedRequest>().authUser;
    if (
      (user.role !== UserRole.Staff && user.role !== UserRole.Admin) ||
      !user.employeeBranchId
    ) {
      throw new ForbiddenException('Staff access is required');
    }
    return true;
  }
}
