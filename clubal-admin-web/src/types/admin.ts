import type { Timestamp } from "firebase/firestore";

/** 관리자 역할: super(전체), editor(편집), support(고객지원) */
export type AdminRole = "super" | "editor" | "support";

export interface AdminDoc {
  role: AdminRole;
  email?: string;
  displayName?: string;
  createdAt?: Timestamp;
}

export interface Announcement {
  id: string;
  title: string;
  content: string;
  createdBy: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  viewCount: number;
  isPinned: boolean;
  isActive: boolean;
}

export interface AnnouncementInput {
  title: string;
  content: string;
  createdBy: string;
  isPinned?: boolean;
  isActive?: boolean;
}

export type SupportTicketStatus = "open" | "in_progress" | "closed";

export type SupportTicketPriority = "low" | "medium" | "high" | "urgent";

export interface SupportTicket {
  id: string;
  userId: string;
  userEmail?: string;
  userName?: string;
  subject: string;
  message: string;
  status: SupportTicketStatus;
  priority: SupportTicketPriority;
  reply?: string;
  repliedBy?: string;
  repliedAt?: Timestamp;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface SupportTicketInput {
  userId: string;
  userEmail?: string;
  userName?: string;
  subject: string;
  message: string;
  priority?: SupportTicketPriority;
}

export type AdminLogAction =
  | "announcement_create"
  | "announcement_update"
  | "announcement_delete"
  | "ticket_status_change"
  | "ticket_reply";

export interface AdminLog {
  id: string;
  adminUid: string;
  adminEmail?: string;
  action: AdminLogAction;
  targetId: string;
  targetType: "announcement" | "support_ticket";
  metadata?: Record<string, unknown>;
  createdAt: Timestamp;
}
