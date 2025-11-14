import * as pulumi from "@pulumi/pulumi";
import * as postgresql from "@pulumi/postgresql";
import * as random from "@pulumi/random";

interface DatabaseUserConfig {
  serverFqdn: pulumi.Output<string>;
  adminUsername: pulumi.Output<string>;
  adminPassword: pulumi.Output<string>;
  databaseName: string;
  userName: string;
  databases: any[]; // Dependencies on database resources
}

export function createDatabaseUser(
  name: string,
  config: DatabaseUserConfig,
): {
  username: string;
  password: pulumi.Output<string>;
  role: postgresql.Role;
} {
  // Create PostgreSQL provider for this connection
  const provider = new postgresql.Provider(
    `${name}-provider`,
    {
      host: config.serverFqdn,
      port: 5432,
      username: config.adminUsername,
      password: config.adminPassword,
      sslmode: "require",
      superuser: false,
      expectedVersion: "16",
    },
    {
      dependsOn: config.databases,
    },
  );

  // Generate a secure random password
  const userPassword = new random.RandomPassword(`${name}-password`, {
    length: 32,
    special: true,
    overrideSpecial: "!#$%&*()-_=+[]{}<>:?",
  });

  // Create the database role/user
  const role = new postgresql.Role(
    `${name}-role`,
    {
      name: config.userName,
      login: true,
      password: userPassword.result,
      skipDropRole: true, // Don't drop role on destroy (safety)
      skipReassignOwned: true,
    },
    { provider },
  );

  // Grant ALL privileges on the database
  const dbGrant = new postgresql.Grant(
    `${name}-db-grant`,
    {
      database: config.databaseName,
      role: role.name,
      objectType: "database",
      privileges: ["ALL"],
    },
    { provider, dependsOn: [role] },
  );

  // Grant ALL privileges on all tables in public schema
  const tableGrant = new postgresql.Grant(
    `${name}-table-grant`,
    {
      database: config.databaseName,
      role: role.name,
      schema: "public",
      objectType: "table",
      privileges: ["ALL"],
    },
    { provider, dependsOn: [role] },
  );

  // Grant ALL privileges on all sequences in public schema
  const sequenceGrant = new postgresql.Grant(
    `${name}-sequence-grant`,
    {
      database: config.databaseName,
      role: role.name,
      schema: "public",
      objectType: "sequence",
      privileges: ["ALL"],
    },
    { provider, dependsOn: [role] },
  );

  // Grant default privileges for future tables
  const defaultTableGrant = new postgresql.DefaultPrivileges(
    `${name}-default-table-grant`,
    {
      database: config.databaseName,
      role: role.name,
      schema: "public",
      owner: config.adminUsername,
      objectType: "table",
      privileges: ["ALL"],
    },
    { provider, dependsOn: [role] },
  );

  // Grant default privileges for future sequences
  const defaultSequenceGrant = new postgresql.DefaultPrivileges(
    `${name}-default-sequence-grant`,
    {
      database: config.databaseName,
      role: role.name,
      schema: "public",
      owner: config.adminUsername,
      objectType: "sequence",
      privileges: ["ALL"],
    },
    { provider, dependsOn: [role] },
  );

  return {
    username: config.userName,
    password: userPassword.result,
    role: role,
  };
}

