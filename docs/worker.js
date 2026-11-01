// Runs the real NanoC compiler (compiled to WebAssembly) off the main thread.
// A fresh instance per request: compile errors trap, so state never leaks between runs.
let mod;
const ready = fetch('nanoc.wasm').then(r => r.arrayBuffer()).then(b => WebAssembly.compile(b)).then(m => (mod = m));
const dec = new TextDecoder();
onmessage = async e => {
  const { id, src } = e.data;
  try {
    await ready;
    const t0 = performance.now();
    const x = (await WebAssembly.instantiate(mod, { env: { nc_host_write() {}, nc_host_trap() { throw new Error('trap'); } } })).exports;
    const bytes = new TextEncoder().encode(src);
    const p = x.malloc(bytes.length + 1);
    new Uint8Array(x.memory.buffer).set(bytes, p);
    let trapped = false;
    try { x.nc_web_transpile(p, bytes.length); } catch { trapped = true; }
    const u = new Uint8Array(x.memory.buffer);
    let q = x.nc_web_error(), end = q;
    while (u[end]) end++;
    const err = dec.decode(u.slice(q, end));
    const out = trapped ? '' : dec.decode(u.slice(x.nc_web_output(), x.nc_web_output() + x.nc_web_output_len()));
    postMessage({ id, ok: !trapped && !err, out, err, trapped, ms: performance.now() - t0 });
  } catch (ex) {
    postMessage({ id, ok: false, out: '', err: String(ex), trapped: true, ms: 0 });
  }
};
