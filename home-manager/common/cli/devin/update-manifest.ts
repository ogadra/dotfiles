import { writeFile } from "node:fs/promises";

interface Platform {
  url: string;
  sha256: string;
}

interface Manifest {
  version: string;
  platforms: Record<string, Platform>;
}

const response = await fetch("https://static.devin.ai/cli/current/manifest.json");
if (!response.ok) {
  throw new Error(`manifest.json returned HTTP ${response.status}`);
}
const manifest: Manifest = await response.json();
await writeFile(new URL("./manifest.json", import.meta.url), `${JSON.stringify(manifest, null, 2)}\n`);
