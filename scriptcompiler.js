import fs from "fs";
import path from "path";

function luaString(s) {
    if (s === null || s === undefined) return '""';
    return JSON.stringify(String(s));
}

function compileScripts({ inputJson, outputLua }) {
    if (!inputJson || !fs.existsSync(inputJson)) {
        throw new Error(`inputJson not found: ${inputJson}`);
    }

    const raw = fs.readFileSync(inputJson, "utf8");
    let entries;
    try {
        entries = JSON.parse(raw);
    } catch (err) {
        throw new Error(`Failed to parse JSON ${inputJson}: ${err.message}`);
    }

    if (!Array.isArray(entries)) {
        throw new Error(`Expected JSON array in ${inputJson}`);
    }

    const numberedEntries = entries.map((entry, index) => ({
        id: index + 1,
        section: entry.section || "intro",
        name: entry.name || "",
        description: entry.description || "",
        url: entry.url || ""
    }));

    const luaTable = numberedEntries.map(item => {
        return `{id=${item.id}, section=${luaString(item.section)}, name=${luaString(item.name)}, description=${luaString(item.description)}, url=${luaString(item.url)}}`;
    }).join(",\n");

    let existingContent = "";
    if (fs.existsSync(outputLua)) {
        existingContent = fs.readFileSync(outputLua, "utf8");
    }

    const flagPattern = /local COMPILE_SCRIPTS_OUTPUT\s*=\s*true/;
    if (!flagPattern.test(existingContent)) {
        throw new Error(`Flag "COMPILE_SCRIPTS_OUTPUT" not found in ${outputLua}`);
    }

    // Regex to remove any previous scripts table wrapped in comments
    const scriptsPattern = /(local COMPILE_SCRIPTS_OUTPUT\s*=\s*true\s*\n)(-- START SCRIPTS TABLE[\s\S]*?-- END SCRIPTS TABLE\n*)?/;

    // Replace or insert the table wrapped in comment markers, using global 'scripts'
    existingContent = existingContent.replace(
        scriptsPattern,
        `$1-- START SCRIPTS TABLE\nscripts = {\n${luaTable}\n}\n-- END SCRIPTS TABLE\n`
    );

    fs.mkdirSync(path.dirname(outputLua), { recursive: true });
    fs.writeFileSync(outputLua, existingContent, "utf8");
    console.log(`Compiled ${entries.length} scripts -> ${outputLua}`);
}

export default compileScripts;
