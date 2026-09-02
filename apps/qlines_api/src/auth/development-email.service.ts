import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class DevelopmentEmailService {
  private readonly logger = new Logger(DevelopmentEmailService.name);

  sendVerificationCode(email: string, code: string): void {
    this.logger.warn(`[DEV EMAIL] Verification code for ${email}: ${code}`);
  }
}
