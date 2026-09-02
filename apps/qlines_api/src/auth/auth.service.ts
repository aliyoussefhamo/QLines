import {
  ConflictException,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { QueryFailedError } from 'typeorm';
import { UsersService } from '../users/users.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { AuthResponse } from './models/auth-response';
import { PasswordService } from './password.service';
import { TokenService } from './token.service';
import { EmailVerificationService } from './email-verification.service';
import { RegistrationResponse } from './models/registration-response';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly passwordService: PasswordService,
    private readonly tokenService: TokenService,
    private readonly emailVerificationService: EmailVerificationService,
  ) {}

  async register(dto: RegisterDto): Promise<RegistrationResponse> {
    if (await this.usersService.findByEmail(dto.email)) {
      throw new ConflictException('Email is already registered');
    }
    try {
      const user = await this.usersService.create(
        dto.fullName,
        dto.email,
        this.passwordService.hash(dto.password),
      );
      await this.emailVerificationService.issue(user.id, user.email);
      return {
        requiresEmailVerification: true,
        email: user.email,
        expiresInSeconds: EmailVerificationService.expiresInSeconds,
      };
    } catch (error) {
      if (error instanceof QueryFailedError) {
        throw new ConflictException('Email is already registered');
      }
      throw error;
    }
  }

  async login(dto: LoginDto): Promise<AuthResponse> {
    const user = await this.usersService.findByEmail(dto.email);
    if (
      !user ||
      !this.passwordService.verify(dto.password, user.passwordHash)
    ) {
      throw new UnauthorizedException('Invalid email or password');
    }
    if (!user.isEmailVerified) {
      throw new ForbiddenException('Email verification is required');
    }
    return this.createResponse(user.id, user.fullName, user.email);
  }

  async verifyEmail(email: string, code: string): Promise<AuthResponse> {
    const user = await this.emailVerificationService.verify(email, code);
    return this.createResponse(user.id, user.fullName, user.email);
  }

  async resendVerification(email: string): Promise<{ sent: true }> {
    const user = await this.usersService.findByEmail(email);
    if (user && !user.isEmailVerified) {
      await this.emailVerificationService.issue(user.id, user.email, true);
    }
    return { sent: true };
  }

  private createResponse(
    id: string,
    fullName: string,
    email: string,
  ): AuthResponse {
    return {
      accessToken: this.tokenService.create(id, email),
      tokenType: 'Bearer',
      expiresInSeconds: TokenService.expiresInSeconds,
      user: { id, fullName, email },
    };
  }
}
