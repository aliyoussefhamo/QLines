import { Inject, Injectable, UnauthorizedException } from '@nestjs/common';
import { createHmac, timingSafeEqual } from 'node:crypto';
import { UserRole } from '../users/models/user-role';

export type TokenPayload = {
  sub: string;
  email: string;
  iat: number;
  exp: number;
  role: UserRole;
  employeeBranchId: string | null;
};
export const JWT_SECRET = Symbol('JWT_SECRET');

@Injectable()
export class TokenService {
  static readonly expiresInSeconds = 60 * 60;

  constructor(@Inject(JWT_SECRET) private readonly secret: string) {}

  create(
    userId: string,
    email: string,
    role: UserRole,
    employeeBranchId: string | null,
  ): string {
    const now = Math.floor(Date.now() / 1000);
    const header = this.encode({ alg: 'HS256', typ: 'JWT' });
    const payload = this.encode({
      sub: userId,
      email,
      iat: now,
      exp: now + TokenService.expiresInSeconds,
      role,
      employeeBranchId,
    } satisfies TokenPayload);
    const unsignedToken = `${header}.${payload}`;
    const signature = createHmac('sha256', this.getSecret())
      .update(unsignedToken)
      .digest('base64url');
    return `${unsignedToken}.${signature}`;
  }

  verify(token: string): TokenPayload {
    const parts = token.split('.');
    if (parts.length !== 3) throw new UnauthorizedException('Invalid token');

    const [header, payload, signature] = parts;
    const expectedSignature = createHmac('sha256', this.getSecret())
      .update(`${header}.${payload}`)
      .digest();
    const suppliedSignature = Buffer.from(signature, 'base64url');
    if (
      expectedSignature.length !== suppliedSignature.length ||
      !timingSafeEqual(expectedSignature, suppliedSignature)
    ) {
      throw new UnauthorizedException('Invalid token');
    }

    try {
      const decoded = JSON.parse(
        Buffer.from(payload, 'base64url').toString('utf8'),
      ) as Partial<TokenPayload>;
      const now = Math.floor(Date.now() / 1000);
      if (
        typeof decoded.sub !== 'string' ||
        typeof decoded.email !== 'string' ||
        typeof decoded.iat !== 'number' ||
        typeof decoded.exp !== 'number' ||
        !Object.values(UserRole).includes(decoded.role as UserRole) ||
        (decoded.employeeBranchId !== null &&
          typeof decoded.employeeBranchId !== 'string') ||
        decoded.exp <= now
      ) {
        throw new UnauthorizedException('Token is invalid or expired');
      }
      return decoded as TokenPayload;
    } catch (error) {
      if (error instanceof UnauthorizedException) throw error;
      throw new UnauthorizedException('Invalid token');
    }
  }

  private encode(value: object): string {
    return Buffer.from(JSON.stringify(value)).toString('base64url');
  }

  private getSecret(): string {
    return this.secret;
  }
}
