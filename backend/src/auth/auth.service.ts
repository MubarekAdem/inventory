import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { CreateUserDto } from './dto/create-user.dto';
import * as bcrypt from 'bcrypt';
import { UserRole } from '@prisma/client';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async validateUser(username: string, password: string): Promise<any> {
    const user = await this.prisma.user.findUnique({
      where: { username, isActive: true },
    });

    if (user && (await bcrypt.compare(password, user.password))) {
      const { password, ...result } = user;
      return result;
    }
    return null;
  }

  async login(loginDto: LoginDto) {
    const user = await this.validateUser(loginDto.username, loginDto.password);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = { username: user.username, sub: user.id, role: user.role };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        username: user.username,
        role: user.role,
      },
    };
  }

  async createUser(createUserDto: CreateUserDto, creatorRole: UserRole) {
    // Only super admin can create other admins
    if (createUserDto.role === UserRole.SUPER_ADMIN) {
      throw new UnauthorizedException('Cannot create super admin');
    }

    if (
      createUserDto.role === UserRole.ADMIN &&
      creatorRole !== UserRole.SUPER_ADMIN
    ) {
      throw new UnauthorizedException(
        'Only super admin can create admin users',
      );
    }

    const hashedPassword = await bcrypt.hash(createUserDto.password, 10);

    const { password, ...userData } = createUserDto;

    const user = await this.prisma.user.create({
      data: {
        ...userData,
        password: hashedPassword,
        role: createUserDto.role || UserRole.USER,
      },
    });

    const { password: _, ...result } = user;
    return result;
  }

  async getUsers() {
    const users = await this.prisma.user.findMany({
      select: {
        id: true,
        username: true,
        role: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });
    return users;
  }

  async updateUserStatus(userId: string, isActive: boolean) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: { isActive },
      select: {
        id: true,
        username: true,
        role: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });
    return user;
  }
}
