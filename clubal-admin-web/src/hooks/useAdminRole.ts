"use client";

import { useAuth } from "@/contexts/AuthContext";
import type { AdminRole } from "@/types/admin";

/** 역할별 권한: super=전체, editor=공지+일부, support=문의만 */
const ROLE_PERMISSIONS = {
  super: {
    canManageAnnouncements: true,
    canManageTickets: true,
    canManageUsers: true,
    canViewLogs: true,
  },
  editor: {
    canManageAnnouncements: true,
    canManageTickets: true,
    canManageUsers: false,
    canViewLogs: true,
  },
  support: {
    canManageAnnouncements: false,
    canManageTickets: true,
    canManageUsers: false,
    canViewLogs: false,
  },
} as const;

export function useAdminRole() {
  const { adminRole } = useAuth();
  const permissions = adminRole
    ? ROLE_PERMISSIONS[adminRole]
    : {
        canManageAnnouncements: false,
        canManageTickets: false,
        canManageUsers: false,
        canViewLogs: false,
      };

  return {
    adminRole: adminRole ?? null,
    ...permissions,
    isSuper: adminRole === "super",
  };
}
