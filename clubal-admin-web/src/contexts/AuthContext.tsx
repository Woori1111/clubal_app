"use client";

import {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  type ReactNode,
} from "react";
import {
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
  type User,
} from "firebase/auth";
import { doc, getDoc } from "firebase/firestore";
import { auth, db } from "@/lib/firebase";
import type { AdminRole } from "@/types/admin";

export type AuthErrorType =
  | "LOGIN_FAILED"
  | "NO_PERMISSION"
  | "NETWORK_ERROR"
  | "UNKNOWN";

export interface AuthState {
  user: User | null;
  idToken: string | null;
  isAdmin: boolean;
  adminRole: AdminRole | null;
  loading: boolean;
}

interface AuthContextValue extends AuthState {
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  getToken: () => Promise<string | null>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [idToken, setIdToken] = useState<string | null>(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [adminRole, setAdminRole] = useState<AdminRole | null>(null);
  const [loading, setLoading] = useState(true);

  const checkAdminRole = useCallback(
    async (uid: string): Promise<{ isAdmin: boolean; role: AdminRole | null }> => {
      try {
        const adminsRef = doc(db, "admins", uid);
        const adminsSnap = await getDoc(adminsRef);
        if (adminsSnap.exists()) {
          const role = adminsSnap.data()?.role as AdminRole | undefined;
          const validRoles: AdminRole[] = ["super", "editor", "support"];
          return {
            isAdmin: true,
            role: role && validRoles.includes(role) ? role : "support",
          };
        }
        const usersRef = doc(db, "users", uid);
        const usersSnap = await getDoc(usersRef);
        if (usersSnap.exists() && usersSnap.data()?.role === "ADMIN") {
          return { isAdmin: true, role: "super" };
        }
        return { isAdmin: false, role: null };
      } catch {
        return { isAdmin: false, role: null };
      }
    },
    []
  );

  const refreshTokenAndRole = useCallback(
    async (u: User) => {
      const token = await u.getIdToken();
      setIdToken(token);
      const { isAdmin: admin, role } = await checkAdminRole(u.uid);
      setIsAdmin(admin);
      setAdminRole(role);
      if (!admin) {
        await signOut(auth);
      }
    },
    [checkAdminRole]
  );

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (u) => {
      if (u) {
        await refreshTokenAndRole(u);
        setUser(u);
      } else {
        setUser(null);
        setIdToken(null);
        setIsAdmin(false);
        setAdminRole(null);
      }
      setLoading(false);
    });
    return () => unsubscribe();
  }, [refreshTokenAndRole]);

  const login = useCallback(
    async (email: string, password: string) => {
      setLoading(true);
      try {
        const cred = await signInWithEmailAndPassword(auth, email, password);
        const { isAdmin: admin, role } = await checkAdminRole(cred.user.uid);
        if (!admin) {
          await signOut(auth);
          const e = new Error("NO_PERMISSION");
          e.name = "NO_PERMISSION";
          throw e;
        }
        const token = await cred.user.getIdToken();
        setIdToken(token);
        setUser(cred.user);
        setIsAdmin(true);
        setAdminRole(role);
      } catch (err: unknown) {
        if (err instanceof Error && err.message === "NO_PERMISSION") {
          throw err;
        }
        if (err && typeof err === "object" && "code" in err) {
          const code = (err as { code: string }).code;
          if (code === "auth/network-request-failed") {
            throw new Error("NETWORK_ERROR");
          }
          if (
            code === "auth/user-not-found" ||
            code === "auth/wrong-password" ||
            code === "auth/invalid-email" ||
            code === "auth/invalid-credential"
          ) {
            throw new Error("LOGIN_FAILED");
          }
        }
        throw new Error("UNKNOWN");
      } finally {
        setLoading(false);
      }
    },
    [checkAdminRole]
  );

  const logout = useCallback(async () => {
    await signOut(auth);
    setUser(null);
    setIdToken(null);
    setIsAdmin(false);
    setAdminRole(null);
  }, []);

  const getToken = useCallback(async (): Promise<string | null> => {
    if (!user) return null;
    const token = await user.getIdToken(true);
    setIdToken(token);
    return token;
  }, [user]);

  const value: AuthContextValue = {
    user,
    idToken,
    isAdmin,
    adminRole,
    loading,
    login,
    logout,
    getToken,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error("useAuth must be used within AuthProvider");
  }
  return ctx;
}
