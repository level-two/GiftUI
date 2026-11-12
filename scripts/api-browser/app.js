"use strict";

const $ = id => document.getElementById(id);
const typeKinds = new Set(["struct", "class", "actor", "enum", "protocol", "typealias"]);
const labels = {struct: "Structures", class: "Classes", actor: "Actors", enum: "Enumerations", protocol: "Protocols", typealias: "Type aliases", extension: "Extensions", func: "Functions", var: "Properties", let: "Constants", macro: "Macros", associatedtype: "Associated types", case: "Cases", init: "Initializers", subscript: "Subscripts"};
const keywords = new Set("public open struct class actor enum protocol extension func var let init subscript typealias associatedtype case static mutating nonmutating borrowing consuming inout throws rethrows async some any where get set willSet didSet nonisolated isolated final override required convenience indirect macro distributed sending each repeat true false nil".split(" "));
let modules = [], current = null, request = 0;

function element(tag, className, text) {
  const el = document.createElement(tag);
  if (className) el.className = className;
  if (text !== undefined) el.textContent = text;
  return el;
}

function signature(text) {
  const pre = element("pre", "signature"), code = element("code");
  // Append text nodes, never interpolate source code or comments into HTML.
  const tokens = text.match(/#*"(?:\\.|[^"\\])*"#*|`[^`]+`|\b[A-Za-z_]\w*\b|[^A-Za-z_`"]+|./g) || [];
  for (const token of tokens) {
    let cls = keywords.has(token) ? "kw" : /^[A-Z]/.test(token) ? "ty" : /^#*"/.test(token) ? "str" : "";
    code.append(cls ? element("span", cls, token) : document.createTextNode(token));
  }
  pre.append(code);
  return pre;
}

async function json(url) {
  const response = await fetch(url, {cache: "no-store"});
  const value = await response.json();
  if (!response.ok) throw new Error(value.error || "Could not load interfaces");
  return value;
}

function navigation() {
  const query = $("module-search").value.toLowerCase();
  const filtered = modules.filter(m => m.name.toLowerCase().includes(query));
  $("modules").replaceChildren(...filtered.map(module => {
    const link = element("a", "module-link");
    link.href = "#" + encodeURIComponent(module.name);
    link.append(element("span", "", module.name), element("span", "count", ($("include-package").checked ? module.packageCount : module.count).toLocaleString()));
    if (current?.name === module.name) link.setAttribute("aria-current", "page");
    return link;
  }));
  if (!filtered.length) $("modules").append(element("p", "muted", "No matching modules"));
  $("module-count").textContent = `${filtered.length} / ${modules.length}`;
}

function matches(symbol, query) {
  return [symbol.name, symbol.signature, symbol.documentation].some(s => s.toLowerCase().includes(query));
}

function filteredSymbol(symbol, query) {
  if (!$("include-package").checked && symbol.access === "package") return null;
  const ownMatch = !query || matches(symbol, query);
  const members = symbol.members.map(s => filteredSymbol(s, ownMatch ? "" : query)).filter(Boolean);
  if (symbol.kind === "extension" && !members.length && !symbol.signature.includes(":")) return null;
  return ownMatch || members.length ? {...symbol, members} : null;
}

function group(symbols) {
  const groups = new Map();
  for (const symbol of symbols) {
    if (!groups.has(symbol.kind)) groups.set(symbol.kind, []);
    groups.get(symbol.kind).push(symbol);
  }
  return [...groups].sort(([a], [b]) => Object.keys(labels).indexOf(a) - Object.keys(labels).indexOf(b));
}

function extras(symbol, container) {
  if (symbol.documentation) container.append(element("div", "documentation", symbol.documentation));
  if (symbol.conditions.length) {
    const conditions = element("div", "conditions");
    conditions.append(element("span", "condition", "#if " + symbol.conditions.join(" && ")));
    container.append(conditions);
  }
}

function members(symbols, autoOpen) {
  const detail = element("details", "members");
  detail.open = autoOpen;
  detail.append(element("summary", "", `${symbols.length} member${symbols.length === 1 ? "" : "s"}`));
  for (const [kind, items] of group(symbols)) {
    const section = element("section", "member-group");
    section.append(element("h4", "", labels[kind] || kind));
    for (const symbol of items) {
      const member = element("div", "member");
      member.append(signature(symbol.signature));
      extras(symbol, member);
      member.append(element("div", "source", `${symbol.file}:${symbol.line}`));
      if (symbol.members.length) member.append(members(symbol.members, autoOpen));
      section.append(member);
    }
    detail.append(section);
  }
  return detail;
}

function card(symbol, searching) {
  const article = element("article", "symbol"), header = element("header", "symbol-header");
  const title = element("h3", "symbol-name");
  title.append(element("span", "kind", symbol.kind + " "), document.createTextNode(symbol.name));
  header.append(title, element("span", "source", `${symbol.access} · ${symbol.file.split("/").at(-1)}:${symbol.line}`));
  article.append(header, signature(symbol.signature));
  extras(symbol, article);
  if (symbol.members.length) article.append(members(symbol.members, searching || symbol.members.length <= 8));
  return article;
}

function render() {
  if (!current) return;
  $("module-meta").textContent = `${current.files} Swift source file${current.files === 1 ? "" : "s"} · ${$("include-package").checked ? "public & package" : "public"} source interface`;
  const query = $("symbol-search").value.trim().toLowerCase(), kind = $("kind-filter").value;
  const symbols = current.symbols.map(s => filteredSymbol(s, query)).filter(Boolean)
    .filter(s => !kind || (kind === "type" ? typeKinds.has(s.kind) : s.kind === kind));
  const content = $("interfaces");
  content.replaceChildren();
  for (const [kind, items] of group(symbols)) {
    const heading = element("h2", "section-heading", labels[kind] || kind);
    heading.append(element("span", "", items.length));
    content.append(heading, ...items.map(s => card(s, Boolean(query))));
  }
  $("status").className = "";
  $("status").textContent = `${symbols.length} top-level declaration${symbols.length === 1 ? "" : "s"}${query ? " matching your search" : " · select a member group to expand"}`;
  if (current.warnings.length) $("status").textContent += " · " + current.warnings.join(" ");
  if (!symbols.length) content.append(element("div", "empty", "No matching declarations. Try another search or enable ‘Include package API’ to inspect cross-module package declarations."));
}

function selectedModule() {
  try { return location.hash === "#content" ? (current?.name || "GiftUI") : decodeURIComponent(location.hash.slice(1)) || "GiftUI"; }
  catch { return "GiftUI"; }
}

async function selectModule() {
  const id = ++request;
  $("status").textContent = "Reading interface…";
  try {
    const module = await json("/api/modules/" + encodeURIComponent(selectedModule()));
    if (id !== request) return;
    current = module;
    document.title = `${module.name} · GiftUI Interfaces`;
    $("module-title").textContent = module.name;
    $("module-meta").textContent = `${module.files} Swift source file${module.files === 1 ? "" : "s"} · public source interface`;
    $("dependencies").replaceChildren();
    if (module.imports.length) {
      $("dependencies").append(element("span", "dependency-label", "IMPORTS"));
      for (const imported of module.imports) {
        const local = modules.some(m => m.name === imported);
        const item = element(local ? "a" : "span", "dependency", imported);
        if (local) item.href = "#" + encodeURIComponent(imported);
        $("dependencies").append(item);
      }
    }
    navigation();
    render();
  } catch (error) {
    if (id !== request) return;
    current = null;
    $("module-title").textContent = selectedModule();
    $("module-meta").textContent = "Interface unavailable";
    $("interfaces").replaceChildren();
    $("dependencies").replaceChildren();
    $("status").className = "error";
    $("status").textContent = error.message;
    navigation();
  }
}

async function refresh() {
  $("refresh").disabled = true;
  try {
    modules = await json("/api/modules");
    navigation();
    await selectModule();
  } catch (error) {
    $("status").className = "error";
    $("status").textContent = error.message;
  } finally { $("refresh").disabled = false; }
}

$("module-search").addEventListener("input", navigation);
$("symbol-search").addEventListener("input", render);
$("kind-filter").addEventListener("change", render);
$("include-package").addEventListener("change", () => { navigation(); render(); });
$("refresh").addEventListener("click", refresh);
window.addEventListener("hashchange", selectModule);
refresh();
