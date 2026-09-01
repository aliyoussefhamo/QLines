import {
  ConflictException,
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

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly passwordService: PasswordService,
    private readonly tokenService: TokenService,
  ) {}

  async register(dto: RegisterDto): Promise<AuthResponse> {
    if (await this.usersService.findByEmail(dto.email)) {
      throw new ConflictException('Email is already registered');
    }
    try {
      const user = await this.usersService.create(
        dto.fullName,
        dto.email,
        this.passwordService.hash(dto.password),
      );
      return this.createResponse(user.id, user.fullName, user.email);
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
    return this.createResponse(user.id, user.fullName, user.email);
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
