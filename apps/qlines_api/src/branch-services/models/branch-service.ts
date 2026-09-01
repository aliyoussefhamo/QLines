export type BranchService = {
  id: string;
  branchId: string;
  name: string;
  description: string;
  requiredDocuments: string[];
  requirements: string[];
  steps: string[];
  notes: string[];
  feeAmount: number | null;
  currency: string | null;
  averageServiceDurationMinutes: number;
  isAvailable: boolean;
};
