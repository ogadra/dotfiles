import { writeFile } from "node:fs/promises";

const response = await fetch("https://static.devin.ai/cli/current/manifest.json");
if (!response.ok) {
  throw new Error(`manifest.json returned HTTP ${response.status}`);
}
const manifest = await response.json();
await writeFile(new URL("./manifest.json", import.meta.url), `${JSON.stringify(manifest, null, 2)}\n`);
