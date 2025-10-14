import fs from "fs";
import path from "path";
import { z } from "zod";
import chokidar from "chokidar";
import { LuaCompiler } from "./luacompiler.js";
import compileScripts from "./scriptcompiler.js";

const CONFIG_FILE = path.resolve("./bundle.json");

const FLAGS = {
    watch: process.argv.includes("--watch"),
    verbose: process.argv.includes("--verbose"),
    once: process.argv.includes("--once")
};

function log(...args) { console.log(...args); }
function info(...args) { console.log("ℹ️", ...args); }
function success(...args) { console.log("✅", ...args); }
function warn(...args) { console.warn("⚠️", ...args); }
function error(...args) { console.error("❌", ...args); }

if (!fs.existsSync(CONFIG_FILE)) {
    error("bundle.json not found:", CONFIG_FILE);
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
    error("main or output not configured in bundle.json");
    process.exit(1);
}

function buildAll() {
    try {
        log(`📦 Building at ${new Date().toLocaleTimeString()}...`);
        if (SCRIPTS_INPUT && SCRIPTS_OUTPUT) {
            log(`📄 Compiling user scripts into: ${SCRIPTS_OUTPUT}`);
            compileScripts({
                inputJson: SCRIPTS_INPUT,
                outputLua: SCRIPTS_OUTPUT,
                includeDirs: INCLUDE_DIRS
            });
            success(`Sections compiled to ${SCRIPTS_OUTPUT}`);
        } else {
            warn("Scripts input/output not configured, skipping sections compilation.");
        }
        const compiler = new LuaCompiler(INCLUDE_DIRS);
        log(`📦 Compiling main Lua entry: ${ENTRY_FILE}`);
        const mainBundle = compiler.compile(ENTRY_FILE);
        fs.mkdirSync(path.dirname(OUTPUT_FILE), { recursive: true });
        fs.writeFileSync(OUTPUT_FILE, mainBundle, "utf8");
        success(`Lua bundle written to ${OUTPUT_FILE}`);
    } catch (err) {
        error("Error during build:", err);
    }
}

buildAll();

if (FLAGS.watch) {
    info("👀 Watch mode enabled. Monitoring for changes...");
    const watchPaths = [
        ENTRY_FILE,
        ...(INCLUDE_DIRS || []),
        ...(SCRIPTS_INPUT ? [SCRIPTS_INPUT] : [])
    ];
    const watcher = chokidar.watch(watchPaths, {
        ignored: /node_modules/,
        ignoreInitial: true,
        persistent: true
    });
    let isBuilding = false;
    let rebuildQueued = false;
    async function queueBuild() {
        if (isBuilding) {
            rebuildQueued = true;
            return;
        }
        isBuilding = true;
        buildAll();
        isBuilding = false;
        if (rebuildQueued) {
            rebuildQueued = false;
            await queueBuild();
        }
    }
    watcher.on("all", (event, filePath) => {
        const rel = path.relative(process.cwd(), filePath);
        if (FLAGS.verbose) info(`🔁 ${event.toUpperCase()} -> ${rel}`);
        queueBuild();
    });
    watcher.on("error", err => {
        error("Watcher error:", err);
    });
} else {
    log("🏁 Build complete. (use --watch to enable hot reloading)");
}
