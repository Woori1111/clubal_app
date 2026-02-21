"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useAuth } from "@/contexts/AuthContext";
import { useAdminRole } from "@/hooks/useAdminRole";

const navItems: Array<{
  href: string;
  label: string;
  icon: string;
  requirePermission?: "canManageAnnouncements" | "canManageTickets" | "canManageUsers" | "canViewLogs";
}> = [
  { href: "/dashboard", label: "대시보드", icon: "📊" },
  { href: "/announcements", label: "공지 관리", icon: "📢", requirePermission: "canManageAnnouncements" },
  { href: "/users", label: "유저 관리", icon: "👥", requirePermission: "canManageUsers" },
  { href: "/inquiries", label: "문의 관리", icon: "💬", requirePermission: "canManageTickets" },
  { href: "/reports", label: "제보 관리", icon: "🐛" },
  { href: "/search", label: "검색", icon: "🔍" },
  { href: "/logs", label: "관리자 로그", icon: "📋", requirePermission: "canViewLogs" },
];

export default function AdminSidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const { logout } = useAuth();
  const permissions = useAdminRole();

  const visibleItems = navItems.filter((item) => {
    if (!item.requirePermission) return true;
    return permissions[item.requirePermission];
  });

  async function handleLogout() {
    await logout();
    router.push("/login");
    router.refresh();
  }

  return (
    <aside className="w-64 min-h-screen bg-gray-900 text-white flex flex-col">
      <div className="p-6 border-b border-gray-700">
        <h2 className="text-lg font-bold">Clubal 관리자</h2>
      </div>
      <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
        {visibleItems.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${
                isActive ? "bg-blue-600" : "hover:bg-gray-800"
              }`}
            >
              <span>{item.icon}</span>
              <span>{item.label}</span>
            </Link>
          );
        })}
      </nav>
      <div className="p-4 border-t border-gray-700">
        <button
          onClick={handleLogout}
          className="w-full flex items-center gap-3 px-4 py-3 rounded-lg text-gray-300 hover:bg-gray-800 hover:text-white transition-colors"
        >
          <span>🚪</span>
          <span>로그아웃</span>
        </button>
      </div>
    </aside>
  );
}
