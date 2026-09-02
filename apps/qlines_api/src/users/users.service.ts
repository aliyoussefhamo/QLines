import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserEntity } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly usersRepository: Repository<UserEntity>,
  ) {}

  findByEmail(email: string): Promise<UserEntity | null> {
    return this.usersRepository.findOne({
      where: { email: this.normalizeEmail(email), isActive: true },
    });
  }

  findById(id: string): Promise<UserEntity | null> {
    return this.usersRepository.findOne({ where: { id, isActive: true } });
  }

  create(
    fullName: string,
    email: string,
    passwordHash: string,
  ): Promise<UserEntity> {
    return this.usersRepository.save(
      this.usersRepository.create({
        fullName: fullName.trim(),
        email: this.normalizeEmail(email),
        passwordHash,
        isActive: true,
        isEmailVerified: false,
      }),
    );
  }

  markEmailVerified(user: UserEntity): Promise<UserEntity> {
    user.isEmailVerified = true;
    return this.usersRepository.save(user);
  }

  updatePassword(user: UserEntity, passwordHash: string): Promise<UserEntity> {
    user.passwordHash = passwordHash;
    return this.usersRepository.save(user);
  }

  updateFullName(user: UserEntity, fullName: string): Promise<UserEntity> {
    user.fullName = fullName.trim();
    return this.usersRepository.save(user);
  }

  private normalizeEmail(email: string): string {
    return email.trim().toLowerCase();
  }
}
