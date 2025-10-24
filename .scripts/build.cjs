const fs = require("fs");
const path = require("path");

// Source and output directories
const srcDir = path.join(__dirname, "src");
const outDir = path.join(__dirname, "build");
const outFile = path.join(outDir, "bundle.min.lua");

// Ensure output directory exists
if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

// Minify Lua code
function minifyLua(code) {
  // Remove multiline comments --[[ ]]
  code = code.replace(/--\[\[[\s\S]*?\]\]/g, "");
  // Remove single-line comments
  code = code.replace(/--.*$/gm, "");
  // Trim each line
  code = code.split("\n").map(l => l.trim()).join(" ");
  // Collapse multiple spaces into one
  code = code.replace(/\s+/g, " ");
  return code;
}

// Resolve relative or include paths
function resolveImportPath(name, fromFile, includeDirs) {
  const tryPaths = [];
  if (name.startsWith("./") || name.startsWith("../")) {
    tryPaths.push(path.resolve(path.dirname(fromFile), name + ".lua"));
    tryPaths.push(path.resolve(path.dirname(fromFile), name, "init.lua"));
  }
  for (const dir of includeDirs) {
    tryPaths.push(path.resolve(dir, name + ".lua"));
    tryPaths.push(path.resolve(dir, name, "init.lua"));
  }
  for (const p of tryPaths) {
    if (fs.existsSync(p)) return p;
  }
  return null;
}

// Keep track of visited modules
const visited = new Set();
const modules = [];
let moduleCounter = 0;
const moduleMap = new Map();

function readModule(filePath, includeDirs) {
  filePath = path.resolve(filePath);
  if (visited.has(filePath)) return moduleMap.get(filePath);
  visited.add(filePath);

  let code = fs.readFileSync(filePath, "utf8");

  // Replace require/import calls
  const importRegex = /(?:require|import)\s*\(\s*["'](.+?)["']\s*\)/g;
  code = code.replace(importRegex, (_, importPath) => {
    const resolved = resolveImportPath(importPath, filePath, includeDirs);
    if (!resolved) return "{}";
    return readModule(resolved, includeDirs);
  });

  const moduleVar = `__mod${moduleCounter++}`;
  moduleMap.set(filePath, moduleVar);

  const minified = minifyLua(code);
  modules.push(`local ${moduleVar} = (function() ${minified} end)()`);

  return moduleVar;
}

// Get all Lua files from src
const luaFiles = fs.readdirSync(srcDir)
  .filter(f => f.endsWith(".lua"))
  .map(f => path.join(srcDir, f));

if (luaFiles.length === 0) {
  console.error("No Lua files found in src folder!");
  process.exit(1);
}

// Process all files
luaFiles.forEach(f => readModule(f, [srcDir]));

// Generate final bundle
const bundleCode = modules.join(" ");
fs.writeFileSync(outFile, bundleCode, "utf8");

console.log(`✅ Bundled ${luaFiles.length} files into: ${outFile}`);
