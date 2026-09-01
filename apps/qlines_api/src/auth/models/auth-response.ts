import { User } from '../../users/models/user';

export type AuthResponse = {
  accessToken: string;
  tokenType: 'Bearer';
  expiresInSeconds: number;
  user: User;
};
