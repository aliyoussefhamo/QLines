import { BadGatewayException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EmailSender } from './email-sender';

@Injectable()
export class ResendEmailService implements EmailSender {
  constructor(private readonly configService: ConfigService) {}

  async sendVerificationCode(email: string, code: string): Promise<void> {
    const apiKey = this.configService.getOrThrow<string>('RESEND_API_KEY');
    const from = this.configService.getOrThrow<string>('EMAIL_FROM');
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from,
        to: [email],
        subject: 'رمز التحقق من QLines',
        text: `رمز التحقق الخاص بك هو: ${code}\n\nتنتهي صلاحية الرمز خلال 10 دقائق. لا تشارك هذا الرمز مع أي شخص.`,
      }),
    });

    if (!response.ok) {
      throw new BadGatewayException('Unable to send verification email');
    }
  }
}
