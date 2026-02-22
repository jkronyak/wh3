
const WebSocket = require('ws');
const { exec } = require('child_process');

const rpfmServerExecPath = 'C:/Modding/Warhammer3/RPFMv4.7.100/rpfm_server.exe';
const url = "ws://127.0.0.1:45127/ws";

class RPFMClient {
    
    constructor(execPath, sessionId = null, game = 'warhammer_3') { 
        this.execPath = execPath;
        this.sessionId = sessionId;
        this.serverProcess = null;
        this.ws = null;
        this.curRequestId = 1;
        this.pendingResponses = new Map();
        this.game = game;
    }

    _connect() { 
        return new Promise((resolve, reject) => { 
            this.ws = new WebSocket(url);
            this.ws.onopen = () => { 
                console.log(`Connected to RPFM server. Setting game to ${this.game}.`);
                this.send({ SetGameSelected: [this.game, true] });
                resolve();
            }
            this.ws.onclose = () => console.log('Connection closed');

            this.ws.onerror = (err) => { 
                console.log('WS error', err);
                reject(err);
            }

            this.ws.onmessage = event => { 
                const msg = JSON.parse(event.data);
                const cb = this.pendingResponses.get(msg.id);

                // if (!cb) reject(new Error("Callback was not found for id:", msg.id));
                if (!cb) return;
                this.pendingResponses.delete(msg.id);
                if (typeof msg.data === 'object' && "Error" in msg.data) { 
                    cb.reject(new Error(msg.data.Error));
                } else { 
                    cb.resolve(msg.data);
                }
            };

        });
    }

    start() { 
        return new Promise((resolve, reject) => {
            this.serverProcess = exec(this.execPath);
            this.serverProcess.once('spawn', () => setTimeout(() => this._connect().then(resolve).catch(reject), 500));
            this.serverProcess.on('error', reject);
        });
    }

    stop() { 
        if (this.ws) {
            this.ws.send("ClientDisconnecting")
            this.ws.close();
        }
        if (this.serverProcess) this.serverProcess.kill();
    }

    send(cmd) { 
        return new Promise((resolve, reject) => {
            const id = this.curRequestId++;
            this.pendingResponses.set(id, { resolve, reject });
            this.ws.send(JSON.stringify({ id, data: cmd }));
        });
    }

    async loadPackFiles(filePaths) {

    }

    // example = { 
    //     PackFile: [
    //         { Folder: "db/effect_bundles_tables" }, 
    //         { File: "db/effects_tables/jar_adjustable_missiles__accuracy"}
    //     ]
    // }
    /**
     * @param {Array[Object]} filePaths - ex: [{ PackFile: [{ Folder: }]}]
     * Example: 
     * [{ PackFile: [{ Folder: "db/effects_tables"]}]
     */

    /**
     * { path: 'db/table/<optional_file>', type: '' }
     * 
     */
    async extractPackedFiles(filePaths) {
        await this.send({ ExtractPackedFiles: [] })
    }
}

module.exports = { RPFMClient };