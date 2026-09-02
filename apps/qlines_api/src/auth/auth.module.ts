import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersModule } from '../users/users.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { PasswordService } from './password.service';
import { JWT_SECRET, TokenService } from './token.service';
import { AuthGuard } from './auth.guard';
import { DevelopmentEmailService } from './development-email.service';
import { EmailVerificationService } from './email-verification.service';
import { EmailVerificationCodeEntity } from './entities/email-verification-code.entity';
import { EMAIL_SENDER } from './email-sender';
import type { EmailSender } from './email-sender';
import { ResendEmailService } from './resend-email.service';
import { PasswordResetCodeEntity } from './entities/password-reset-code.entity';
import { PasswordResetService } from './password-reset.service';

@Module({
  imports: [
    UsersModule,
    TypeOrmModule.forFeature([
      EmailVerificationCodeEntity,
      PasswordResetCodeEntity,
    ]),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    PasswordService,
    TokenService,
    AuthGuard,
    EmailVerificationService,
    PasswordResetService,
    DevelopmentEmailService,
    ResendEmailService,
    {
      provide: EMAIL_SENDER,
      inject: [ConfigService, DevelopmentEmailService, ResendEmailService],
      useFactory: (
        configService: ConfigService,
        developmentEmailService: DevelopmentEmailService,
        resendEmailService: ResendEmailService,
      ): EmailSender =>
        configService.get<string>('EMAIL_PROVIDER', 'development') === 'resend'
          ? resendEmailService
          : developmentEmailService,
    },
    {
      provide: JWT_SECRET,
      inject: [ConfigService],
      useFactory: (configService: ConfigService): string =>
        configService.getOrThrow<string>('JWT_SECRET'),
    },
  ],
  exports: [AuthGuard, TokenService],
})
export class AuthModule {}
