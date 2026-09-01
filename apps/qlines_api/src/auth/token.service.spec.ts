import { TokenService } from './token.service';

describe('TokenService', () => {
  const service = new TokenService('test-secret-that-is-long-enough');

  it('should create and verify a signed token', () => {
    const token = service.create('user-1', 'ali@example.com');
    expect(service.verify(token)).toEqual(
      expect.objectContaining({ sub: 'user-1', email: 'ali@example.com' }),
    );
  });

  it('should reject a modified token', () => {
    const token = service.create('user-1', 'ali@example.com');
    expect(() => service.verify(`${token}changed`)).toThrow('Invalid token');
  });
});
