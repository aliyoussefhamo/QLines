import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { UsersModule } from '../users/users.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { PasswordService } from './password.service';
import { JWT_SECRET, TokenService } from './token.service';
import { AuthGuard } from './auth.guard';

@Module({
  imports: [UsersModule],
  controllers: [AuthController],
  providers: [
    AuthService,
    PasswordService,
    TokenService,
    AuthGuard,
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
