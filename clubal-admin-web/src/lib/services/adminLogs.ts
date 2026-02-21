import {
  collection,
  getDocs,
  query,
  orderBy,
  limit,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import type { AdminLog } from "@/types/admin";

function toLog(id: string, data: Record<string, unknown>): AdminLog {
  return {
    id,
    adminUid: String(data.adminUid ?? ""),
    adminEmail: (data.adminEmail as string) || undefined,
    action: data.action as AdminLog["action"],
    targetId: String(data.targetId ?? ""),
    targetType: data.targetType as "announcement" | "support_ticket",
    metadata: data.metadata as Record<string, unknown> | undefined,
    createdAt: data.createdAt as AdminLog["createdAt"],
  };
}

export async function listAdminLogs(max = 100): Promise<AdminLog[]> {
  const q = query(
    collection(db, "admin_logs"),
    orderBy("createdAt", "desc"),
    limit(max)
  );
  const snap = await getDocs(q);
  return snap.docs.map((d) => toLog(d.id, d.data()));
}
