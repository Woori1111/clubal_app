import { collection, addDoc, serverTimestamp } from "firebase/firestore";
import { db } from "./firebase";
import type { AdminLogAction } from "@/types/admin";

export async function writeAdminLog(
  adminUid: string,
  adminEmail: string | undefined,
  action: AdminLogAction,
  targetId: string,
  targetType: "announcement" | "support_ticket",
  metadata?: Record<string, unknown>
): Promise<void> {
  await addDoc(collection(db, "admin_logs"), {
    adminUid,
    adminEmail: adminEmail ?? null,
    action,
    targetId,
    targetType,
    metadata: metadata ?? {},
    createdAt: serverTimestamp(),
  });
}
