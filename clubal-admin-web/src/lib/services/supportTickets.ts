import {
  collection,
  doc,
  getDocs,
  getDoc,
  addDoc,
  updateDoc,
  query,
  orderBy,
  serverTimestamp,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import type {
  SupportTicket,
  SupportTicketInput,
  SupportTicketStatus,
} from "@/types/admin";

const COLLECTION = "support_tickets";

function toTicket(id: string, data: Record<string, unknown>): SupportTicket {
  const status = (data.status ?? "open") as SupportTicketStatus;
  const priority = (data.priority ?? "medium") as SupportTicket["priority"];
  return {
    id,
    userId: String(data.userId ?? ""),
    userEmail: data.userEmail as string | undefined,
    userName: data.userName as string | undefined,
    subject: String(data.subject ?? ""),
    message: String(data.message ?? ""),
    status,
    priority,
    reply: data.reply as string | undefined,
    repliedBy: data.repliedBy as string | undefined,
    repliedAt: data.repliedAt as SupportTicket["repliedAt"],
    createdAt: (data.createdAt as SupportTicket["createdAt"]) ?? null,
    updatedAt: (data.updatedAt as SupportTicket["updatedAt"]) ?? null,
  };
}

export async function listSupportTickets(): Promise<SupportTicket[]> {
  const q = query(
    collection(db, COLLECTION),
    orderBy("updatedAt", "desc")
  );
  const snap = await getDocs(q);
  return snap.docs.map((d) => toTicket(d.id, d.data()));
}

export async function getSupportTicket(
  id: string
): Promise<SupportTicket | null> {
  const ref = doc(db, COLLECTION, id);
  const snap = await getDoc(ref);
  if (!snap.exists()) return null;
  return toTicket(snap.id, snap.data());
}

export async function createSupportTicket(
  input: SupportTicketInput
): Promise<string> {
  const data = {
    userId: input.userId,
    userEmail: input.userEmail ?? null,
    userName: input.userName ?? null,
    subject: input.subject,
    message: input.message,
    status: "open",
    priority: input.priority ?? "medium",
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  };
  const ref = await addDoc(collection(db, COLLECTION), data);
  return ref.id;
}

export async function updateTicketStatus(
  id: string,
  status: SupportTicketStatus
): Promise<void> {
  const ref = doc(db, COLLECTION, id);
  await updateDoc(ref, {
    status,
    updatedAt: serverTimestamp(),
  });
}

export async function replyToTicket(
  id: string,
  reply: string,
  repliedBy: string
): Promise<void> {
  const ref = doc(db, COLLECTION, id);
  await updateDoc(ref, {
    reply,
    repliedBy,
    repliedAt: serverTimestamp(),
    status: "in_progress",
    updatedAt: serverTimestamp(),
  });
}
