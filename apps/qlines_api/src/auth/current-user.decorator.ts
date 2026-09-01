import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { AuthenticatedRequest } from './auth.guard';
import type { TokenPayload } from './token.service';

export const CurrentUser = createParamDecorator(
  (_data: unknown, context: ExecutionContext): TokenPayload => {
    return context.switchToHttp().getRequest<AuthenticatedRequest>().authUser;
  },
);
