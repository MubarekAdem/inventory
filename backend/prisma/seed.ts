import { PrismaClient, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  // Check if super admin already exists
  const existingSuperAdmin = await prisma.user.findFirst({
    where: { role: UserRole.SUPER_ADMIN },
  });

  if (existingSuperAdmin) {
    console.log('Super admin already exists');
    return;
  }

  // Create super admin user
  const hashedPassword = await bcrypt.hash('admin123', 10);

  const superAdmin = await prisma.user.create({
    data: {
      username: 'superadmin',
      password: hashedPassword,
      role: UserRole.SUPER_ADMIN,
      isActive: true,
    },
  });

  console.log('Super admin created:', {
    id: superAdmin.id,
    username: superAdmin.username,
    role: superAdmin.role,
  });

  console.log('Seeding completed!');
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
