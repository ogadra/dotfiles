import { writeFile } from "node:fs/promises";

interface Platform {
  url: string;
  sha256: string;
}

interface Manifest {
  version: string;
  platforms: Record<string, Platform>;
}

const targets: Record<string, string> = {
  "x86_64-linux": "x86_64-unknown-linux",
  "aarch64-darwin": "aarch64-apple-darwin",
};

const response = await fetch("https://static.devin.ai/cli/current/manifest.json");
if (!response.ok) {
  throw new Error(`manifest.json returned HTTP ${response.status}`);
}
const upstream: Manifest = await response.json();

const platforms: Record<string, Platform> = {};
for (const [system, target] of Object.entries(targets)) {
  const platform = upstream.platforms[target];
  if (platform === undefined) {
    throw new Error(`manifest.json has no ${target}`);
  }
  platforms[system] = { url: platform.url, sha256: platform.sha256 };
}

const manifest: Manifest = { version: upstream.version, platforms };
await writeFile(new URL("./manifest.json", import.meta.url), `${JSON.stringify(manifest, null, 2)}\n`);
