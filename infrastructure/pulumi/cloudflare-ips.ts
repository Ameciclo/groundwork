// Cloudflare's published IPv4 ranges (https://www.cloudflare.com/ips-v4).
// Azure Postgres firewall rules are IPv4 only. Cloudflare changes this list
// rarely; to refresh it, replace the array with the current output of
//   curl https://www.cloudflare.com/ips-v4
export const cloudflareIpv4Cidrs = [
  "173.245.48.0/20",
  "103.21.244.0/22",
  "103.22.200.0/22",
  "103.31.4.0/22",
  "141.101.64.0/18",
  "108.162.192.0/18",
  "190.93.240.0/20",
  "188.114.96.0/20",
  "197.234.240.0/22",
  "198.41.128.0/17",
  "162.158.0.0/15",
  "104.16.0.0/13",
  "104.24.0.0/14",
  "172.64.0.0/13",
  "131.0.72.0/22",
];

const toInt = (ip: string) =>
  ip.split(".").reduce((n, octet) => n * 256 + Number(octet), 0);
const toIp = (n: number) =>
  [24, 16, 8, 0].map((shift) => Math.floor(n / 2 ** shift) % 256).join(".");

// "104.16.0.0/13" -> first and last address of the block
export function cidrToRange(cidr: string): { start: string; end: string } {
  const [ip, bits] = cidr.split("/");
  const size = 2 ** (32 - Number(bits));
  const start = Math.floor(toInt(ip) / size) * size;
  return { start: toIp(start), end: toIp(start + size - 1) };
}
