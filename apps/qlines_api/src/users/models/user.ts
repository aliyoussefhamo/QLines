import { UserRole } from './user-role';

export type User = {
  id: string;
  fullName: string;
  email: string;
  role: UserRole;
  employeeBranchId: string | null;
};
