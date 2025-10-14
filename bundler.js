import fs from "fs";
import path from "path";
import { z } from "zod";
import { LuaCompiler } from "./luacompiler.js";
import compileScripts from "./scriptcompiler.js";

const CONFIG_FILE = path.resolve("./bundle.json");

if (!fs.existsSync(CONFIG_FILE)) {
    console.error("❌ bundle.json not found:", CONFIG_FILE);
    process.exit(1);
}

const configSchema = z.object({
    main: z.string().optional(),
    output: z.string().optional(),
    include: z.array(z.string()).optional(),
    scripts: z.object({
        input: z.string().optional(),
        output: z.string().optional()
    }).optional(),
    modules: z.array(z.string()).optional()
});

const config = configSchema.parse(JSON.parse(fs.readFileSync(CONFIG_FILE, "utf8")));

const ENTRY_FILE = config.main ? path.resolve(config.main) : null;
const OUTPUT_FILE = config.output ? path.resolve(config.output) : null;
const INCLUDE_DIRS = (config.include || []).map(d => path.resolve(d));
const SCRIPTS_INPUT = config.scripts?.input ? path.resolve(config.scripts.input) : null;
const SCRIPTS_OUTPUT = config.scripts?.output ? path.resolve(config.scripts.output) : null;

if (!ENTRY_FILE || !OUTPUT_FILE) {
    console.error("❌ main or output not configured in bundle.json");
    process.exit(1);
}

if (SCRIPTS_INPUT && SCRIPTS_OUTPUT) {
    console.log(`📄 Compiling user scripts into sections: ${SCRIPTS_OUTPUT}`);
    compileScripts({
        inputJson: SCRIPTS_INPUT,
        outputLua: SCRIPTS_OUTPUT,
        includeDirs: INCLUDE_DIRS
    });
    console.log(`✅ Sections compiled to ${SCRIPTS_OUTPUT}`);
} else {
    console.warn("⚠️ Scripts input/output not configured, skipping sections compilation.");
}

const compiler = new LuaCompiler(INCLUDE_DIRS);

console.log(`📦 Compiling main Lua entry: ${ENTRY_FILE}`);

let mainBundle;
try {
    mainBundle = compiler.compile(ENTRY_FILE);
} catch (err) {
    console.error("❌ Error compiling main entry:", err);
    process.exit(1);
}

fs.mkdirSync(path.dirname(OUTPUT_FILE), { recursive: true });
fs.writeFileSync(OUTPUT_FILE, mainBundle, "utf8");

console.log(`✅ Lua bundle written to ${OUTPUT_FILE}`);
