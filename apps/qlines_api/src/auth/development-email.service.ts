import { Injectable, Logger } from '@nestjs/common';
import { EmailSender } from './email-sender';

@Injectable()
export class DevelopmentEmailService implements EmailSender {
  private readonly logger = new Logger(DevelopmentEmailService.name);

  sendVerificationCode(email: string, code: string): Promise<void> {
    this.logger.warn(`[DEV EMAIL] Verification code for ${email}: ${code}`);
    return Promise.resolve();
  }
}
