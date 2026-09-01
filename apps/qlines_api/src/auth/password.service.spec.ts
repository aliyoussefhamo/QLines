import { PasswordService } from './password.service';

describe('PasswordService', () => {
  const service = new PasswordService();

  it('should hash and verify a password', () => {
    const hash = service.hash('strong-password');
    expect(hash).not.toContain('strong-password');
    expect(service.verify('strong-password', hash)).toBe(true);
    expect(service.verify('wrong-password', hash)).toBe(false);
  });
});
