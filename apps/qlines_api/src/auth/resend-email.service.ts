import { BadGatewayException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EmailSender } from './email-sender';

@Injectable()
export class ResendEmailService implements EmailSender {
  constructor(private readonly configService: ConfigService) {}

  async sendVerificationCode(email: string, code: string): Promise<void> {
    await this.send(
      email,
      'رمز التحقق من QLines',
      `رمز التحقق الخاص بك هو: ${code}\n\nتنتهي صلاحية الرمز خلال 10 دقائق. لا تشارك هذا الرمز مع أي شخص.`,
    );
  }

  async sendPasswordResetCode(email: string, code: string): Promise<void> {
    await this.send(
      email,
      'إعادة تعيين كلمة مرور QLines',
      `رمز إعادة تعيين كلمة المرور هو: ${code}\n\nتنتهي صلاحية الرمز خلال 10 دقائق. إذا لم تطلب تغيير كلمة المرور فتجاهل هذه الرسالة.`,
    );
  }

  private async send(
    email: string,
    subject: string,
    text: string,
  ): Promise<void> {
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
        subject,
        text,
      }),
    });

    if (!response.ok) {
      throw new BadGatewayException('Unable to send email');
    }
  }
}
