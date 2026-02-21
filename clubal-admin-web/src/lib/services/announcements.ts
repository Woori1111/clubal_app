import {
  collection,
  doc,
  getDocs,
  getDoc,
  addDoc,
  updateDoc,
  deleteDoc,
  query,
  orderBy,
  serverTimestamp,
  increment,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import type { Announcement, AnnouncementInput } from "@/types/admin";

const COLLECTION = "announcements";

function toAnnouncement(
  id: string,
  data: Record<string, unknown>
): Announcement {
  return {
    id,
    title: String(data.title ?? ""),
    content: String(data.content ?? ""),
    createdBy: String(data.createdBy ?? ""),
    createdAt: (data.createdAt as Announcement["createdAt"]) ?? null,
    updatedAt: (data.updatedAt as Announcement["updatedAt"]) ?? null,
    viewCount: Number(data.viewCount ?? 0),
    isPinned: Boolean(data.isPinned),
    isActive: data.isActive !== false,
  };
}

export async function listAnnouncements(): Promise<Announcement[]> {
  const q = query(
    collection(db, COLLECTION),
    orderBy("isPinned", "desc"),
    orderBy("createdAt", "desc")
  );
  const snap = await getDocs(q);
  return snap.docs.map((d) => {
    const data = d.data();
    return toAnnouncement(d.id, { ...data, createdAt: data.createdAt });
  });
}

export async function getAnnouncement(id: string): Promise<Announcement | null> {
  const ref = doc(db, COLLECTION, id);
  const snap = await getDoc(ref);
  if (!snap.exists()) return null;
  const data = snap.data();
  return toAnnouncement(snap.id, { ...data, createdAt: data.createdAt });
}

export async function createAnnouncement(
  input: AnnouncementInput
): Promise<string> {
  const data = {
    title: input.title,
    content: input.content,
    createdBy: input.createdBy,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    viewCount: 0,
    isPinned: input.isPinned ?? false,
    isActive: input.isActive ?? true,
  };
  const ref = await addDoc(collection(db, COLLECTION), data);
  return ref.id;
}

export async function updateAnnouncement(
  id: string,
  updates: Partial<
    Pick<
      AnnouncementInput,
      "title" | "content" | "isPinned" | "isActive"
    >
  >
): Promise<void> {
  const ref = doc(db, COLLECTION, id);
  await updateDoc(ref, {
    ...updates,
    updatedAt: serverTimestamp(),
  });
}

export async function deleteAnnouncement(id: string): Promise<void> {
  const ref = doc(db, COLLECTION, id);
  await deleteDoc(ref);
}

export async function incrementAnnouncementViewCount(id: string): Promise<void> {
  const ref = doc(db, COLLECTION, id);
  await updateDoc(ref, {
    viewCount: increment(1),
    updatedAt: serverTimestamp(),
  });
}
