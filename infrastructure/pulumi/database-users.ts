import * as pulumi from "@pulumi/pulumi";
import * as random from "@pulumi/random";
import * as command from "@pulumi/command";

interface DatabaseUserConfig {
  serverFqdn: pulumi.Output<string>;
  adminUsername: pulumi.Output<string>;
  adminPassword: pulumi.Output<string>;
  databaseName: string;
  userName: string;
}

export function createDatabaseUser(
  name: string,
  config: DatabaseUserConfig,
): {
  username: string;
  password: pulumi.Output<string>;
} {
  // Generate a secure random password for the user
  const userPassword = new random.RandomPassword(`${name}-password`, {
    length: 32,
    special: true,
    overrideSpecial: "!#$%&*()-_=+[]{}<>:?",
  });

  // Create the database user using a remote command
  // This runs on the K3s VM which has network access to the PostgreSQL server
  const createUser = new command.remote.Command(
    `${name}-create-user`,
    {
      connection: {
        host: pulumi.output("10.10.1.4"), // K3s VM private IP
        user: "azureuser",
        privateKey: pulumi.output(
          process.env.SSH_PRIVATE_KEY || "~/.ssh/id_rsa",
        ),
      },
      create: pulumi.interpolate`
        # Create user if not exists
        PGPASSWORD='${config.adminPassword}' PGSSLMODE=require psql \
          -h ${config.serverFqdn} \
          -U ${config.adminUsername} \
          -d postgres \
          -c "DO \\$\\$ BEGIN \
                IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '${config.userName}') THEN \
                  CREATE USER ${config.userName} WITH PASSWORD '${userPassword.result}'; \
                END IF; \
              END \\$\\$;" || true
        
        # Update password (in case user already exists)
        PGPASSWORD='${config.adminPassword}' PGSSLMODE=require psql \
          -h ${config.serverFqdn} \
          -U ${config.adminUsername} \
          -d postgres \
          -c "ALTER USER ${config.userName} WITH PASSWORD '${userPassword.result}';"
        
        # Grant database privileges
        PGPASSWORD='${config.adminPassword}' PGSSLMODE=require psql \
          -h ${config.serverFqdn} \
          -U ${config.adminUsername} \
          -d ${config.databaseName} \
          -c "GRANT ALL PRIVILEGES ON DATABASE ${config.databaseName} TO ${config.userName};"
        
        # Grant schema privileges
        PGPASSWORD='${config.adminPassword}' PGSSLMODE=require psql \
          -h ${config.serverFqdn} \
          -U ${config.adminUsername} \
          -d ${config.databaseName} \
          -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${config.userName};"
        
        PGPASSWORD='${config.adminPassword}' PGSSLMODE=require psql \
          -h ${config.serverFqdn} \
          -U ${config.adminUsername} \
          -d ${config.databaseName} \
          -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${config.userName};"
        
        # Grant default privileges for future objects
        PGPASSWORD='${config.adminPassword}' PGSSLMODE=require psql \
          -h ${config.serverFqdn} \
          -U ${config.adminUsername} \
          -d ${config.databaseName} \
          -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${config.userName};"
        
        PGPASSWORD='${config.adminPassword}' PGSSLMODE=require psql \
          -h ${config.serverFqdn} \
          -U ${config.adminUsername} \
          -d ${config.databaseName} \
          -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${config.userName};"
      `,
    },
    {
      dependsOn: [], // Will be set when calling this function
    },
  );

  return {
    username: config.userName,
    password: userPassword.result,
  };
}

