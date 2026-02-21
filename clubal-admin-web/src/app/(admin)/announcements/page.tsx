"use client";

import { useState, useEffect } from "react";
import { useAuth } from "@/contexts/AuthContext";
import { useAdminRole } from "@/hooks/useAdminRole";
import {
  listAnnouncements,
  createAnnouncement,
  updateAnnouncement,
  deleteAnnouncement,
  incrementAnnouncementViewCount,
} from "@/lib/services/announcements";
import { writeAdminLog } from "@/lib/adminLogs";
import type { Announcement } from "@/types/admin";

function formatDate(ts: { toDate?: () => Date } | null): string {
  if (!ts?.toDate) return "-";
  return new Date(ts.toDate()).toLocaleString("ko-KR");
}

export default function AnnouncementsPage() {
  const { user } = useAuth();
  const { canManageAnnouncements } = useAdminRole();
  const [items, setItems] = useState<Announcement[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [modal, setModal] = useState<"create" | "edit" | "view" | null>(null);
  const [selected, setSelected] = useState<Announcement | null>(null);
  const [form, setForm] = useState({
    title: "",
    content: "",
    isPinned: false,
    isActive: true,
  });
  const [submitting, setSubmitting] = useState(false);

  async function load() {
    setLoading(true);
    setError("");
    try {
      const list = await listAnnouncements();
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

  async function handleCreate() {
    if (!user) return;
    setSubmitting(true);
    setError("");
    try {
      const id = await createAnnouncement({
        title: form.title,
        content: form.content,
        createdBy: user.uid,
        isPinned: form.isPinned,
        isActive: form.isActive,
      });
      await writeAdminLog(
        user.uid,
        user.email ?? undefined,
        "announcement_create",
        id,
        "announcement",
        { title: form.title }
      );
      setModal(null);
      setForm({ title: "", content: "", isPinned: false, isActive: true });
      await load();
    } catch (e) {
      setError(e instanceof Error ? e.message : "등록 실패");
    } finally {
      setSubmitting(false);
    }
  }

  async function handleUpdate() {
    if (!user || !selected) return;
    setSubmitting(true);
    setError("");
    try {
      await updateAnnouncement(selected.id, {
        title: form.title,
        content: form.content,
        isPinned: form.isPinned,
        isActive: form.isActive,
      });
      await writeAdminLog(
        user.uid,
        user.email ?? undefined,
        "announcement_update",
        selected.id,
        "announcement",
        { title: form.title }
      );
      setModal(null);
      setSelected(null);
      await load();
    } catch (e) {
      setError(e instanceof Error ? e.message : "수정 실패");
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDelete(id: string) {
    if (!user || !confirm("정말 삭제하시겠습니까?")) return;
    setSubmitting(true);
    setError("");
    try {
      await deleteAnnouncement(id);
      await writeAdminLog(
        user.uid,
        user.email ?? undefined,
        "announcement_delete",
        id,
        "announcement"
      );
      setModal(null);
      setSelected(null);
      await load();
    } catch (e) {
      setError(e instanceof Error ? e.message : "삭제 실패");
    } finally {
      setSubmitting(false);
    }
  }

  function openView(a: Announcement) {
    setSelected(a);
    setForm({
      title: a.title,
      content: a.content,
      isPinned: a.isPinned,
      isActive: a.isActive,
    });
    setModal("view");
    incrementAnnouncementViewCount(a.id).then(() => load());
  }

  function openEdit(a: Announcement) {
    setSelected(a);
    setForm({
      title: a.title,
      content: a.content,
      isPinned: a.isPinned,
      isActive: a.isActive,
    });
    setModal("edit");
  }

  if (!canManageAnnouncements) {
    return (
      <div className="p-4 sm:p-6 lg:p-8">
        <h1 className="text-xl sm:text-2xl font-bold text-gray-800 mb-6">
          공지 관리
        </h1>
        <div className="p-6 bg-amber-50 text-amber-800 rounded-lg">
          이 메뉴에 대한 접근 권한이 없습니다.
        </div>
      </div>
    );
  }

  return (
    <div className="p-4 sm:p-6 lg:p-8">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6 lg:mb-8">
        <h1 className="text-xl sm:text-2xl font-bold text-gray-800">
          공지 관리
        </h1>
        {canManageAnnouncements && (
          <button
            onClick={() => {
              setSelected(null);
              setForm({ title: "", content: "", isPinned: false, isActive: true });
              setModal("create");
            }}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm sm:text-base"
          >
            + 공지 작성
          </button>
        )}
      </div>

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
            등록된 공지가 없습니다.
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
                    고정
                  </th>
                  <th className="hidden md:table-cell px-4 py-3 text-left text-xs font-medium text-gray-600 uppercase">
                    조회수
                  </th>
                  <th className="hidden lg:table-cell px-4 py-3 text-left text-xs font-medium text-gray-600 uppercase">
                    상태
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
                {items.map((a) => (
                  <tr key={a.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3">
                      <button
                        onClick={() => openView(a)}
                        className="text-left text-blue-600 hover:underline font-medium"
                      >
                        {a.title}
                        {a.isPinned && (
                          <span className="ml-2 text-amber-500">📌</span>
                        )}
                      </button>
                    </td>
                    <td className="hidden sm:table-cell px-4 py-3 text-gray-600">
                      {a.isPinned ? "예" : "-"}
                    </td>
                    <td className="hidden md:table-cell px-4 py-3 text-gray-600">
                      {a.viewCount}
                    </td>
                    <td className="hidden lg:table-cell px-4 py-3">
                      <span
                        className={`px-2 py-0.5 rounded text-xs ${
                          a.isActive ? "bg-green-100 text-green-800" : "bg-gray-100 text-gray-600"
                        }`}
                      >
                        {a.isActive ? "노출" : "비노출"}
                      </span>
                    </td>
                    <td className="hidden md:table-cell px-4 py-3 text-gray-500 text-sm">
                      {formatDate(a.updatedAt)}
                    </td>
                    <td className="px-4 py-3 text-right space-x-2">
                      <button
                        onClick={() => openView(a)}
                        className="text-blue-600 hover:underline text-sm"
                      >
                        보기
                      </button>
                      {canManageAnnouncements && (
                        <>
                          <button
                            onClick={() => openEdit(a)}
                            className="text-gray-600 hover:underline text-sm"
                          >
                            수정
                          </button>
                          <button
                            onClick={() => handleDelete(a.id)}
                            disabled={submitting}
                            className="text-red-600 hover:underline text-sm disabled:opacity-50"
                          >
                            삭제
                          </button>
                        </>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {modal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-lg w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <h2 className="text-lg font-bold text-gray-800 mb-4">
                {modal === "create"
                  ? "공지 작성"
                  : modal === "edit"
                    ? "공지 수정"
                    : "공지 상세"}
              </h2>
              {modal === "view" && selected && (
                <div className="space-y-4 mb-4">
                  <p className="text-gray-600 text-sm">
                    조회수: {selected.viewCount} | 수정:{" "}
                    {formatDate(selected.updatedAt)}
                  </p>
                  <p className="font-medium text-gray-800">{selected.title}</p>
                  <div className="text-gray-600 whitespace-pre-wrap border rounded p-4 bg-gray-50">
                    {selected.content}
                  </div>
                  <p className="text-sm text-gray-500">
                    고정: {selected.isPinned ? "예" : "아니오"} | 상태:{" "}
                    {selected.isActive ? "노출" : "비노출"}
                  </p>
                </div>
              )}
              {(modal === "create" || modal === "edit") && (
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      제목
                    </label>
                    <input
                      value={form.title}
                      onChange={(e) =>
                        setForm((f) => ({ ...f, title: e.target.value }))
                      }
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                      placeholder="제목"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      내용
                    </label>
                    <textarea
                      value={form.content}
                      onChange={(e) =>
                        setForm((f) => ({ ...f, content: e.target.value }))
                      }
                      rows={6}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                      placeholder="내용"
                    />
                  </div>
                  <div className="flex flex-wrap gap-4">
                    <label className="flex items-center gap-2">
                      <input
                        type="checkbox"
                        checked={form.isPinned}
                        onChange={(e) =>
                          setForm((f) => ({
                            ...f,
                            isPinned: e.target.checked,
                          }))
                        }
                        className="rounded"
                      />
                      <span className="text-sm text-gray-700">상단 고정</span>
                    </label>
                    <label className="flex items-center gap-2">
                      <input
                        type="checkbox"
                        checked={form.isActive}
                        onChange={(e) =>
                          setForm((f) => ({
                            ...f,
                            isActive: e.target.checked,
                          }))
                        }
                        className="rounded"
                      />
                      <span className="text-sm text-gray-700">노출</span>
                    </label>
                  </div>
                </div>
              )}
              <div className="flex justify-end gap-2 mt-6">
                {modal === "view" && (
                  <>
                    {canManageAnnouncements && selected && (
                      <button
                        onClick={() => setModal("edit")}
                        className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
                      >
                        수정
                      </button>
                    )}
                    <button
                      onClick={() => {
                        setModal(null);
                        setSelected(null);
                      }}
                      className="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700"
                    >
                      닫기
                    </button>
                  </>
                )}
                {(modal === "create" || modal === "edit") && (
                  <>
                    <button
                      onClick={() => {
                        setModal(null);
                        setSelected(null);
                      }}
                      className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
                    >
                      취소
                    </button>
                    <button
                      onClick={modal === "create" ? handleCreate : handleUpdate}
                      disabled={submitting || !form.title.trim()}
                      className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
                    >
                      {submitting ? "저장 중..." : "저장"}
                    </button>
                  </>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
