"use client";

import { useState, useEffect } from "react";
import { useAuth } from "@/contexts/AuthContext";
import { useAdminRole } from "@/hooks/useAdminRole";
import {
  listSupportTickets,
  updateTicketStatus,
  replyToTicket,
} from "@/lib/services/supportTickets";
import { writeAdminLog } from "@/lib/adminLogs";
import type {
  SupportTicket,
  SupportTicketStatus,
  SupportTicketPriority,
} from "@/types/admin";

const STATUS_LABEL: Record<SupportTicketStatus, string> = {
  open: "접수",
  in_progress: "처리중",
  closed: "완료",
};

const PRIORITY_LABEL: Record<SupportTicketPriority, string> = {
  low: "낮음",
  medium: "보통",
  high: "높음",
  urgent: "긴급",
};

const PRIORITY_COLOR: Record<SupportTicketPriority, string> = {
  low: "bg-gray-100 text-gray-700",
  medium: "bg-blue-100 text-blue-800",
  high: "bg-amber-100 text-amber-800",
  urgent: "bg-red-100 text-red-800",
};

const NEXT_STATUS: Record<SupportTicketStatus, SupportTicketStatus | null> = {
  open: "in_progress",
  in_progress: "closed",
  closed: null,
};

function formatDate(ts: { toDate?: () => Date } | null): string {
  if (!ts?.toDate) return "-";
  return new Date(ts.toDate()).toLocaleString("ko-KR");
}

