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
  peopleWaiting: number;
  bookingsAhead: number;
  activeServiceCounters: number;
  averageServiceDurationMinutes: number;
  isAvailable: boolean;
};
