import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Inject,
  Injectable,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { createHmac, randomInt, timingSafeEqual } from 'node:crypto';
import { Repository } from 'typeorm';
import { UsersService } from '../users/users.service';
import { EMAIL_SENDER } from './email-sender';
import type { EmailSender } from './email-sender';
import { EmailVerificationCodeEntity } from './entities/email-verification-code.entity';
import { JWT_SECRET } from './token.service';

@Injectable()
export class EmailVerificationService {
  static readonly expiresInSeconds = 10 * 60;
  static readonly resendDelaySeconds = 60;

  constructor(
    @InjectRepository(EmailVerificationCodeEntity)
    private readonly codesRepository: Repository<EmailVerificationCodeEntity>,
    @Inject(JWT_SECRET) private readonly secret: string,
    private readonly usersService: UsersService,
    @Inject(EMAIL_SENDER) private readonly emailService: EmailSender,
  ) {}

  async issue(
    userId: string,
    email: string,
    enforceDelay = false,
  ): Promise<void> {
    const existing = await this.codesRepository.findOne({ where: { userId } });
    const now = new Date();
    if (
      enforceDelay &&
      existing &&
      now.getTime() - existing.lastSentAt.getTime() <
        EmailVerificationService.resendDelaySeconds * 1000
    ) {
      throw new HttpException(
        'Wait before requesting another verification code',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    const code = randomInt(0, 1_000_000).toString().padStart(6, '0');
    const entity = existing ?? this.codesRepository.create({ userId });
    entity.codeHash = this.hash(code);
    entity.expiresAt = new Date(
      now.getTime() + EmailVerificationService.expiresInSeconds * 1000,
    );
    entity.attemptCount = 0;
    entity.lastSentAt = now;
    await this.codesRepository.save(entity);
    await this.emailService.sendVerificationCode(email, code);
  }

  async verify(email: string, code: string) {
    const user = await this.usersService.findByEmail(email);
    if (!user || user.isEmailVerified) {
      throw new BadRequestException('Verification code is invalid');
    }
    const entity = await this.codesRepository.findOne({
      where: { userId: user.id },
    });
    if (!entity || entity.expiresAt.getTime() <= Date.now()) {
      throw new BadRequestException('Verification code is invalid or expired');
    }
    if (entity.attemptCount >= 5) {
      throw new HttpException(
        'Too many verification attempts',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }
    if (!this.matches(code, entity.codeHash)) {
      entity.attemptCount += 1;
      await this.codesRepository.save(entity);
      throw new BadRequestException('Verification code is invalid');
    }

    await this.usersService.markEmailVerified(user);
    await this.codesRepository.delete({ userId: user.id });
    return user;
  }

  private hash(code: string): string {
    return createHmac('sha256', this.secret).update(code).digest('hex');
  }

  private matches(code: string, expectedHash: string): boolean {
    const actual = Buffer.from(this.hash(code), 'hex');
    const expected = Buffer.from(expectedHash, 'hex');
    return (
      actual.length === expected.length && timingSafeEqual(actual, expected)
    );
  }
}
