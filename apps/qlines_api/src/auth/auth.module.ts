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

@Module({
  imports: [
    UsersModule,
    TypeOrmModule.forFeature([EmailVerificationCodeEntity]),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    PasswordService,
    TokenService,
    AuthGuard,
    EmailVerificationService,
    DevelopmentEmailService,
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
