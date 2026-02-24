
import WebSocket from 'ws';
import type {
    Message,
    Response,
    Command,
    ContainerInfo,
    RFileInfo,
    DataSource,
    ContainerPath
} from './rpfm-types.js';
const SERVER_URL = "ws://127.0.0.1:45127/ws";

class RPFMClient {

    private ws: WebSocket | null = null;
    private url: string;

    private game: string;
    private curRequestId: number = 1;
    private pendingResponses = new Map<number, {
        resolve: (resp: Response) => void;
        reject: (err: Error) => void;
    }>();

    public sessionId: number | null = null;

    constructor(game: string = 'warhammer_3', url: string = SERVER_URL) {
        this.game = game;
        this.url = url;
    }

    connect(sessionId?: number): Promise<any> {
        console.log('connect', sessionId);
        return new Promise((resolve, reject) => {
            const wsUrl = sessionId ? `${this.url}?session_id=${sessionId}` : this.url;
            this.ws = new WebSocket(wsUrl);

            this.ws.onopen = async () => {
                if (sessionId == null) await this.send({ SetGameSelected: [this.game, true] }).catch(reject);
            }
            this.ws.onclose = () => resolve({ msg: `Closing connection with session id: ${this.sessionId}` });
            this.ws.onerror = (error) => reject(new Error(error.message));

            this.ws.onmessage = event => {
                const msg: Message<Response> = JSON.parse(event.data as string);
                if (typeof msg.data === "object" && "SessionConnected" in msg.data) {
                    this.sessionId = msg.data.SessionConnected;
                    resolve({
                        msg: `Connected to RPFM server session with id ${this.sessionId}`,
                        sessionId: this.sessionId
                    });
                    return;
                }

                const cb = this.pendingResponses.get(msg.id);
                if (!cb) return;

                this.pendingResponses.delete(msg.id);
                if (typeof msg.data === "object" && "Error" in msg.data) {
                    cb.reject(new Error(msg.data.Error));
                } else {
                    cb.resolve(msg.data);
                }
            }
        });
    }

    reconnect(sessionId: number): Promise<{ msg: string, sessionId: number }> {
        return this.connect(sessionId);
    }

    async disconnect(): Promise<void> {
        await this.send("ClientDisconnecting");
        this.ws?.close();
        this.ws = null;
    }

    suspend(): void {
        if (this.ws) {
            this.ws.terminate();
            this.ws.close();
            this.ws.removeAllListeners();
            this.ws = null;
        }
    }

    send(cmd: Command): Promise<Response> {
        return new Promise((resolve, reject) => {
            const id = this.curRequestId++;
            this.pendingResponses.set(id, { resolve, reject });
            if (this.ws?.OPEN) this.ws.send(JSON.stringify({ id, data: cmd }));
        });
    }

    close(): void {
    this.ws?.terminate();
    this.ws = null;
}

    async loadPackFiles(paths: string[]): Promise<ContainerInfo> {
        const resp = await this.send({ OpenPackFiles: paths });
        return (resp as { ContainerInfo: ContainerInfo }).ContainerInfo;
    }

    async getTreeView(): Promise<[ContainerInfo, RFileInfo[]]> {
        const resp = await this.send("GetPackFileDataForTreeView");
        return (resp as { ContainerInfoVecRFileInfo: [ContainerInfo, RFileInfo[]] }).ContainerInfoVecRFileInfo;
    }

    // TODO: Check return type here.
    async closePack(): Promise<Response> {
        const resp = await this.send("ClosePack");
        return (resp) as Response;
    }

    async getTablePaths(table: string): Promise<string[]> {
        const resp = await this.send({ GetTablesByTableName: table });
        return (resp as { VecString: string[] }).VecString;
    }

    async extractPackedFiles(paths: Partial<Record<DataSource, ContainerPath[]>>, dest: string, asTsv: boolean = false) {
        const resp = await this.send({ ExtractPackedFiles: [paths, dest, asTsv] });
        return (resp as { StringVecPathBuf: [string, string[]] }).StringVecPathBuf;
    }

    async insertPackedFiles(srcPaths: string[], destContPaths: ContainerPath[], ignorePaths: string[] | null = null): Promise<[ContainerPath[], string | null]> {
        const resp = await this.send({ AddPackedFiles: [srcPaths, destContPaths, ignorePaths] });
        return (resp as {
            VecContainerPathOptionString: [ContainerPath[], string | null]
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