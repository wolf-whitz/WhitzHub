import fs from "fs";
import path from "path";

export class LuaCompiler {
  constructor(includeDirs = []) {
    if (!Array.isArray(includeDirs))
      throw new Error("includeDirs must be an array of strings");
    this.includeDirs = includeDirs.map((d) => path.resolve(d));
    this.visited = new Set();
    this.modules = [];
    this.moduleCounter = 0;
    this.moduleMap = new Map();
  }

  resolveImportPath(name, fromFile) {
    const tryPaths = [];
    if (name.startsWith("./") || name.startsWith("../")) {
      tryPaths.push(path.resolve(path.dirname(fromFile), name + ".lua"));
      tryPaths.push(path.resolve(path.dirname(fromFile), name, "init.lua"));
    }
    for (const dir of this.includeDirs) {
      tryPaths.push(path.resolve(dir, name + ".lua"));
      tryPaths.push(path.resolve(dir, name, "init.lua"));
    }
    for (const p of tryPaths) {
      if (fs.existsSync(p)) return p;
    }
    return null;
  }

  minifyLua(code) {
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

  readModule(filePath, options = {}) {
    filePath = path.resolve(filePath);
    if (this.visited.has(filePath)) return this.moduleMap.get(filePath);
    this.visited.add(filePath);

    let code = fs.readFileSync(filePath, "utf8");

    const imports = [];
    const importRegex = /(?:import|require)\s*\(\s*["'](.+?)["']\s*\)/g;
    code = code.replace(importRegex, (_, importPath) => {
      const resolved = this.resolveImportPath(importPath, filePath);
      if (!resolved) return "{}";
      const modVar = this.readModule(resolved, options);
      imports.push(modVar);
      return modVar;
    });

    let moduleTable = null;
    const tableMatch = code.match(/local\s+(\w+)\s*=\s*{\s*}/);
    if (tableMatch) moduleTable = tableMatch[1];
    else {
      moduleTable = `__table${this.moduleCounter}`;
      code = `local ${moduleTable} = {} ${code}`;
    }

    const lines = code.trimEnd().split("\n");
    const lastLine = lines[lines.length - 1].trim();
    if (!/^return\s+\w+/.test(lastLine)) code += ` return ${moduleTable}`;

    const moduleVar = `__mod${this.moduleCounter++}`;
    this.moduleMap.set(filePath, moduleVar);

    const minifiedCode = this.minifyLua(code);

    const wrappedCode = `local ${moduleVar} = (function() ${minifiedCode} end)()`;
    this.modules.push(wrappedCode);

    return moduleVar;
  }

  compile(entryFile, options = {}) {
    if (typeof entryFile !== "string")
      throw new Error("entryFile must be a string");

    this.visited.clear();
    this.modules = [];
    this.moduleCounter = 0;
    this.moduleMap.clear();

    const entryVar = this.readModule(entryFile, options);

    return this.modules.join(" ") + ` return ${entryVar}`;
  }
}
