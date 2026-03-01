import { RPFMClient } from "./rpfm-client.ts";

const sessions = new Map<number, Promise<RPFMClient>>();

const initSession = async (sessionId?: number): Promise<RPFMClient> => { 
    const client = new RPFMClient();
    await client.connect(sessionId);
    return client;
}

export const getOrCreateSession = async (sessionId?: number): Promise<RPFMClient> => {
    const key = sessionId ?? 1;
    if (sessions.has(key)) return sessions.get(key)!;
    const sessionPromise = initSession(sessionId);
    sessions.set(key, sessionPromise);
    return sessionPromise;
}

export const deleteSession = (sessionId: number = 1): void => {
    sessions.delete(sessionId);
}

export const deleteAllSessions = (): void => {
    sessions.clear();
}
