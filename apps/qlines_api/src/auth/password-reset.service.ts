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
import { PasswordResetCodeEntity } from './entities/password-reset-code.entity';
import { PasswordService } from './password.service';
import { JWT_SECRET } from './token.service';

@Injectable()
export class PasswordResetService {
  static readonly expiresInSeconds = 10 * 60;
  static readonly resendDelaySeconds = 60;

  constructor(
    @InjectRepository(PasswordResetCodeEntity)
    private readonly codesRepository: Repository<PasswordResetCodeEntity>,
    @Inject(JWT_SECRET) private readonly secret: string,
    @Inject(EMAIL_SENDER) private readonly emailSender: EmailSender,
    private readonly usersService: UsersService,
    private readonly passwordService: PasswordService,
  ) {}

  async request(email: string): Promise<void> {
    const user = await this.usersService.findByEmail(email);
    if (!user || !user.isEmailVerified) return;

    const existing = await this.codesRepository.findOne({
      where: { userId: user.id },
    });
    const now = new Date();
    if (
      existing &&
      now.getTime() - existing.lastSentAt.getTime() <
        PasswordResetService.resendDelaySeconds * 1000
    ) {
      return;
    }

    const code = randomInt(0, 1_000_000).toString().padStart(6, '0');
    const entity = existing ?? this.codesRepository.create({ userId: user.id });
    entity.codeHash = this.hash(code);
    entity.expiresAt = new Date(
      now.getTime() + PasswordResetService.expiresInSeconds * 1000,
    );
    entity.attemptCount = 0;
    entity.lastSentAt = now;
    await this.codesRepository.save(entity);
    await this.emailSender.sendPasswordResetCode(user.email, code);
  }

  async reset(email: string, code: string, newPassword: string): Promise<void> {
    const user = await this.usersService.findByEmail(email);
    if (!user)
      throw new BadRequestException('Reset code is invalid or expired');

    const entity = await this.codesRepository.findOne({
      where: { userId: user.id },
    });
    if (!entity || entity.expiresAt.getTime() <= Date.now()) {
      throw new BadRequestException('Reset code is invalid or expired');
    }
    if (entity.attemptCount >= 5) {
      throw new HttpException(
        'Too many reset attempts',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }
    if (!this.matches(code, entity.codeHash)) {
      entity.attemptCount += 1;
      await this.codesRepository.save(entity);
      throw new BadRequestException('Reset code is invalid or expired');
    }

    await this.usersService.updatePassword(
      user,
      this.passwordService.hash(newPassword),
    );
    await this.codesRepository.delete({ userId: user.id });
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
