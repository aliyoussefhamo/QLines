import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHmac } from 'node:crypto';

type TokenPayload = { sub: string; email: string; iat: number; exp: number };

@Injectable()
export class TokenService {
  static readonly expiresInSeconds = 60 * 60;

  constructor(private readonly configService: ConfigService) {}

  create(userId: string, email: string): string {
    const now = Math.floor(Date.now() / 1000);
    const header = this.encode({ alg: 'HS256', typ: 'JWT' });
    const payload = this.encode({
      sub: userId,
      email,
      iat: now,
      exp: now + TokenService.expiresInSeconds,
    } satisfies TokenPayload);
    const unsignedToken = `${header}.${payload}`;
    const signature = createHmac('sha256', this.getSecret())
      .update(unsignedToken)
      .digest('base64url');
    return `${unsignedToken}.${signature}`;
  }

  private encode(value: object): string {
    return Buffer.from(JSON.stringify(value)).toString('base64url');
  }

  private getSecret(): string {
    return this.configService.getOrThrow<string>('JWT_SECRET');
  }
}
