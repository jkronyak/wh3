
import WebSocket from 'ws';
import { exec, type ChildProcess } from 'child_process';
import type { Message, Response, Command, ContainerInfo, RFileInfo, DataSource, ContainerPath } from './rpfmTypes.ts';
const url = "ws://127.0.0.1:45127/ws";
const EXEC_PATH = "C:/Modding/Warhammer3/RPFMv4.7.100/rpfm_server.exe"

class RPFMClient {

    private execPath: string;
    private ws: WebSocket | null;
    private serverProcess: ChildProcess | null = null;

    private game: string;
    private curRequestId: number = 1;
    private pendingResponses = new Map<number, {
        resolve: (resp: Response) => void;
        reject: (err: Error) => void;
    }>();

    public sessionId: number | null = null;

    constructor(execPath: string = EXEC_PATH, sessionId: number | null = null, game: string = 'warhammer_3') {
        this.execPath = execPath;
        this.sessionId = sessionId;
        this.serverProcess = null;
        this.ws = null;
        this.curRequestId = 1;
        this.pendingResponses = new Map();
        this.game = game;
    }

    _connect(): Promise<any> {
        return new Promise((resolve, reject) => {
            this.ws = new WebSocket(url);
            this.ws.onopen = () => {
                const msg = `Connected to RPFM server. Setting game to ${this.game}.`
                this.send({ SetGameSelected: [this.game, true] });
                resolve({ msg, id: this.sessionId });
            }
            this.ws.onclose = () => console.log('Connection closed');

            this.ws.onerror = (err) => {
                console.log('WS error', err);
                reject(err);
            }

            this.ws.onmessage = event => {

                const msg: Message<Response> = JSON.parse(event.data as string);
                if (typeof msg.data === "object" && "SessionConnected" in msg.data) {
                    this.sessionId = msg.data.SessionConnected;
                }
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

    async disconnect(): Promise<void> {
        await this.send("ClientDisconnecting");
        if (this.ws) this.ws.close();
    }


    async stop() {
            return new Promise(res => {
                if (this.ws) {
                    this.send("ClientDisconnecting")
                    this.ws.close();
                }
            })
        }

        send(cmd: Command): Promise < Response > {
            return new Promise((resolve, reject) => {
                const id = this.curRequestId++;
                this.pendingResponses.set(id, { resolve, reject });
                if (this.ws?.OPEN) this.ws.send(JSON.stringify({ id, data: cmd }));
            });
        }

    async loadPackFiles(paths: string[]): Promise < ContainerInfo > {
            const resp = await this.send({ OpenPackFiles: paths });
            return(resp as { ContainerInfo: ContainerInfo }).ContainerInfo;
        }

    async getTreeView(): Promise < [ContainerInfo, RFileInfo[]] > {
            const resp = await this.send("GetPackFileDataForTreeView");
            return(resp as { ContainerInfoVecRFileInfo: [ContainerInfo, RFileInfo[]] }).ContainerInfoVecRFileInfo;
        }

    // TODO: Check return type here.
    async closePack(): Promise < Response > {
            const resp = await this.send("ClosePack");
            return(resp) as Response;
        }

    async getTablePaths(table: string): Promise < string[] > {
            const resp = await this.send({ GetTablesByTableName: table });
            return(resp as { VecString: string[] }).VecString;
        }

    async extractPackedFiles(paths: Partial<Record<DataSource, ContainerPath[]>>, dest: string, asTsv: boolean = false) {
            const resp = await this.send({ ExtractPackedFiles: [paths, dest, asTsv] });
            return (resp as { StringVecPathBuf: [string, string[]] }).StringVecPathBuf;
        }

    async insertPackedFiles(srcPaths: string[], destContPaths: ContainerPath[], ignorePaths: string[] | null = null): Promise < [ContainerPath[], string | null] > {
            const resp = await this.send({ AddPackedFiles: [srcPaths, destContPaths, ignorePaths] });
            return(resp as { VecContainerPathOptionString: [ContainerPath[], string | null]
        }).VecContainerPathOptionString;
    }

    async savePack(): Promise<ContainerInfo> {
        const resp = await this.send("SavePack");
        return (resp as { ContainerInfo: ContainerInfo }).ContainerInfo;
    }

    async savePackAs(path: string): Promise<ContainerInfo> {
        const resp = await this.send({ SavePackAs: path });
        return (resp as { ContainerInfo: ContainerInfo }).ContainerInfo;
    }

    async getTableVersionString(tableName: string, fileName: string): Promise<string> {
        const resp = await this.send({ GetTableVersionFromDependencyPackFile: tableName });
        const version = (resp as { I32: number }).I32;
        return `#${tableName};${version};db/${tableName}/${fileName}`;
    }

}

export {
    RPFMClient
}