export default function InquiriesPage() {
  const { user } = useAuth();
  const { canManageTickets } = useAdminRole();
  const [items, setItems] = useState<SupportTicket[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [detailId, setDetailId] = useState<string | null>(null);
  const [replyText, setReplyText] = useState("");
  const [submitting, setSubmitting] = useState(false);

  async function load() {
    setLoading(true);
    setError("");
    try {
      const list = await listSupportTickets();
      setItems(list);
    } catch (e) {
      setError(e instanceof Error ? e.message : "로드 실패");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  const selected = items.find((t) => t.id === detailId);

  async function handleStatusChange(ticket: SupportTicket) {
    if (!user || !canManageTickets) return;
    const next = NEXT_STATUS[ticket.status];
    if (!next) return;
    setSubmitting(true);
    setError("");
    try {
      await updateTicketStatus(ticket.id, next);
      await writeAdminLog(
        user.uid,
        user.email ?? undefined,
        "ticket_status_change",
        ticket.id,
        "support_ticket",
        { from: ticket.status, to: next }
      );
      await load();
    } catch (e) {
      setError(e instanceof Error ? e.message : "상태 변경 실패");
    } finally {
      setSubmitting(false);
    }
  }

  async function handleReply() {
    if (!user || !selected || !replyText.trim()) return;
    setSubmitting(true);
    setError("");
    try {
      await replyToTicket(selected.id, replyText.trim(), user.uid);
      await writeAdminLog(
        user.uid,
        user.email ?? undefined,
        "ticket_reply",
        selected.id,
        "support_ticket"
      );
      setReplyText("");
      setDetailId(null);
      await load();
    } catch (e) {
      setError(e instanceof Error ? e.message : "답변 등록 실패");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="p-4 sm:p-6 lg:p-8">
      <h1 className="text-xl sm:text-2xl font-bold text-gray-800 mb-6 lg:mb-8">
        문의 관리
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
            등록된 문의가 없습니다.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-600 uppercase">
                    제목
                  </th>
                  <th className="hidden sm:table-cell px-4 py-3 text-left text-xs font-medium text-gray-600 uppercase">
                    상태
                  </th>
                  <th className="hidden md:table-cell px-4 py-3 text-left text-xs font-medium text-gray-600 uppercase">
                    우선순위
                  </th>
                  <th className="hidden lg:table-cell px-4 py-3 text-left text-xs font-medium text-gray-600 uppercase">
                    작성자
                  </th>
                  <th className="hidden md:table-cell px-4 py-3 text-left text-xs font-medium text-gray-600 uppercase">
                    수정일
                  </th>
                  <th className="px-4 py-3 text-right text-xs font-medium text-gray-600 uppercase">
                    작업
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {items.map((t) => (
                  <tr key={t.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3">
                      <button
                        onClick={() =>
                          setDetailId(detailId === t.id ? null : t.id)
                        }
                        className="text-left text-blue-600 hover:underline font-medium"
                      >
                        {t.subject}
                      </button>
                    </td>
                    <td className="hidden sm:table-cell px-4 py-3">
                      <span
                        className={`px-2 py-0.5 rounded text-xs ${
                          t.status === "open"
                            ? "bg-blue-100 text-blue-800"
                            : t.status === "in_progress"
                              ? "bg-amber-100 text-amber-800"
                              : "bg-gray-100 text-gray-600"
                        }`}
                      >
                        {STATUS_LABEL[t.status]}
                      </span>
                    </td>
                    <td className="hidden md:table-cell px-4 py-3">
                      <span
                        className={`px-2 py-0.5 rounded text-xs ${
                          PRIORITY_COLOR[t.priority]
                        }`}
                      >
                        {PRIORITY_LABEL[t.priority]}
                      </span>
                    </td>
                    <td className="hidden lg:table-cell px-4 py-3 text-gray-600 text-sm">
                      {t.userName || t.userEmail || t.userId || "-"}
                    </td>
                    <td className="hidden md:table-cell px-4 py-3 text-gray-500 text-sm">
                      {formatDate(t.updatedAt)}
                    </td>
                    <td className="px-4 py-3 text-right space-x-2">
                      <button
                        onClick={() =>
                          setDetailId(detailId === t.id ? null : t.id)
                        }
                        className="text-blue-600 hover:underline text-sm"
                      >
                        {detailId === t.id ? "접기" : "상세"}
                      </button>
                      {canManageTickets && NEXT_STATUS[t.status] && (
                        <button
                          onClick={() => handleStatusChange(t)}
                          disabled={submitting}
                          className="text-green-600 hover:underline text-sm disabled:opacity-50"
                        >
                          → {STATUS_LABEL[NEXT_STATUS[t.status]!]}
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {selected && (
        <div className="mt-6 p-4 sm:p-6 bg-white rounded-lg shadow">
          <h2 className="text-lg font-bold text-gray-800 mb-4">문의 상세</h2>
          <div className="space-y-3 text-sm">
            <p>
              <span className="font-medium text-gray-700">제목:</span>{" "}
              {selected.subject}
            </p>
            <p>
              <span className="font-medium text-gray-700">상태:</span>{" "}
              <span
                className={`px-2 py-0.5 rounded ${
                  selected.status === "open"
                    ? "bg-blue-100 text-blue-800"
                    : selected.status === "in_progress"
                      ? "bg-amber-100 text-amber-800"
                      : "bg-gray-100 text-gray-600"
                }`}
              >
                {STATUS_LABEL[selected.status]}
              </span>
            </p>
            <p>
              <span className="font-medium text-gray-700">작성자:</span>{" "}
              {selected.userName || selected.userEmail || selected.userId || "-"}
            </p>
            <p>
              <span className="font-medium text-gray-700">등록일:</span>{" "}
              {formatDate(selected.createdAt)}
            </p>
            <div>
              <span className="font-medium text-gray-700">내용:</span>
              <div className="mt-1 p-3 bg-gray-50 rounded text-gray-600 whitespace-pre-wrap">
                {selected.message}
              </div>
            </div>
            {selected.reply && (
              <div>
                <span className="font-medium text-gray-700">답변:</span>
                <p className="mt-1 text-gray-500 text-xs">
                  {selected.repliedAt &&
                    formatDate(selected.repliedAt) + " · "}
                  {selected.repliedBy ?? ""}
                </p>
                <div className="mt-1 p-3 bg-green-50 rounded text-gray-600 whitespace-pre-wrap">
                  {selected.reply}
                </div>
              </div>
            )}
          </div>
          {canManageTickets && (
            <div className="mt-4">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                답변 작성
              </label>
              <textarea
                value={replyText}
                onChange={(e) => setReplyText(e.target.value)}
                rows={3}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                placeholder="답변 내용"
              />
              <div className="mt-2 flex gap-2">
                <button
                  onClick={handleReply}
                  disabled={submitting || !replyText.trim()}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
                >
                  {submitting ? "등록 중..." : "답변 등록"}
                </button>
                <button
                  onClick={() => {
                    setDetailId(null);
                    setReplyText("");
                  }}
                  className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
                >
                  닫기
                </button>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
