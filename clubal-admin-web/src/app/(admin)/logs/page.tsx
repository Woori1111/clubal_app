"use client";

import { useState, useEffect } from "react";
import { useAdminRole } from "@/hooks/useAdminRole";
import { listAdminLogs } from "@/lib/services/adminLogs";
import type { AdminLog, AdminLogAction } from "@/types/admin";

const ACTION_LABEL: Record<AdminLogAction, string> = {
  announcement_create: "공지 작성",
  announcement_update: "공지 수정",
  announcement_delete: "공지 삭제",
  ticket_status_change: "문의 상태 변경",
  ticket_reply: "문의 답변",
};

function formatDate(ts: { toDate?: () => Date } | null): string {
  if (!ts?.toDate) return "-";
  return new Date(ts.toDate()).toLocaleString("ko-KR");
}

export default function AdminLogsPage() {
  const { canViewLogs } = useAdminRole();
  const [items, setItems] = useState<AdminLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!canViewLogs) return;
    setLoading(true);
    setError("");
    listAdminLogs(100)
      .then(setItems)
      .catch((e) => setError(e instanceof Error ? e.message : "로드 실패"))
      .finally(() => setLoading(false));
  }, [canViewLogs]);

  if (!canViewLogs) {
    return (
      <div className="p-4 sm:p-6 lg:p-8">
        <h1 className="text-xl sm:text-2xl font-bold text-gray-800 mb-6">
          관리자 로그
        </h1>
        <div className="p-6 bg-amber-50 text-amber-800 rounded-lg">
          이 메뉴에 대한 접근 권한이 없습니다.
        </div>
      </div>
    );
  }

  return (
    <div className="p-4 sm:p-6 lg:p-8">
      <h1 className="text-xl sm:text-2xl font-bold text-gray-800 mb-6 lg:mb-8">
        관리자 로그
      </h1>

      {error && (
        <div className="mb-4 p-3 text-sm text-red-600 bg-red-50 rounded-lg">
          {error}
        </div>
      )}

      <div className="bg-white rounded-lg shadow overflow-hidden">
        {loading ? (
          <div className="p-8 text-center text-gray-500">로딩 중...</div>
        ) : items.length === 0 ? (
          <div className="p-8 text-center text-gray-500">
            로그가 없습니다.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-600 uppercase">
                    일시
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-600 uppercase">
                    관리자
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-600 uppercase">
                    액션
                  </th>
                  <th className="hidden sm:table-cell px-4 py-3 text-left text-xs font-medium text-gray-600 uppercase">
                    대상
                  </th>
                  <th className="hidden md:table-cell px-4 py-3 text-left text-xs font-medium text-gray-600 uppercase">
                    메타
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {items.map((log) => (
                  <tr key={log.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3 text-gray-600 text-sm">
                      {formatDate(log.createdAt)}
                    </td>
                    <td className="px-4 py-3 text-gray-600 text-sm">
                      {log.adminEmail || log.adminUid}
                    </td>
                    <td className="px-4 py-3">
                      <span className="px-2 py-0.5 rounded text-xs bg-gray-100 text-gray-800">
                        {ACTION_LABEL[log.action]}
                      </span>
                    </td>
                    <td className="hidden sm:table-cell px-4 py-3 text-gray-500 text-sm">
                      {log.targetType} / {log.targetId.slice(0, 8)}...
                    </td>
                    <td className="hidden md:table-cell px-4 py-3 text-gray-400 text-xs">
                      {log.metadata &&
                      Object.keys(log.metadata).length > 0 ? (
                        <pre className="truncate max-w-xs">
                          {JSON.stringify(log.metadata)}
                        </pre>
                      ) : (
                        "-"
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
