export const EMAIL_SENDER = Symbol('EMAIL_SENDER');

export interface EmailSender {
  sendVerificationCode(email: string, code: string): Promise<void>;
}
